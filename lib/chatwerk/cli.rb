# typed: false
# frozen_string_literal: true

require 'thor'
require 'chatwerk'
require 'chatwerk/mcp'
require 'chatwerk/api'
require 'mcp'

module Chatwerk
  # CLI interface for Chatwerk using Thor
  class CLI < Thor
    desc 'mcp', 'Start the Model Context Protocol server in stdio mode'
    def mcp
      MCP::Server.new(Chatwerk::Mcp.new).serve(MCP::Server::StdioClientConnection.new)
    end

    desc 'inspect [WORKING_DIRECTORY]', 'Run the MCP inspector with an optional working directory path (defaults to current directory)'
    def inspect(working_directory = nil)
      pwd = working_directory || Dir.pwd
      system("npx @modelcontextprotocol/inspector -e PWD=#{pwd} bundle exec exe/chatwerk mcp")
    end

    desc 'print_env', 'Show current environment details'
    def print_env
      puts API.print_env
    end

    desc 'packages [PACKAGE_PATH]', 'List all valid packwerk packages, optionally filtered by package path'
    def packages(package_path = nil)
      puts API.packages(package_path)
    end

    desc 'package PACKAGE_PATH', 'Show details for a specific package'
    def package(package_path)
      puts API.package(package_path)
    end

    desc 'package_todos PACKAGE_PATH [CONSTANT_NAME]', 'Show dependency violations FROM this package TO others'
    def package_todos(package_path, constant_name = nil)
      puts API.package_todos(package_path, constant_name)
    end

    desc 'package_violations PACKAGE_PATH [CONSTANT_NAME]', 'Show dependency violations TO this package FROM others'
    def package_violations(package_path, constant_name = nil)
      puts API.package_violations(package_path, constant_name)
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
