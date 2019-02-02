describe Rung::Runner::CallHelper, '#call' do
  test_class = Class.new do
    def test_method1
      yield if block_given?
      :test_method1_return
    end

    def test_method2(state)
      yield if block_given?
      state[:value] = 5
      :test_method2_return
    end

    def test_method3(*args)
      yield if block_given?
      @test_method3_received_arguments = args
      :test_method3_return
    end

    attr_reader :test_method3_received_arguments
  end

  let(:second_argument) { double :second_argument }
  let(:action_from_block) { false }
  let(:block) { nil }

  subject do
    described_class.call(
      action, state, operation_instance,
      action_from_block, second_argument, &block
    )
  end

  let(:state) { {} }
  let(:operation_instance) { test_class.new }

  context 'callable action with no arguments' do
    let(:action) { -> { :action_return_value } }

    it 'calls action .call' do
      expect(subject).to eq :action_return_value
    end
  end

  context 'callable action with one argument' do
    let(:action) do
      lambda do |state|
        state[:value] = 6
        :action_return_value
      end
    end

    it 'calls action .call with state' do
      expect(subject).to eq :action_return_value
      expect(state[:value]).to eq 6
    end
  end

  context 'callable with vary arguments' do
    let(:action) { spy call: :action_return_value }

    it 'calls action .call with state and second_argument' do
      expect(subject).to eq :action_return_value
      expect(action).to have_received(:call).with(state, second_argument)
    end
  end

  context 'method with no state' do
    let(:action) { :test_method1 }

    it 'calls method with no arguments' do
      expect(subject).to eq :test_method1_return
    end
  end

  context 'method with one argument' do
    let(:action) { :test_method2 }
    it 'calls method with state' do
      expect(subject).to eq :test_method2_return
      expect(state[:value]).to eq 5
    end
  end

  context 'method with vary arguments' do
    let(:action) { :test_method3 }

    it 'calls action .call with state and second_argument' do
      expect(subject).to eq :test_method3_return
      expect(operation_instance.test_method3_received_arguments).to eq [
        state, second_argument
      ]
    end
  end

  describe 'with from_block' do
    let(:action_from_block) { true }

    context 'action with no arguments' do
      let(:action) { -> { test_method1 } }

      it 'calls action .call in the operation_instance context' do
        expect(subject).to eq :test_method1_return
      end
    end

    context 'action with one argument' do
      let(:action) { ->(state) { test_method2(state) } }

      it 'calls action .call with state in the operation_instance context' do
        expect(subject).to eq :test_method2_return
        expect(state[:value]).to eq 5
      end
    end

    context 'action with two arguments' do
      let(:action) do
        lambda do |state, second_argument|
          test_method2(state)
          second_argument
        end
      end

      it 'calls action .call with state and second_argument in the operation_instance context' do
        expect(subject).to eq second_argument
        expect(state[:value]).to eq 5
      end
    end

    context 'action with invariant arguments' do
      let(:action) do
        lambda do |*args|
          test_method3(*args)
        end
      end

      it 'calls action .call with state and second_argument in the operation_instance context' do
        expect(subject).to eq :test_method3_return
        expect(operation_instance.test_method3_received_arguments).to eq [
          state, second_argument
        ]
      end
    end
  end

  describe 'with action_from_block and block passed' do
    let(:block) { proc {} }
    let(:action) { double }
    let(:action_from_block) { true }

    it 'raises error' do
      expect { subject }.to raise_error(
        Rung::Error,
        "Can't pass block when action_from_block is enabled"
      )
    end
  end

  describe 'with block passed' do
    let(:block_spy) { spy }
    let(:block) { -> { block_spy.call } }

    context 'callable action with no arguments' do
      let(:action) do
        lambda do |&block|
          block.call
          :action_return_value
        end
      end

      it 'calls action .call passing the block' do
        expect(subject).to eq :action_return_value
        expect(block_spy).to have_received(:call)
      end
    end

    context 'callable action with one argument' do
      let(:action) do
        lambda do |state, &block|
          state[:value] = 6
          block.call
          :action_return_value
        end
      end

      it 'calls action .call with state passing the block' do
        expect(subject).to eq :action_return_value
        expect(state[:value]).to eq 6
        expect(block_spy).to have_received(:call)
      end
    end

    context 'callable with vary arguments' do
      let(:action) { spy call: :action_return_value }

      it 'calls action .call with state and second_argument passing the block' do
        expect(subject).to eq :action_return_value
        expect(action).to have_received(:call)
          .with(state, second_argument, &block)
      end
    end

    context 'method with no state' do
      let(:action) { :test_method1 }

      it 'calls method with no arguments passing the block' do
        expect(subject).to eq :test_method1_return
        expect(block_spy).to have_received(:call)
      end
    end

    context 'method with one argument' do
      let(:action) { :test_method2 }
      it 'calls method with state passing the block' do
        expect(subject).to eq :test_method2_return
        expect(state[:value]).to eq 5
        expect(block_spy).to have_received(:call)
      end
    end

    context 'method with vary arguments' do
      let(:action) { :test_method3 }

      it 'calls action .call with state and second_argument passing the block' do
        expect(subject).to eq :test_method3_return
        expect(operation_instance.test_method3_received_arguments).to eq [
          state, second_argument
        ]
        expect(block_spy).to have_received(:call)
      end
    end
  end
end
