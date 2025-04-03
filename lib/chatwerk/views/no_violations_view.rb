require_relative 'base_view'

module Chatwerk
  module Views
    class NoViolationsView < BaseView
      def template(package:, constant_name: nil)
        if constant_name.nil?
          <<~MESSAGE
            No violations found in #{package.name.inspect}.
          MESSAGE
        else
          <<~MESSAGE
            No violations found in #{package.name.inspect} for #{constant_name.inspect}.
            Ensure that constant_name is given in the format of "::ConstantName" or "::ConstantName::NestedConstant".
          MESSAGE
        end
      end
    end
  end
end
