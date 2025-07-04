# typed: strict
# frozen_string_literal: true

require 'zeitwerk'
require 'query_packwerk'
require 'sorbet-runtime'
require 'chatwerk/version'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Chatwerk provides integration between QueryPackwerk and AI tools
# via the Model Context Protocol (MCP) server.
module Chatwerk
  class NotFoundError < Error; end
end
