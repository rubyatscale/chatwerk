# frozen_string_literal: true

require 'mcp'

module Chatwerk
  module Tools
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
          result = Api.package(package_path: package_path)

          MCP::Tool::Response.new([{
                                    type: 'text',
                                    text: result
                                  }])
        end
      end
    end
  end
end
