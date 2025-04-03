require_relative 'base_view'

module Chatwerk
  module Views
    class ViolationsListView < BaseView
      # The anonymous_source_counts method returns a hash as follows:
      # {
      #   "::Core::User" => {
      #     "User.find(_)" => 2,
      #     "User.create(_)" => 1
      #   }
      #   "::Core::Product" => {
      #     "Product.find(_)" => 1,
      #     "Product.create(_)" => 1
      #   }
      # }
      def template(package:, violations:)
        sums = violations.anonymous_source_counts.transform_values do |source_counts|
          source_counts.values.sum
        end

        if sums.empty?
          NoViolationsView.render(package:)
        else
          sums.sort_by { |_, count| -count }.map do |constant_name, count|
            "#{constant_name} (#{format_count(count, 'violation')})\n"
          end.join
        end
      end
    end
  end
end
