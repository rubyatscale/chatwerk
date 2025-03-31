require_relative 'base_view'

module Chatwerk
  module Views
    class ViolationsDetailsView < BaseView
      def template(package:, violations:, constant_name:)
        say "The following code violates package boundaries:\n"

        relevant_violations = violations
                              .anonymous_sources_with_locations
                              .select { |c, _| c.start_with?(constant_name) }

        if relevant_violations.empty?
          say Views::NoViolationsView.render(package:, constant_name:)
        else
          relevant_violations.each do |name, source|
            say "# Constant `#{name}`"
            if source && !source.empty?
              source.each do |code, files|
                say "  #{code}"
                files.each do |file|
                  say "  - #{file}"
                end
              end
            else
              say '  No usages found.'
            end
          end
        end
      end
    end
  end
end
