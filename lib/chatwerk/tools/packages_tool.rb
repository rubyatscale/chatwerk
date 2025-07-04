# frozen_string_literal: true

require 'mcp'

module Chatwerk
  module Tools
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
          Helpers.chdir
          result = Api.packages(package_path: package_path)

          MCP::Tool::Response.new([{
                                    type: 'text',
                                    text: result
                                  }])
        end
      end
    end
  end
end
