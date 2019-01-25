describe Rung do
  describe "successful run" do
    let(:proc_with_one_argument_spy) { spy }
    let(:proc_no_argument_spy) { spy }

    let(:method_with_argument_spy) { spy }
    let(:method_no_arguments_spy) { spy }
    let(:block_no_arguments_spy) { spy }
    let(:block_with_arguments_spy) { spy }

    let(:class_with_state_argument_spy) { spy }
    let(:class_with_state_argument) do
      Class.new do
        class << self
          def call(state)
            @spy.call(state)
            state[:class_with_state_argument] = true
            true
          end

          attr_writer :spy
        end
      end.tap do |klass|
        klass.spy = class_with_state_argument_spy
      end
    end

    let(:class_without_argument_spy) { spy }
    let(:class_without_argument) do
      Class.new do
        class << self
          def call
            @spy.call
            true
          end

          attr_writer :spy
        end
      end.tap do |klass|
        klass.spy = class_without_argument_spy
      end
    end

    let(:successful_test_class) do
      block_no_arguments_spy = self.block_no_arguments_spy
      block_with_arguments_spy = self.block_with_arguments_spy
      proc_with_one_argument_spy = self.proc_with_one_argument_spy
      proc_no_argument_spy = self.proc_no_argument_spy
      class_with_state_argument = self.class_with_state_argument
      class_without_argument = self.class_without_argument

      Class.new(Rung::Base) do
        def initialize(method_with_argument_spy, method_no_arguments_spy)
          @method_with_argument_spy = method_with_argument_spy
          @method_no_arguments_spy = method_no_arguments_spy
        end

        step :test_method
        step class_with_state_argument
        step class_without_argument
        step :test_method2
        step do
          @anonymous_step1 = true
          block_no_arguments_spy.call
          true
        end
        step do |state|
          state[:anonymous_step] = true
          @anonymous_step2 = true
          block_with_arguments_spy.call(state)
          5 # number
        end
        step proc_with_one_argument_spy
        step proc_no_argument_spy

        def test_method(state)
          state[:test_method] = true
          @method_with_argument_spy.call(state)
          true
        end

        def test_method2
          @method_no_arguments_spy.call
          "ok" # string
        end
      end
    end

    let(:instance) { successful_test_class.new(method_with_argument_spy, method_no_arguments_spy) }
    subject!(:result) { instance.call }

    it "has a successful result" do
      expect(result).to be_success
      expect(result).not_to be_failure
    end

    it "calls all the steps in order" do
      expect(method_with_argument_spy).to have_received(:call).ordered
      expect(class_with_state_argument_spy).to have_received(:call).ordered
      expect(class_without_argument_spy).to have_received(:call).ordered
      expect(method_no_arguments_spy).to have_received(:call).ordered
      expect(block_no_arguments_spy).to have_received(:call).ordered
      expect(proc_with_one_argument_spy).to have_received(:call).ordered
      expect(proc_no_argument_spy).to have_received(:call).ordered
    end

    it "executes anonymous steps in the instance context" do
      expect(instance.instance_variable_get "@anonymous_step1").to eq true
      expect(instance.instance_variable_get "@anonymous_step2").to eq true
    end

    it "provides state for callable objects" do
      expect(result.state[:class_with_state_argument]).to eq true
    end

    it "provides state for anonymous blocks" do
      expect(result.state[:anonymous_step]).to eq true
    end

    it "provides state for test methods" do
      expect(result.state[:test_method]).to eq true
    end
  end
end
