require 'spec_helper'

RSpec.describe Chatwerk::Views::ViolationsListView do
  context 'with multiple violations' do
    it 'renders a list of violations with counts' do
      violations = instance_double('Chatwerk::Violations')
      allow(violations).to receive(:anonymous_source_counts).and_return({
                                                                          '::Core::User' => { 'source1' => 2, 'source2' => 1 },
                                                                          '::Core::Product' => { 'source3' => 1 }
                                                                        })

      expect(described_class.render(violations:)).to eq(<<~OUTPUT)
        These constants violate package boundaries:
        ::Core::User: 3 violations
        ::Core::Product: 1 violation
      OUTPUT
    end
  end
end
