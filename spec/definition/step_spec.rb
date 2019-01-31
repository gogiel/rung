describe Rung::Definition::Step do
  step_builder = lambda do |action, options|
    described_class.new action, options
  end

  it_should_behave_like 'step', step_builder: step_builder do
    describe '#nested?' do
      subject { step.nested? }
      it { should eq false }
    end
  end
end

describe Rung::Definition::NestedStep do
  step_builder = lambda do |action, options|
    described_class.new action, nested_steps, options
  end

  let(:nested_steps) { double :nested_steps }
  it_should_behave_like 'step', step_builder: step_builder do
    describe '#nested?' do
      subject { step.nested? }
      it { should eq true }
    end

    describe '#nested_steps' do
      subject { step.nested_steps }
      it { should eq nested_steps }
    end
  end
end
