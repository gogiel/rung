shared_examples_for 'step' do |step_builder:|
  let(:options) { {} }
  let(:action) { double :action }
  let(:step) { instance_exec action, options, &step_builder }

  describe '#action' do
    subject { step.action }
    it { should eq action }
  end

  describe '#from_block' do
    subject { step.from_block }

    context 'by default' do
      it { should eq false }
    end

    context 'with options: from_block: true' do
      let(:options) { { from_block: true } }
      it { should eq true }
    end
  end

  describe 'run?' do
    subject { step.run? success }

    describe 'on success' do
      let(:success) { true }

      context 'by default' do
        it { should eq true }
      end

      context 'with options: run_on: :failure' do
        let(:options) { { run_on: :failure } }
        it { should eq false }
      end

      context 'with options: run_on: :any' do
        let(:options) { { run_on: :any } }
        it { should eq true }
      end

      context 'with options: run_on: :some_invalid_state' do
        let(:options) { { run_on: :some_invalid_state } }
        it { should eq false }
      end
    end

    describe 'on failure' do
      let(:success) { false }

      context 'by default' do
        it { should eq false }
      end

      context 'with options: run_on: :failure' do
        let(:options) { { run_on: :failure } }
        it { should eq true }
      end

      context 'with options: run_on: :any' do
        let(:options) { { run_on: :any } }
        it { should eq true }
      end

      context 'with options: run_on: :some_invalid_state' do
        let(:options) { { run_on: :some_invalid_state } }
        it { should eq false }
      end
    end

    describe '#ignore_result?' do
      subject { step.ignore_result? }

      context 'by default' do
        it { should eq false }
      end

      context 'with options: ignore_result: true' do
        let(:options) { { ignore_result: true } }
        it { should eq true }
      end
    end

    describe '#fail_fast?' do
      subject { step.fail_fast? }

      context 'by default' do
        it { should eq false }
      end

      context 'with options: fail_fast: true' do
        let(:options) { { fail_fast: true } }
        it { should eq true }
      end
    end
  end
end
