# QueryPackwerk MCP Server

The QueryPackwerk MCP (Model Context Protocol) server enables integration with Cursor IDE and other AI tools that support the MCP protocol. This allows you to get information about Packwerk packages and violations directly in your IDE.

## Installation

The MCP server requires additional dependencies. Make sure to install the gem with the development dependencies:

```bash
gem install query_packwerk --development
```

Or in your Gemfile:

```ruby
gem 'query_packwerk', group: :development
```

## Starting the MCP Server

You can start the MCP server using the provided command:

```bash
query_packwerk_mcp
```

By default, the server runs on port 7531. You can specify a different port:

```bash
query_packwerk_mcp --port=9000
```

## Connecting with Cursor

To use QueryPackwerk with Cursor:

1. Start the MCP server in your project directory:
   ```bash
   cd /your/rails/project
   query_packwerk_mcp
   ```

2. In Cursor, open Settings > Extensions > Model Context Providers.

3. Add a new MCP connection with the URL: `http://localhost:7531/mcp/context`

4. Now you can ask Cursor about your packages and violations!

## Example Queries for Cursor

Once connected, you can ask Cursor questions about your Packwerk structure:

- "What are all the packages in this codebase?"
- "Tell me about the dependencies of package X"
- "What packages depend on package Y?"
- "Show me all the violations for package Z"
- "How difficult would it be to separate package X from its dependencies?"
- "What code patterns are used to access package Y?"

## Available API Endpoints

The MCP server also provides a REST API that you can use directly:

- `GET /api/packages` - List all packages
- `GET /api/packages/search?q=query` - Search packages by name/owner
- `GET /api/packages/:name/info` - Get detailed info about a package
- `GET /api/packages/:name/dependencies` - Get dependencies of a package
- `GET /api/packages/:name/consumers` - Get consumers of a package
- `GET /api/packages/:name/usage-patterns` - Get usage patterns of a package
- `GET /api/packages/:name/access-patterns` - Get access patterns with examples
- `GET /api/packages/:name/usage-locations` - Find where a package is used
- `GET /api/packages/:name/separation-difficulty` - Assess difficulty of separating a package

## MCP Protocol Integration

The MCP server supports the following capabilities:

- `packwerk-packages` - Access information about packages
- `packwerk-violations` - Access information about violations

These capabilities are available through the standard MCP context endpoint at `/mcp/context`.
