require 'mcp'
require 'query_packwerk'
require 'parse_packwerk'
require 'yaml'
require_relative 'views'
require_relative 'api'
require_relative 'helpers'

module Chatwerk
  # Print environment information tool
  class PrintEnvTool < MCP::Tool
    description 'Get the current working directory and environment path of the MCP server, ensuring correct directory context'

    input_schema(
      properties: {},
      required: []
    )

    class << self
      def call(server_context:)
        msg = <<~MESSAGE
          Relay these exact details to the user:
          Current Directory: #{Dir.pwd}
          Environment: #{ENV.fetch('PWD', nil)}
        MESSAGE
        Helpers.chdir do
          msg << "Chdir'd to #{Helpers.pwd}\n"
        end
        msg << ENV.to_h.map { |key, value| "#{key}=#{value}" }.join("\n")

        MCP::Tool::Response.new([{
                                  type: 'text',
                                  text: msg
                                }])
      end
    end
  end

  # List packages tool
  class PackagesTool < MCP::Tool
    description <<~DESC
      List all valid packwerk packages (aka packs) in the project.
      Use this to find or list packages, optionally matching a substring of the package_path.
    DESC

    input_schema(
      properties: {
        package_path: {
          type: 'string',
          description: "A partial package path name to constrain the results (e.g. 'packs/product_services/payments/banks' or 'payments/banks')."
        }
      },
      required: []
    )

    class << self
      def call(server_context:, package_path: nil)
        result = API.packages(package_path: package_path)

        MCP::Tool::Response.new([{
                                  type: 'text',
                                  text: result
                                }])
      end
    end
  end

  # Show package details tool
  class PackageTool < MCP::Tool
    description <<~DESC
      Show the details for a specific package.

      Output format:
      - Package details, including dependencies and configuration
    DESC

    input_schema(
      properties: {
        package_path: {
          type: 'string',
          description: "A full relative package path (e.g. 'packs/product_services/payments/banks')."
        }
      },
      required: ['package_path']
    )

    class << self
      def call(package_path:, server_context:)
        Helpers.chdir
        result = API.package(package_path: package_path)

        MCP::Tool::Response.new([{
                                  type: 'text',
                                  text: result
                                }])
      end
    end
  end

  # Package todos (violations FROM this package) tool
  class PackageTodosTool < MCP::Tool
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

    input_schema(
      properties: {
        package_path: {
          type: 'string',
          description: "The relative path of a directory containing a package.yml file (e.g. 'packs/product_services/payments/origination_banks')."
        },
        constant_name: {
          type: 'string',
          description: "The name of a constant to filter the results by. If provided, a more detailed list of code usage examples will be returned. (e.g. '::OtherPackage::SomeClass')"
        }
      },
      required: ['package_path']
    )

    class << self
      def call(package_path:, server_context:, constant_name: nil)
        Helpers.chdir
        result = API.package_todos(package_path: package_path, constant_name: constant_name)

        MCP::Tool::Response.new([{
                                  type: 'text',
                                  text: result
                                }])
      end
    end
  end

  # Package violations (violations TO this package) tool
  class PackageViolationsTool < MCP::Tool
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

    input_schema(
      properties: {
        package_path: {
          type: 'string',
          description: "The relative path of a directory containing a package.yml file (e.g. 'packs/product_services/payments/origination_banks'). AKA a 'pack' or 'package'."
        },
        constant_name: {
          type: 'string',
          description: 'The name of a constant to filter the results by. If provided, a more detailed list of code usage examples will be returned.'
        }
      },
      required: ['package_path']
    )

    class << self
      def call(package_path:, server_context:, constant_name: nil)
        Helpers.chdir
        result = API.package_violations(package_path: package_path, constant_name: constant_name)

        MCP::Tool::Response.new([{
                                  type: 'text',
                                  text: result
                                }])
      end
    end
  end

  # MCP Server setup
  class Mcp
    def self.server
      # Set up the server with all tools
      MCP::Server.new(
        name: name,
        version: Chatwerk::VERSION,
        tools: [
          PrintEnvTool,
          PackagesTool,
          PackageTool,
          PackageTodosTool,
          PackageViolationsTool
        ]
      )
    end

    def self.name
      'chatwerk'
    end
  end
end
