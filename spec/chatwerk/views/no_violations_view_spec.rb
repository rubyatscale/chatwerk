require 'spec_helper'

RSpec.describe Chatwerk::Views::NoViolationsView do
  it 'renders a message indicating no violations found' do
    package = instance_double('Chatwerk::Package', name: 'orders')
    constant_name = '::Orders::Order'

    expect(described_class.render(package:, constant_name:)).to eq(<<~MESSAGE)
      No violations found in "orders" for "::Orders::Order".
      Ensure that constant_name is given in the format of:
        "::ConstantName"
        "::ConstantName::NestedConstant"
    MESSAGE
  end
end
