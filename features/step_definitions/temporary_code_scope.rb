Given('definition') do |content|
  @temporary_scope ||= Object.new

  @temporary_scope.instance_eval(content)
end

When('I run') do |content|
  @temporary_scope.instance_eval(content)
end

Then(/^I can assure that/) do |content|
  expect(@temporary_scope.instance_eval(content)).to eq true
end

Then('I can test that') do |content|
  @temporary_scope.instance_eval(content)
end
