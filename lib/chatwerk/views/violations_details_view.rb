require_relative 'base_view'

module Chatwerk
  module Views
    class ViolationsDetailsView < BaseView
      def template(package:, violations:)
        say "Usage of constants in violation of a dependency boundary.\n"

        violations.anonymous_sources_with_locations.each do |constant_name, source|
          say "# Constant `#{constant_name}`"
          if source && !source.empty?
            source.each do |code, files|
              say "  #{code}"
              files.each do |file|
                say "  - #{file}"
              end
            end
          else
            say '  No sources found.'
          end
        end
      end
    end
  end
end
