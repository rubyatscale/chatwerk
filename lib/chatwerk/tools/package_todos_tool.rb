# frozen_string_literal: true

require 'mcp'

module Chatwerk
  module Tools
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
          result = Api.package_todos(package_path: package_path, constant_name: constant_name)

          MCP::Tool::Response.new([{
                                    type: 'text',
                                    text: result
                                  }])
        end
      end
    end
  end
end
