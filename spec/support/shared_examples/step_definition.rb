shared_examples_for 'step definition' do |step_name:, **options|
  test_class = Class.new do
    include Rung::Definition::StepsDSL
  end

  let(:operation) { test_class.new }
  let(:callable) { proc {} }

  before do
    allow(operation).to receive(:add_generic_step)
  end

  it 'creates step with a method name' do
    operation.public_send step_name, :some_name

    expect(operation).to have_received(:add_generic_step).with(
      :some_name, options
    )
  end

  it 'creates step with a callable' do
    operation.public_send step_name, callable
    expect(operation).to have_received(:add_generic_step).with(
      callable, options
    )
  end

  it 'creates step with a block' do
    operation.public_send step_name, &callable
    expect(operation).to have_received(:add_generic_step).with(
      nil, options, &callable
    )
  end
end
