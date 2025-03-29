# Chatwerk

Chatwerk provides AI tool integration for the [QueryPackwerk](https://github.com/rubyatscale/query_packwerk) gem. It adds a Model Context Protocol (MCP) server that allows AI tools like Cursor IDE to access information about your Packwerk packages, dependencies, and violations.

## Installation

Install the gem, either add in to your packwerk'd application's Gemfile:

```ruby
$ bundle add chatwerk
$ bundle install
```

or install it on its own:

```bash
$ gem install chatwerk
```

## Usage

### Starting the MCP Server

You can test the inspector to see if it's working

```bash
$ chatwerk inspect
```

### Connecting with Cursor IDE

To use Chatwerk with Cursor:

1. In Cursor, open Settings > MCP

2. Add a new MCP connection as a command
   Name: `chatwerk`
   Command: `chatwerk mcp`

3. Ask Cursor to check all the tools on packwerk. Give it an example pack name (partial strings work)

### Example Queries for Cursor

Once connected, you can ask Cursor questions about your Packwerk structure:

- "What are all the packages in this codebase?"
- "Tell me about the dependencies of package X"
- "What packages depend on package Y?"
- "Show me all the violations for package Z"
- "How difficult would it be to separate package X from its dependencies?"
- "What code patterns are used to access Constant on package Y?"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

Run `bin/inspect`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubyatscale/chatwerk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
