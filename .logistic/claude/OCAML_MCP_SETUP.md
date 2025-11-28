# Setting Up ocaml-mcp for OCaml Type Information

The `ocaml-mcp` server provides Claude Code with direct access to OCaml type information, module signatures, build status, and more. This is essential for effective OCaml development with Claude.

## Installation Steps

1. **Clone the repository:**
   ```bash
   mkdir -p ~/tools
   cd ~/tools
   git clone https://github.com/tmattio/ocaml-mcp.git
   cd ocaml-mcp
   ```

2. **Install dependencies and build:**
   ```bash
   dune pkg lock  # Lock dependencies using Dune package management
   dune build     # Build the project
   dune install   # Install to ~/.local/bin (or your configured opam prefix)
   ```

3. **Verify installation:**
   ```bash
   ~/.local/bin/ocaml-mcp-server --help
   ```

   You should see help output listing available tools and options.

## Configuration in Claude Code

### 1. Add OCaml MCP to global configuration

Add the OCaml MCP server to `~/.claude/mcp.json`. If the file doesn't exist, create it:

```json
{
  "mcpServers": {
    "ocaml-mcp": {
      "type": "stdio",
      "command": "/home/YOUR_USERNAME/.local/bin/ocaml-mcp-server",
      "args": [
        "--stdio",
        "--dune"
      ]
    }
  },
  "permissions": {
    "allow": [
      "mcp__ocaml-mcp__*"
    ]
  }
}
```

**Important:**
- Replace `YOUR_USERNAME` with your actual username (e.g., `/home/bnguyenv/.local/bin/ocaml-mcp-server`)
- The `--dune` flag enables Dune RPC integration for build status and diagnostics
- The `--root` argument is omitted so the server auto-detects the project root from the current working directory
- If you already have MCP servers configured in `mcp.json`, add the `"ocaml-mcp"` entry to the existing `"mcpServers"` object and merge the permissions without removing other entries

### 2. Restart Claude Code

Exit Claude Code completely and restart it. The MCP server will now be available for all your OCaml projects.

### 3. Project-specific overrides (optional)

If a specific project needs different MCP configuration, you can create a `.mcp.json` file in that project's root directory. Project-specific configurations override the global configuration.

## Available Tools

Once configured, Claude will have access to these tools:

### Type Information & Navigation
- **`mcp__ocaml-mcp__ocaml_type_at_pos`** - Get type information at a specific file location
  - Parameters: `file_path`, `line`, `column`
  - Returns the inferred or declared type at that position

- **`mcp__ocaml-mcp__ocaml_find_definition`** - Find where a symbol is defined
  - Parameters: `file_path`, `line`, `column`
  - Jumps to the definition of the symbol under the cursor

- **`mcp__ocaml-mcp__ocaml_find_references`** - Find all references to a symbol
  - Parameters: `file_path`, `line`, `column`
  - Lists all locations where the symbol is used

- **`mcp__ocaml-mcp__ocaml_module_signature`** - Get module signatures
  - Parameters: `module_path` (array of strings like `["Lib", "Module"]`)
  - Returns the signature from compiled artifacts

- **`mcp__ocaml-mcp__ocaml_project_structure`** - Inspect project layout
  - Returns information about libraries, executables, and dependencies

### Build System Integration
- **`mcp__ocaml-mcp__dune_build_status`** - Get current build status
  - Parameters: `targets` (optional array of targets)
  - Returns build status with errors and warnings

- **`mcp__ocaml-mcp__dune_build_target`** - Build specific targets
  - Parameters: `targets` (array of target names)
  - Builds the specified targets and returns results

- **`mcp__ocaml-mcp__dune_run_tests`** - Run tests
  - Parameters: `test_names` (optional array of test names)
  - Executes tests and reports results

### File Operations with OCaml Awareness
- **`mcp__ocaml-mcp__fs_edit`** - Edit files with automatic formatting
  - Parameters: `file_path`, `old_string`, `new_string`
  - For OCaml files, automatically runs ocamlformat and returns diagnostics

- **`mcp__ocaml-mcp__fs_write`** - Write files with automatic formatting
  - Parameters: `file_path`, `content`
  - For OCaml files, automatically formats and validates syntax

## Usage Notes

### Getting Type Information

**Before querying types, build your project:**
```bash
dune build
```

The ocaml-mcp server reads type information from compiled artifacts (`.cmt`, `.cmti` files). If the project hasn't been built, or if there are compilation errors, type information may be incomplete or unavailable.

### Workflow Example

```ocaml
(* You're working on this function and want to know types *)
let process_data items =
  let result = List.map transform items in
  result
```

Claude can use `mcp__ocaml-mcp__ocaml_type_at_pos` to query:
- What is the type of `items`?
- What is the type of `transform`?
- What is the type of `result`?

This eliminates the need to add type annotations everywhere just to understand your code.

### Build Errors

Files with build errors may not have complete type information. Use `mcp__ocaml-mcp__dune_build_status` to check for errors first, fix them, rebuild, then query types.

### Performance

The MCP server is fast for most operations. Type queries are nearly instantaneous since they read from already-compiled artifacts. Building targets may take longer depending on project size.

## Troubleshooting

### "File not found" errors
- Make sure you're using relative paths from the project root
- Example: `lib/src/module.ml`, not `/absolute/path/to/lib/src/module.ml`

### No type information available
- Run `dune build` to ensure artifacts are up-to-date
- Check that the file compiles without errors
- Verify you're in the correct project directory (the server auto-detects the project root from your current working directory)

### MCP server not loading
- Check that `~/.local/bin/ocaml-mcp-server` exists and is executable
- Verify `~/.claude/mcp.json` has correct JSON syntax
- Check that the permissions section includes `"mcp__ocaml-mcp__*"`
- Restart Claude Code completely

### Build status shows "waiting"
- The Dune RPC connection may not be established yet
- Try running `dune build` manually first
- Check that the `--dune` flag is present in `~/.claude/mcp.json`

## Using PATH instead of absolute path

If `~/.local/bin` is in your PATH, you can simplify the command in `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "ocaml-mcp": {
      "type": "stdio",
      "command": "ocaml-mcp-server",
      "args": ["--stdio", "--dune"]
    }
  },
  "permissions": {
    "allow": [
      "mcp__ocaml-mcp__*"
    ]
  }
}
```

This uses `ocaml-mcp-server` from PATH instead of the full path.

## Benefits

Using ocaml-mcp with Claude Code provides:

- **Instant type information** without cluttering code with annotations
- **Jump to definition** to understand how modules work
- **Find all references** to see where functions are used
- **Build integration** to catch errors early
- **Smart file editing** with automatic formatting

This makes Claude a much more effective OCaml development assistant!
