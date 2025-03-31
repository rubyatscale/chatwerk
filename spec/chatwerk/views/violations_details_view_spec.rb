require 'spec_helper'

RSpec.describe Chatwerk::Views::ViolationsDetailsView do
  context 'with violations having source locations' do
    it 'renders violation details with source locations' do
      package = instance_double('QueryPackwerk::Package', name: 'orders')
      constant_name = '::Core::User'
      sources = {
        '::Core::User' => {
          'User.find(order.user_id)' => ['app/packages/orders/app/models/order.rb:45', 'app/packages/orders/app/services/order_service.rb:12'],
          'User.create(user_params)' => ['app/packages/orders/app/controllers/orders_controller.rb:28']
        }
      }
      violations = instance_double('QueryPackwerk::Violations', anonymous_sources_with_locations: sources)

      expect(described_class.render(package:, violations:, constant_name:)).to eq(<<~OUTPUT)
        The following code violates package boundaries:

        # Constant `::Core::User`
          User.find(order.user_id)
          - app/packages/orders/app/models/order.rb:45
          - app/packages/orders/app/services/order_service.rb:12
          User.create(user_params)
          - app/packages/orders/app/controllers/orders_controller.rb:28
      OUTPUT
    end
  end

  context 'with violations having no source locations' do
    it 'renders message about no sources being found' do
      package = instance_double('QueryPackwerk::Package', name: 'orders')
      constant_name = '::Core::Product'
      sources = {
        '::Core::Product' => {}
      }
      violations = instance_double('QueryPackwerk::Violations', anonymous_sources_with_locations: sources)

      expect(described_class.render(package:, violations:, constant_name:)).to eq(<<~OUTPUT)
        The following code violates package boundaries:

        # Constant `::Core::Product`
          No usages found.
      OUTPUT
    end
  end
end
