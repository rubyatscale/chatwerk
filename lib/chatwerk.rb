# typed: strict
# frozen_string_literal: true

require 'query_packwerk'
require 'sorbet-runtime'

# Chatwerk provides integration between QueryPackwerk and AI tools
# via the Model Context Protocol (MCP) server.
module Chatwerk
  extend T::Sig

  autoload :API, 'chatwerk/api'
  autoload :CLI, 'chatwerk/cli'
  autoload :Helpers, 'chatwerk/helpers'
  autoload :Mcp, 'chatwerk/mcp'
  autoload :Views, 'chatwerk/views'
  autoload :VERSION, 'chatwerk/version'

  class Error < StandardError; end
  class NotFoundError < Error; end
end
