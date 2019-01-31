describe Rung::Definition::StepsDSL do
  describe '#add_generic_step' do
    test_class = Class.new do
      include Rung::Definition::StepsDSL
    end

    let(:operation) { test_class.new }
    let(:action1) { proc {} }
    let(:action2) { proc {} }

    it 'adds steps to steps_definition' do
      operation.add_generic_step action1
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(action1)
      ]
    end

    it 'adds multiple specs' do
      operation.add_generic_step action1
      operation.add_generic_step action2
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(action1),
        Rung::Definition::Step.new(action2)
      ]
    end

    it 'supports step options' do
      operation.add_generic_step(
        action1,
        run_on: :all, ignore_result: true, fail_fast: true
      )
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(
          action1, run_on: :all, ignore_result: true, fail_fast: true
        )
      ]
    end

    it 'supports block' do
      operation.add_generic_step(nil, &action1)
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(action1, from_block: true)
      ]
    end

    it 'supports block with step options' do
      operation.add_generic_step(
        nil,
        run_on: :all, ignore_result: true, fail_fast: true,
        &action1
      )
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(
          action1,
          run_on: :all, ignore_result: true, fail_fast: true,
          from_block: true
        )
      ]
    end

    it 'supports method name' do
      operation.add_generic_step :some_method
      expect(operation.steps_definition).to eq [
        Rung::Definition::Step.new(:some_method)
      ]
    end

    describe 'wrappers' do
      it 'supports wrappers with nested steps' do
        wrapper = action1
        operation.add_generic_step wrapper do
          add_generic_step :step1
        end

        expect(operation.steps_definition).to eq [
          Rung::Definition::NestedStep.new(
            wrapper,
            [
              Rung::Definition::Step.new(:step1)
            ]
          )
        ]
      end

      it 'supports nested wrappers' do
        wrapper = action1
        nested_wrapper = action2
        operation.add_generic_step wrapper do
          add_generic_step :step1
          add_generic_step nested_wrapper do
            add_generic_step :step2
          end
        end

        expect(operation.steps_definition).to eq [
          Rung::Definition::NestedStep.new(
            wrapper,
            [
              Rung::Definition::Step.new(:step1),
              Rung::Definition::NestedStep.new(
                nested_wrapper,
                [
                  Rung::Definition::Step.new(:step2)
                ]
              )
            ]
          )
        ]
      end
    end
  end

  describe '#step' do
    it_should_behave_like 'step definition', step_name: 'step'
  end

  describe '#tee' do
    it_should_behave_like 'step definition',
      step_name: 'tee', ignore_result: true
  end

  describe '#failure' do
    it_should_behave_like 'step definition',
      step_name: 'failure', ignore_result: true, run_on: :failure
  end

  describe '#always' do
    it_should_behave_like 'step definition',
      step_name: 'always', ignore_result: true, run_on: :any
  end
end
