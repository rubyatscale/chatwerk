require 'mcp'
require 'query_packwerk'
require 'parse_packwerk'
require 'yaml'
require_relative 'views'
require_relative 'api'

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
        Helpers.chdir do
          msg << "Chdir'd to #{Helpers.pwd}\n"
        end
        msg << ENV.to_h.map { |key, value| "#{key}=#{value}" }.join("\n")
      end
    end

    tool 'packages' do
      description <<~DESC
        List all valid packwerk packages (aka packs) in the project.
        Use this to find or list packages, optionally matching a substring of the package_path.
      DESC
      argument :package_path, String, required: false, description: "A partial package path name to constrain the results (e.g. 'packs/product_services/payments/banks' or 'payments/banks')."
      call do |args|
        Helpers.chdir
        API.packages(package_path: args[:package_path])
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
        Helpers.chdir
        API.package(package_path: args[:package_path])
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
        Helpers.chdir
        API.package_todos(package_path: args[:package_path], constant_name: args[:constant_name])
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
        Helpers.chdir
        API.package_violations(package_path: args[:package_path], constant_name: args[:constant_name])
      end
    end
  end
end
