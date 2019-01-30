describe Rung do
  context 'with a complex class' do
    let(:proc_with_one_argument_spy) { spy }
    let(:proc_no_argument_spy) { spy }

    let(:method_with_argument_spy) { spy }
    let(:method_no_arguments_spy) { spy }
    let(:block_no_arguments_spy) { spy }
    let(:block_with_arguments_spy) { spy }

    let(:class_with_argument_spy) { spy }
    let(:class_with_state_argument) do
      Class.new do
        class << self
          def call(state)
            state[:class_with_state_argument] = true
            @spy.call(state)
          end

          attr_writer :spy
        end
      end.tap do |klass|
        klass.spy = class_with_argument_spy
      end
    end

    let(:empty_wrapper) do
      Class.new do
        def self.call
          yield
        end
      end
    end

    let(:class_without_argument_spy) { spy }
    let(:class_without_argument) do
      Class.new do
        class << self
          def call
            @spy.call
          end

          attr_writer :spy
        end
      end.tap do |klass|
        klass.spy = class_without_argument_spy
      end
    end

    let(:failure_spy) { spy }

    let(:test_class) do
      block_no_arguments_spy = self.block_no_arguments_spy
      block_with_arguments_spy = self.block_with_arguments_spy
      proc_with_one_argument_spy = self.proc_with_one_argument_spy
      proc_no_argument_spy = self.proc_no_argument_spy
      class_with_state_argument = self.class_with_state_argument
      class_without_argument = self.class_without_argument
      empty_wrapper = self.empty_wrapper
      failure_spy = self.failure_spy

      Class.new(Rung::Operation) do
        def initialize(method_with_argument_spy, method_no_arguments_spy)
          @method_with_argument_spy = method_with_argument_spy
          @method_no_arguments_spy = method_no_arguments_spy
        end

        step :test_method
        step empty_wrapper do
          step class_with_state_argument
          step empty_wrapper do
            step class_without_argument
            step :test_method2
          end
        end
        step do
          @anonymous_step1 = true
          block_no_arguments_spy.call
        end
        step do |state|
          state[:anonymous_step] = true
          @anonymous_step2 = true
          block_with_arguments_spy.call(state)
        end
        step proc_with_one_argument_spy
        step proc_no_argument_spy
        failure failure_spy

        def test_method(state)
          state[:test_method] = true
          @method_with_argument_spy.call(state)
        end

        def test_method2
          @method_no_arguments_spy.call
        end
      end
    end

    let(:instance) { test_class.new(method_with_argument_spy, method_no_arguments_spy) }
    subject(:result) { instance.call }

    describe 'successful run' do
      before { result }

      it 'has a successful result' do
        expect(result).to be_success
        expect(result).not_to be_failure
      end

      it 'calls all the steps in order' do
        expect(method_with_argument_spy).to have_received(:call).ordered
        expect(class_with_argument_spy).to have_received(:call).ordered
        expect(class_without_argument_spy).to have_received(:call).ordered
        expect(method_no_arguments_spy).to have_received(:call).ordered
        expect(block_no_arguments_spy).to have_received(:call).ordered
        expect(proc_with_one_argument_spy).to have_received(:call).ordered
        expect(proc_no_argument_spy).to have_received(:call).ordered
      end

      it 'executed anonymous steps in the instance context' do
        expect(instance.instance_variable_get('@anonymous_step1')).to eq true
        expect(instance.instance_variable_get('@anonymous_step2')).to eq true
      end

      it 'provides state for callable objects' do
        expect(result[:class_with_state_argument]).to eq true
      end

      it 'provides state for anonymous blocks' do
        expect(result[:anonymous_step]).to eq true
      end

      it 'provides state for test methods' do
        expect(result[:test_method]).to eq true
      end

      it "doesn't execute failure step" do
        expect(failure_spy).not_to have_received(:call)
      end
    end

    describe 'failed run' do
      context 'proc with no argument (last step) failure' do
        before do
          allow(proc_no_argument_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).to have_received(:call).ordered
          expect(method_no_arguments_spy).to have_received(:call).ordered
          expect(block_no_arguments_spy).to have_received(:call).ordered
          expect(proc_with_one_argument_spy).to have_received(:call).ordered
          expect(proc_no_argument_spy).to have_received(:call).ordered
        end

        it 'executed anonymous steps in the instance context' do
          result
          expect(instance.instance_variable_get('@anonymous_step1')).to eq true
          expect(instance.instance_variable_get('@anonymous_step2')).to eq true
        end

        it 'provides state for callable objects' do
          expect(result[:class_with_state_argument]).to eq true
        end

        it 'provides state for anonymous blocks' do
          expect(result[:anonymous_step]).to eq true
        end

        it 'provides state for test methods' do
          expect(result[:test_method]).to eq true
        end
      end

      context 'proc with one argument failure' do
        before do
          allow(proc_with_one_argument_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).to have_received(:call).ordered
          expect(method_no_arguments_spy).to have_received(:call).ordered
          expect(block_no_arguments_spy).to have_received(:call).ordered
          expect(proc_with_one_argument_spy).to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end

      context 'block with no argument failure' do
        before do
          allow(block_no_arguments_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).to have_received(:call).ordered
          expect(method_no_arguments_spy).to have_received(:call).ordered
          expect(block_no_arguments_spy).to have_received(:call).ordered
          expect(proc_with_one_argument_spy).not_to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end

      context 'method with no argument failure' do
        before do
          allow(method_no_arguments_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).to have_received(:call).ordered
          expect(method_no_arguments_spy).to have_received(:call).ordered
          expect(block_no_arguments_spy).not_to have_received(:call).ordered
          expect(proc_with_one_argument_spy).not_to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end

      context 'class without argument failure' do
        before do
          allow(class_without_argument_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).to have_received(:call).ordered
          expect(method_no_arguments_spy).not_to have_received(:call).ordered
          expect(block_no_arguments_spy).not_to have_received(:call).ordered
          expect(proc_with_one_argument_spy).not_to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end

      context 'class with state failure' do
        before do
          allow(class_with_argument_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).to have_received(:call).ordered
          expect(class_without_argument_spy).not_to have_received(:call).ordered
          expect(method_no_arguments_spy).not_to have_received(:call).ordered
          expect(block_no_arguments_spy).not_to have_received(:call).ordered
          expect(proc_with_one_argument_spy).not_to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end

      context 'method with argument failure' do
        before do
          allow(method_with_argument_spy).to receive(:call)
        end

        it 'has a failed result' do
          expect(result).to be_failure
          expect(result).not_to be_success
        end

        it 'executed failed and earlier steps' do
          result
          expect(method_with_argument_spy).to have_received(:call).ordered
          expect(class_with_argument_spy).not_to have_received(:call).ordered
          expect(class_without_argument_spy).not_to have_received(:call).ordered
          expect(method_no_arguments_spy).not_to have_received(:call).ordered
          expect(block_no_arguments_spy).not_to have_received(:call).ordered
          expect(proc_with_one_argument_spy).not_to have_received(:call).ordered
          expect(proc_no_argument_spy).not_to have_received(:call).ordered
        end
      end
    end
  end
end
