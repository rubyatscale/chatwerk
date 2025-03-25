# Chatwerk

Chatwerk provides AI tool integration for the [QueryPackwerk](https://github.com/rubyatscale/query_packwerk) gem. It adds a Model Context Protocol (MCP) server that allows AI tools like Cursor IDE to access information about your Packwerk packages, dependencies, and violations.

## Installation

Install the gem and add to your application's Gemfile:

```ruby
gem 'chatwerk', group: :development
```

And then execute:

```bash
$ bundle install
```

Or install it yourself:

```bash
$ gem install chatwerk
```

## Usage

### Starting the MCP Server

Start the MCP server in your Rails application directory:

```bash
$ chatwerk_mcp
```

By default, the server runs on port 7531. You can specify a different port:

```bash
$ chatwerk_mcp --port=9000
```

### Connecting with Cursor IDE

To use Chatwerk with Cursor:

1. Start the MCP server in your project directory:
   ```bash
   cd /your/rails/project
   chatwerk_mcp
   ```

2. In Cursor, open Settings > Extensions > Model Context Providers.

3. Add a new MCP connection with the URL: `http://localhost:7531/mcp/context`

4. Now you can ask Cursor questions about your Packwerk structure!

### Example Queries for Cursor

Once connected, you can ask Cursor questions about your Packwerk structure:

- "What are all the packages in this codebase?"
- "Tell me about the dependencies of package X"
- "What packages depend on package Y?"
- "Show me all the violations for package Z"
- "How difficult would it be to separate package X from its dependencies?"
- "What code patterns are used to access package Y?"

## API Reference

Chatwerk provides a structured API for accessing Packwerk information. This API powers the MCP server but can also be used directly in your Ruby code:

```ruby
require 'chatwerk'

# Get detailed information about a package
Chatwerk::API.package_info('packs/my_package')

# Get dependencies of a package
Chatwerk::API.package_dependencies('packs/my_package')

# Find usage locations of a package
Chatwerk::API.find_usage_locations('packs/my_package')

# Assess difficulty of separating a package
Chatwerk::API.assess_separation_difficulty('packs/my_package')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubyatscale/chatwerk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
