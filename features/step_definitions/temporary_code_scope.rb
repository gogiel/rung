class TemporaryScope
end

Given("definition") do |content|
  @temporary_scope ||= TemporaryScope.new

  @temporary_scope.instance_eval(content)
end

When("I run") do |content|
  @temporary_scope.instance_eval(content)
end

Then("I can assure that") do |content|
  expect(@temporary_scope.instance_eval(content)).to eq true
end
