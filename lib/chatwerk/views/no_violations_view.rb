require_relative 'base_view'

module Chatwerk
  module Views
    class NoViolationsView < BaseView
      def template(package:, constant_name:)
        <<~MESSAGE
          No violations found in #{package.name.inspect} for #{constant_name.inspect}.
          Ensure that constant_name is given in the format of:
            "::ConstantName"
            "::ConstantName::NestedConstant"
        MESSAGE
      end
    end
  end
end
