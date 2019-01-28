Before do
  allow_any_instance_of(Object).to receive(:print_to_output) do |_receiver, output|
    @stored_output ||= ""
    @stored_output << output
  end
end

Then("I see output") do |string|
  expect(@stored_output).to eq string
end

Then("I clear output") do
  @stored_output = ""
end
