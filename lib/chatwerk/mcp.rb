# frozen_string_literal: true

require 'mcp'

module Chatwerk
  # MCP Server setup
  class Mcp
    def self.server
      # Set up the server with all tools
      MCP::Server.new(
        name: name,
        version: Chatwerk::VERSION,
        tools: [
          Tools::PrintEnvTool,
          Tools::PackagesTool,
          Tools::PackageTool,
          Tools::PackageTodosTool,
          Tools::PackageViolationsTool
        ]
      )
    end

    def self.name
      'chatwerk'
    end
  end
end
