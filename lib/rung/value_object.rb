module Rung
  # Helper module for defining comparable value objects
  module ValueObject
    # @return [true] when other has the same class and equal instance variables
    # @return [false] otherwise
    def ==(other)
      return false if self.class != other.class

      instance_variables.all? do |variable|
        instance_variable_get(variable) ==
          other.send(:instance_variable_get, variable)
      end
    end
  end
end
