describe Rung::Definition::OperationDSL do
  describe '#around' do
    it_behaves_like 'operation callback definition', 'around'
  end

  describe '#around_each' do
    it_behaves_like 'operation callback definition', 'around_each'
  end
end
