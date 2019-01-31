shared_examples_for 'operation callback definition' do |callback_name|
  test_class = Class.new do
    include Rung::Definition::OperationDSL
  end

  let(:operation) { test_class.new }
  let(:callable) { proc {} }

  it 'creates callback from a method name' do
    operation.public_send callback_name, :some_method
    expect(operation.public_send("#{callback_name}_callbacks")).to eq [
      Rung::Definition::Callback.new(:some_method)
    ]
  end

  it 'creates callback from a callable' do
    operation.public_send callback_name, callable
    expect(operation.public_send("#{callback_name}_callbacks")).to eq [
      Rung::Definition::Callback.new(callable)
    ]
  end

  it 'creates callback from a block' do
    operation.public_send callback_name, &callable
    expect(operation.public_send("#{callback_name}_callbacks")).to eq [
      Rung::Definition::Callback.new(callable, from_block: true)
    ]
  end

  it 'supports multiple callbacks' do
    operation.public_send callback_name, :some_method
    operation.public_send callback_name, callable
    expect(operation.public_send("#{callback_name}_callbacks")).to eq [
      Rung::Definition::Callback.new(:some_method),
      Rung::Definition::Callback.new(callable)
    ]
  end
end
