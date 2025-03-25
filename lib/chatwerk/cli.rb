# typed: false
# frozen_string_literal: true

require 'thor'
require 'chatwerk'
require 'chatwerk/mcp'
require 'mcp'

module Chatwerk
  # CLI interface for Chatwerk using Thor
  class CLI < Thor
    desc 'mcp', 'Start the Model Context Protocol server in stdio mode'
    def mcp
      MCP::Server.new(Chatwerk::Mcp.new).serve(MCP::Server::StdioClientConnection.new)
    end

    desc 'version', 'Display Chatwerk version'
    def version
      puts "Chatwerk #{Chatwerk::VERSION}"
    end
    map %w[--version -v] => :version

    def self.exit_on_failure?
      true
    end
  end
end
