require 'mcp'
require 'query_packwerk'
require 'parse_packwerk'
require 'yaml'
require_relative 'views'

module Chatwerk
  class Mcp < MCP::App
    name 'chatwerk'
    version '0.1.0'

    # client_initialized do
    #   # MCP servers booted by Cursor aren't started with the PWD being set correctly.
    #   Dir.chdir(ENV["PWD"]) if ENV["PWD"]
    # end

    tool 'print_env' do
      description 'Get the current working directory and environment path of the MCP server, ensuring correct directory context'

      call do |_args|
        msg = <<~MESSAGE
          Relay these exact details to the user:
          Current Directory: #{Dir.pwd}
          Environment: #{ENV.fetch('PWD', nil)}
        MESSAGE
        Dir.chdir(ENV.fetch('PWD', nil)) do
          msg << "Chdir'd to #{Dir.pwd}\n"
        end
        msg << ENV.to_h.map { |key, value| "#{key}=#{value}" }.join("\n")
      end
    end

    tool 'packages' do
      description <<~DESC
        List all valid packwerk packages in the project, optionally matching a substring of the package_path.

        Output format:
        - List of all matching package paths.
      DESC
      argument :package_path, String, required: false, description: "A full relative package path or substring (e.g. 'packs/product_services/payments/banks' or 'payments/banks')."
      call do |args|
        Dir.chdir(ENV.fetch('PWD', nil))
        packages = Helpers.all_packages(args[:package_path])

        if packages.empty?
          has_packwerk_yml = File.exist?('packwerk.yml')
          Views::NoPackagesView.render(has_packwerk_yml:)
        else
          Views::PackagesView.render(packages:, has_packwerk_yml:)
        end
      rescue StandardError => e
        raise Views::ErrorView.render(package_path: args[:package_path], error: e)
      end
    end

    tool 'package' do
      description <<~DESC
        Show the details for a specific package.

        Output format:
        - Package details, including dependencies and configuration
      DESC
      argument :package_path, String, required: true, description: "A full relative package path (e.g. 'packs/product_services/payments/banks')."
      call do |args|
        Dir.chdir(ENV.fetch('PWD', nil))
        package = Helpers.find_package(args[:package_path])

        Views::PackageView.render(package:)
      rescue StandardError => e
        raise Views::ErrorView.render(package_path: args[:package_path], error: e)
      end
    end

    tool 'package_todos' do
      description <<~DESC
        Find code that violates dependency boundaries FROM this package TO other packages.

        Output formats:
        - Without constant_name: List of violated constants with counts
          Example: "::OtherPackage::SomeClass # 3 violations"
        - With constant_name: Detailed examples and locations
          Example:
            ::OtherPackage::SomeClass
              example: OtherPackage::SomeClass.new
              files:
                - app/services/my_service.rb
      DESC
      argument :package_path, String, required: true, description: "The relative path of a directory containing a package.yml file (e.g. 'packs/product_services/payments/origination_banks')."
      argument :constant_name, String, required: false, description: "The name of a constant to filter the results by. If provided, a more detailed list of code usage examples will be returned. (e.g. '::OtherPackage::SomeClass')"
      call do |args|
        Dir.chdir(ENV.fetch('PWD', nil))
        package = Helpers.find_package(args[:package_path])
        constant_name = Helpers.normalize_constant_name(args[:constant_name])
        violations = package.todos

        if constant_name.empty?
          Views::ViolationsListView.render(package:, violations:)
        else
          constant_violations = violations.anonymous_sources_with_locations.select { |c, _| c.start_with?(constant_name) }
          if constant_violations.empty?
            Views::NoViolationsView.render(package:, constant_name:)
          else
            Views::ViolationsDetailsView.render(package:, violations: constant_violations)
          end
        end
      rescue StandardError => e
        raise Views::ErrorView.render(package_path: args[:package_path], args: args, error: e)
      end
    end

    tool 'package_violations' do
      description <<~DESC
        Find code that violates dependency boundaries TO this package FROM other packages.

        Output formats:
        - Without constant_name: List of violated constants with counts
          Example: "::ThisPackage::SomeClass: 3 violations"
        - With constant_name: Detailed examples and locations
          Example:
            # Constant `::ThisPackage::SomeClass`
              ## Example:
                ThisPackage::SomeClass.new
              ### Files:
                app/services/other_service.rb
      DESC
      argument :package_path, String, required: true, description: "The relative path of a directory containing a package.yml file (e.g. 'packs/product_services/payments/origination_banks'). AKA a 'pack' or 'package'."
      argument :constant_name, String, required: false, description: 'The name of a constant to filter the results by. If provided, a more detailed list of code usage examples will be returned.'
      call do |args|
        Dir.chdir(ENV.fetch('PWD', nil))
        package = Helpers.find_package(args[:package_path])
        constant_name = Helpers.normalize_constant_name(args[:constant_name])
        violations = package.violations

        if constant_name.empty?
          Views::ViolationsListView.render(package:, violations:)
        else
          constant_violations = violations.anonymous_sources_with_locations.select { |c, _| c.start_with?(constant_name) }
          if constant_violations.empty?
            Views::NoViolationsView.render(package:, constant_name:)
          else
            Views::ViolationsDetailsView.render(package:, violations: constant_violations)
          end
        end
      rescue StandardError => e
        raise Chatwerk::Views::ErrorView.render(package_path: args[:package_path], args: args, error: e)
      end
    end
  end
end
