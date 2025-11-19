# frozen_string_literal: true

require 'mcp'
require_relative '../helpers'

module Chatwerk
  module Tools
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
  end
end
