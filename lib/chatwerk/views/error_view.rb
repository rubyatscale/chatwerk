require_relative 'base_view'

module Chatwerk
  module Views
    class ErrorView < BaseView
      def template(error:, package_path: nil, args: {})
        if error.is_a?(Chatwerk::Error)
          say error.message
        elsif package_path && !package_path.empty?
          say "There was a problem finding or accessing #{package_path.inspect}"
        else
          say 'There was a problem accessing packages'
        end
        say <<~ERROR
          Error: #{error.message}

          * Please ensure that the package path is correct.
          * Check that there is a package.yml file in the given directory.
          * Check that the path is a project root relative path that doesn't start with a slash.
          * Try calling the packages tool with the package_path to see if it is valid.
        ERROR

        say 'Backtrace:'
        say error.backtrace.join("\n")
      end
    end
  end
end
