module Rung
  class WrapperBlockDSL
    include StepsDSL

    def self.call(&block)
      dsl_instance = new
      dsl_instance.instance_exec(&block)
      dsl_instance.steps
    end

    private_class_method :new
  end
end
