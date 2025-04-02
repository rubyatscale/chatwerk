require 'spec_helper'

RSpec.describe Chatwerk::Views::PackageView do
  context 'with a valid package' do
    it 'renders package details' do
      config = { 'dependencies' => ['core'], 'enforce_dependencies' => true }
      package = instance_double('QueryPackwerk::Package',
                                name: 'orders',
                                config: config,
                                enforce_dependencies: true,
                                enforce_privacy: true,
                                owner: 'Test Team',
                                metadata: {},
                                dependency_names: ['dependency1'],
                                consumer_names: ['consumer1'],
                                todos: [],
                                violations: [])

      expect(described_class.render(package:)).to eq(<<~OUTPUT)
        ---
        name: orders
        enforce_dependencies: true
        enforce_privacy: true
        owner: Test Team
        metadata: {}
        dependencies:
        - dependency1
        consumers:
        - consumer1
        todos_count: 0
        violations_count: 0

      OUTPUT
    end
  end
end
