# rubocop:disable Style/GlobalVars
describe Rung::Runner::Runner do
  let(:operation_class) do
    Class.new do
      class << self
        attr_accessor :steps_definition
        attr_accessor :around_callbacks
        attr_accessor :around_each_callbacks
      end

      self.steps_definition = []
      self.around_callbacks = []
      self.around_each_callbacks = []
    end
  end

  let(:operation_instance) do
    operation_class.new
  end

  let(:initial_state) { {} }

  before { $execution_trace = [] }

  before do
    allow(Rung::Runner::CallHelper).to receive(:call).with(
      anything, instance_of(Rung::State), operation_instance, :from_block_param
    ) { |action, state| action.call(state) }

    allow(Rung::Runner::CallHelper).to receive(:call).with(
      anything, instance_of(Rung::State), operation_instance
    ) { |action, state, &block| action.call(state, &block) }

    # rubocop:disable Metrics/ParameterLists
    allow(Rung::Runner::CallHelper).to receive(:call).with(
      anything, instance_of(Rung::State), operation_instance,
      :callback_from_block_param, anything
    ) do |action, state, _instance, _from_block, step, &block|
      action.call(state, step, &block)
    end
    # rubocop:enable Metrics/ParameterLists

    allow(Rung::Runner::CallHelper).to receive(:call).with(
      anything, instance_of(Rung::State), operation_instance,
      :callback_from_block_param, nil
    ) { |action, state, &block| action.call(state, &block) }
  end

  subject(:result) do
    described_class.new(operation_instance, initial_state).call
  end

  context 'no steps' do
    it 'has a successful result' do
      expect(result).to eq(Rung::State.new({}, true, operation_instance))
    end
  end

  context 'successful steps' do
    before do
      operation_class.steps_definition += [
        generate_step('first'),
        generate_step('second')
      ]
    end

    it 'has a successful result' do
      expect(result).to eq(Rung::State.new({}, true, operation_instance))
    end

    it 'calls steps in order' do
      result
      expect($execution_trace).to eq ['step first', 'step second']
    end
  end

  describe '#run? check' do
    before do
      operation_class.steps_definition += [
        generate_step('first', run_method: ->(_) { false }),
        generate_step('second'),
        generate_step('third', run_method: ->(_) { false })
      ]
    end

    it 'ignores steps that respond with false to #run?' do
      result
      expect($execution_trace).to eq ['step second']
    end
  end

  describe 'step failure' do
    before do
      operation_class.steps_definition += [
        generate_step('first',
          result: false,
          run_method: lambda do |success|
            expect(success).to eq true
          end),
        generate_step('second',
          run_method: lambda do |success|
            expect(success).to eq false
            true
          end),
        generate_step('third',
          run_method: lambda do |success|
            expect(success).to eq false
            false
          end)
      ]
    end

    it 'has unsuccessful result' do
      expect(result).to eq(Rung::State.new({}, false, operation_instance))
    end

    it 'passes false to next steps #run?' do
      result
      expect($execution_trace).to eq ['step first', 'step second']
    end
  end

  describe 'fail_fast' do
    before do
      operation_class.steps_definition += [
        generate_step('first',
          result: false,
          fail_fast: true),
        generate_step('second')
      ]
    end

    it 'immediately stops the execution' do
      expect(result).to eq(Rung::State.new({}, false, operation_instance))
    end

    it "doesn't call next steps" do
      result
      expect($execution_trace).to eq ['step first']
    end
  end

  describe 'step that ignores the result' do
    before do
      operation_class.steps_definition += [
        generate_step('first',
          result: false,
          ignore_result: true),
        generate_step('second')
      ]
    end

    it 'is successful when step that ignores the result return false' do
      expect(result).to eq(Rung::State.new({}, true, operation_instance))
    end

    it 'runs next steps' do
      result
      expect($execution_trace).to eq ['step first', 'step second']
    end
  end

  describe 'nested steps' do
    let(:nested_step) { generate_step('nested2') }

    before do
      operation_class.steps_definition += [
        generate_step('init'),
        generate_nested_step('first', [
                               generate_step('nested1'),
                               generate_nested_step('second', [
                                                      nested_step
                                                    ]),
                               generate_step('nested3')
                             ]),
        generate_nested_step('third', [
                               generate_step('last')
                             ])
      ]
    end

    it 'is successful' do
      expect(result).to eq(Rung::State.new({}, true, operation_instance))
    end

    it 'calls steps in the correct order' do
      result
      expect($execution_trace).to eq [
        'step init',
        'nested step before first',
        [
          'step nested1',
          'nested step before second',
          [
            'step nested2'
          ],
          'nested step after second',
          'step nested3'
        ],
        'nested step after first',
        'nested step before third',
        [
          'step last'
        ],
        'nested step after third'
      ].flatten!
    end

    context 'nested stap fails' do
      let(:nested_step) { generate_step('nested2', result: false) }

      it 'is a failure' do
        expect(result).to eq(Rung::State.new({}, false, operation_instance))
      end

      it "doesn't call next steps but still lets wrappers to finish" do
        result
        expect($execution_trace).to eq [
          'step init',
          'nested step before first',
          [
            'step nested1',
            'nested step before second',
            [
              'step nested2'
            ],
            'nested step after second'
            # "step nested3"
          ],
          'nested step after first'
          # "nested step before third",
          # [
          #   "step last"
          # ],
          # "nested step after third"
        ].flatten!
      end
    end
  end

  describe 'around callbacks support' do
    before do
      operation_class.steps_definition += [
        generate_step('step')
      ]

      operation_class.around_callbacks += [
        generate_callback('one'),
        generate_callback('two'),
        generate_callback('three')
      ]
    end

    it 'calls callbacks in the order they are defined' do
      result

      expect($execution_trace).to eq [
        'callback before one',
        'callback before two',
        'callback before three',

        'step step',

        'callback after three',
        'callback after two',
        'callback after one'
      ]
    end

    it 'has a result value not affected by callbacks' do
      expect(result).to eq(Rung::State.new({}, true, operation_instance))
    end
  end

  describe 'around each callbacks support' do
    describe 'callbacks order' do
      before do
        operation_class.around_each_callbacks += [
          generate_callback('one'),
          generate_callback('two')
        ]
        operation_class.steps_definition += [
          generate_step('first'),
          generate_nested_step('nest', [
                                 generate_step('last')
                               ])
        ]
      end

      it 'calls callbacks in the order they are defined' do
        result

        expect($execution_trace).to eq [
          'callback before one', 'callback before two',
          'step first',
          'callback after two', 'callback after one',

          'callback before one', 'callback before two',
          'nested step before nest',
          [
            'callback before one', 'callback before two',
            'step last',
            'callback after two', 'callback after one'
          ],
          'nested step after nest',
          'callback after two', 'callback after one'
        ].flatten!
      end
    end

    describe 'callbacks input' do
      let(:step) { generate_step('first') }
      before do
        operation_class.around_each_callbacks += [
          generate_callback('one', action: lambda do |state, step, &block|
            expect(state).to eq(Rung::State.new({}, true, operation_instance))
            expect(step).to eq step
            $execution_trace << 'callback executed'
            block.call
          end)
        ]
        operation_class.steps_definition += [
          step
        ]
      end

      it 'passes state and step to callback' do
        result
        expect($execution_trace).to eq ['callback executed', 'step first']
      end

      describe 'callbacks return value' do
        it 'can change return value of the step' do
          operation_class.around_each_callbacks = [
            generate_callback('one', action: proc do |&block|
              $execution_trace << 'callback executed'
              block.call
              false
            end)
          ]

          operation_class.steps_definition += [
            generate_step('seconds step')
          ]

          expect(result).to eq(Rung::State.new({}, false, operation_instance))
          expect($execution_trace).to eq ['callback executed', 'step first']
        end
      end

      it 'passes callback return value from last to first' do
        operation_class.around_each_callbacks = [
          generate_callback('one', action: proc do |&block|
            return_value = block.call
            $execution_trace << "callback one received: #{return_value}"
            :callback_one_value
          end),
          generate_callback('two', action: proc do |&block|
            return_value = block.call
            $execution_trace << "callback two received: #{return_value}"
            :callback_two_value
          end)
        ]

        operation_class.steps_definition = [
          generate_step('seconds step', result: :step_result)
        ]

        expect(result).to eq(Rung::State.new({}, true, operation_instance))
        expect($execution_trace).to eq [
          'step seconds step',
          'callback two received: step_result',
          'callback one received: callback_two_value'
        ]
      end
    end
  end

  describe 'initial state support' do
    let(:initial_state) { { value: 5 } }

    it 'is used to initialize the state' do
      operation_class.steps_definition = [
        generate_step('seconds step', action: proc do |state|
          state[:value] += 2
        end)
      ]

      expect(result).to eq(
        Rung::State.new(
          { value: 7 }, true, operation_instance
        )
      )
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists,
  # rubocop:disable Metrics/AbcSize
  def generate_step(
    name, result: true, fail_fast: false, action: nil,
    run_method: nil, ignore_result: false
  )
    run_method ||= ->(success) { success }
    action ||= proc do
      $execution_trace << "step #{name}"
      result
    end
    double("step_#{name}",
      action: action, nested?: false, from_block: :from_block_param,
      ignore_result?: ignore_result, fail_fast?: fail_fast).tap do |step|
      allow(step).to receive(:run?, &run_method)
    end
  end

  def generate_nested_step(name, nested_steps, result: true, fail_fast: false,
    run_method: nil, ignore_result: false)
    generate_step(name,
      result: result, fail_fast: fail_fast,
      run_method: run_method || ->(success) { success },
      ignore_result: ignore_result).tap do |step|
      allow(step).to receive(:nested?) { true }
      allow(step).to receive(:nested_steps) { nested_steps }
      allow(step).to receive(:action) do
        proc do |&block|
          $execution_trace << "nested step before #{name}"
          block.call
          $execution_trace << "nested step after #{name}"
        end
      end
    end
  end

  def generate_callback(name, action: nil)
    double("callback_#{name}",
      action: (action || proc do |&block|
        $execution_trace << "callback before #{name}"
        block.call
        $execution_trace << "callback after #{name}"
      end),
      from_block: :callback_from_block_param)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists, Metrics/AbcSize
end
# rubocop:enable Style/GlobalVars
