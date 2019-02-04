describe Rung::State do
  let(:internal_state) { { my_key: 'val' } }
  let(:success) { true }
  let(:operation) { double :operation }
  subject { described_class.new internal_state, success, operation }

  it 'behaves like a hash' do
    expect(subject[:my_key]).to eq 'val'
    expect(subject.to_h).to eq internal_state
  end

  context 'successful state' do
    describe '#success?' do
      it 'is true' do
        expect(subject.success?).to eq true
      end
    end

    describe '#fail?' do
      it 'is false' do
        expect(subject.fail?).to eq false
      end
    end
  end

  context 'failed state' do
    let(:success) { false }

    describe '#success?' do
      it 'is false' do
        expect(subject.success?).to eq false
      end
    end

    describe '#fail?' do
      it 'is true' do
        expect(subject.fail?).to eq true
      end
    end
  end

  describe '#failure?' do
    it 'is a #fail? alias' do
      expect(subject.method(:failure?).original_name).to eq(:fail?)
    end
  end

  describe '#failed??' do
    it 'is a #fail? alias' do
      expect(subject.method(:failed?).original_name).to eq(:fail?)
    end
  end

  describe '#successful???' do
    it 'is a #success?? alias' do
      expect(subject.method(:successful?).original_name).to eq(:success?)
    end
  end
end
