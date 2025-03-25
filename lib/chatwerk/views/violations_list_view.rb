require_relative 'base_view'

module Chatwerk
  module Views
    class ViolationsListView < BaseView
      def template(violations:)
        say 'These constants violate package boundaries:'
        violations.anonymous_source_counts.each do |constant_name, source_counts|
          count = source_counts.values.sum
          say "#{constant_name}: #{format_count(count, 'violation')}"
        end
      end
    end
  end
end
