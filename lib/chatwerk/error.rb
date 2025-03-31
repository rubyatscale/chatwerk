# frozen_string_literal: true

module Chatwerk
  class Error < RuntimeError
    def initialize(error, package_path: nil, **args)
      message =
        if package_path && !package_path.empty?
          "There was a problem finding or accessing #{package_path.inspect}"
        else
          'There was a problem accessing package information'
        end

      super(<<~ERROR)
        #{message}
        Error: #{error}

        * Please ensure that the package path is correct.
        * Check that there is a package.yml file in the given directory.
        * Check that the path is a project root relative path that doesn't start with a slash.
        * Try calling the packages tool with the package_path to see if it is valid.
      ERROR
    end
  end
end
