# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this project is

`chatwerk` provides an MCP (Model Context Protocol) server built on top of [query_packwerk](https://github.com/rubyatscale/query_packwerk). It lets AI coding assistants (Cursor, Claude, etc.) query packwerk package information, dependencies, and violations from a Ruby codebase.

## Commands

```bash
bundle install

# Run all tests (RSpec)
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/spec.rb

# Lint
bundle exec rubocop
bundle exec rubocop -a  # auto-correct
```

## Architecture

- `lib/chatwerk.rb` — entry point; starts the MCP server
- `lib/chatwerk/` — MCP tool definitions that wrap `query_packwerk` queries (e.g. list packs, show violations, show dependencies)
- `spec/` — RSpec tests
