module Rung
  class WrapperBlockDSL
    include StepsDSL

    def self.call(&block)
      new.call(&block)
    end

    attr_reader :steps

    def initialize
      @steps = Steps.new
    end

    def call(&block)
      instance_exec(&block)
      @steps
    end
  end
end
