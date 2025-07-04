# frozen_string_literal: true

module Chatwerk
  module Views
    class ViolationsDetailsView < BaseView
      def template(package:, violations:, constant_name:)
        relevant_violations = violations.anonymous_sources_with_locations.select { |c, _| c.start_with?(constant_name) }

        if relevant_violations.empty?
          Views::NoViolationsView.render(package:, constant_name:)
        else
          grep_formatted_violations(relevant_violations)
        end
      end

      private

      def grep_formatted_violations(relevant_violations)
        # Group violations by file
        files_to_violations = {}

        relevant_violations.each do |constant, source_info|
          say "No sources found for #{constant}" if source_info.empty?
          source_info.each do |code, files|
            say "No files found for #{constant} with code: #{code}" if files.empty?

            files.each do |file_with_line|
              file, line = file_with_line.split(':')
              files_to_violations[file] ||= []
              files_to_violations[file] << { constant:, code:, line: line }
            end
          end
        end

        # Output violations grouped by file
        files_to_violations.sort.map do |file, violations|
          lines = violations.sort_by { |v| v[:line].to_i }.map do |violation|
            "#{violation[:line]}:   #{violation[:code]}"
          end.join("\n")

          "#{file}\n#{lines}\n"
        end.join("\n")
      end
    end
  end
end
