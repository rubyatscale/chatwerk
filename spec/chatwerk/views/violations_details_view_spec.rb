require 'spec_helper'

RSpec.describe Chatwerk::Views::ViolationsDetailsView do
  context 'with violations having source locations' do
    it 'renders violation details with source locations' do
      package = instance_double('Chatwerk::Package', name: 'orders')

      # Create the violations double with source locations
      violations = instance_double('Chatwerk::Violations')
      allow(violations).to receive(:anonymous_sources_with_locations).and_return({
                                                                                   '::Core::User' => {
                                                                                     'User.find(order.user_id)' => ['app/packages/orders/app/models/order.rb:45', 'app/packages/orders/app/services/order_service.rb:12'],
                                                                                     'User.create(user_params)' => ['app/packages/orders/app/controllers/orders_controller.rb:28']
                                                                                   }
                                                                                 })

      expect(described_class.render(package:, violations:)).to eq(<<~OUTPUT)
        Usage of constants in violation of a dependency boundary.

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
      package = instance_double('Chatwerk::Package', name: 'orders')

      # Create the violations double with empty sources
      violations = instance_double('Chatwerk::Violations')
      allow(violations).to receive(:anonymous_sources_with_locations).and_return({
                                                                                   '::Core::Product' => {}
                                                                                 })

      expect(described_class.render(package:, violations:)).to eq(<<~OUTPUT)
        Usage of constants in violation of a dependency boundary.

        # Constant `::Core::Product`
          No sources found.
      OUTPUT
    end
  end
end
