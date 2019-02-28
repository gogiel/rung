describe Rung::Definition::NestedOperation do
  let(:state) { Rung::State.new({ a: 1, b: 2 }, double, double) }
  let(:nested_state_success) { double :nested_state_success }
  let(:nested_state) do
    Rung::State.new({ b: 3, c: 6 }, nested_state_success, double)
  end
  let(:operation) { spy call: nested_state }
  let(:nested_operation) { described_class.new(operation) }

  subject!(:result) { nested_operation.call(state) }

  it 'passes state with no changes' do
    expect(operation).to have_received(:call).with(a: 1, b: 2)
  end

  it 'modifies original state' do
    expect(state.to_h).to eq a: 1, b: 3, c: 6
  end

  it 'returns nested_state_success' do
    expect(result).to eq nested_state_success
  end

  context 'with input mapper' do
    let(:input_mapper) { ->(state) { { value_a: state[:a] } } }
    let(:nested_operation) do
      described_class.new(operation, input: input_mapper)
    end

    it 'modifies the input' do
      expect(operation).to have_received(:call).with(value_a: 1)
    end
  end

  context 'with output mapper' do
    let(:output_mapper) { ->(state) { { nested_output: state[:c] } } }
    let(:nested_operation) do
      described_class.new(operation, output: output_mapper)
    end

    it 'modifies the output' do
      expect(state.to_h).to eq a: 1, b: 2, nested_output: 6
    end
  end
end
