require 'spec_helper'

RSpec.describe Chatwerk::Views::ViolationsListView do
  context 'with multiple violations' do
    it 'renders a list of violations with counts' do
      package = instance_double('Chatwerk::Package', name: 'packs/core')
      violations = instance_double('Chatwerk::Violations')
      allow(violations).to receive(:anonymous_source_counts).and_return({
                                                                          '::Core::User' => { 'source1' => 2, 'source2' => 1 },
                                                                          '::Core::Product' => { 'source3' => 1 }
                                                                        })

      expect(described_class.render(package:, violations:)).to eq(<<~OUTPUT)
        ::Core::User (3 violations)
        ::Core::Product (1 violation)
      OUTPUT
    end
  end

  context 'with no violations' do
    it 'renders a message indicating no violations' do
      package = instance_double('Chatwerk::Package', name: 'packs/core')
      violations = instance_double('Chatwerk::Violations')
      allow(violations).to receive(:anonymous_source_counts).and_return({})

      expect(described_class.render(package:, violations:)).to eq(<<~OUTPUT)
        No violations found in "packs/core".
      OUTPUT
    end
  end
end
