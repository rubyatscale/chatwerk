# frozen_string_literal: true

RSpec.describe Chatwerk::Views::PackagesView do
  context 'when packages are found' do
    it 'renders a list of packages' do
      packages = [
        instance_double('Chatwerk::Package', name: 'orders'),
        instance_double('Chatwerk::Package', name: 'users'),
        instance_double('Chatwerk::Package', name: 'payments')
      ]
      package_path = 'app/packages'

      expect(described_class.render(packages:, package_path:)).to eq(<<~OUTPUT)
        orders
        payments
        users
      OUTPUT
    end
  end

  context 'when no packages are found' do
    it 'renders a message indicating no packages found' do
      packages = []
      package_path = 'app/invalid_path'

      expect(described_class.render(packages:, package_path:)).to eq(<<~OUTPUT)
        No packages found matching "app/invalid_path"
      OUTPUT
    end
  end
end
