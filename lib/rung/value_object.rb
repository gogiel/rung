module ComparableValueObject
  def ==(other)
    return false if self.class != other.class

    instance_variables.all? do |variable|
      instance_variable_get(variable) ==
        other.send(:instance_variable_get, variable)
    end
  end
end
