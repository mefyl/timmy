# Team-Level Claude Code Instructions

This file contains development guidelines that apply across all projects in this directory.

## OCaml Type-Driven Development Workflow

**CRITICAL**: When working with OCaml modules that have signatures (`.mli` files), follow this workflow:

### 1. Signature First, Implementation Second

When adding new functions to a module with a `.mli`, ALWAYS add the signature to the `.mli` file FIRST:

- Define the function signature in the `.mli` file
- Use stub implementations (`failwith "TODO: implement function_name"`) in the `.ml` file to make everything compile
- Only implement the real functionality after the signature is correct everywhere
- **Never** write implementations in `.ml` without first defining the signature in `.mli`

**Why:** The signature is the contract. Define the contract first, then fulfill it. This prevents type inference from guessing the wrong thing and makes refactoring much easier.

### 2. Getting Type Information

**FIRST: Use the ocaml-mcp tools to query type information**

When you need to understand what type something has:

- **DO:** Use `mcp__ocaml-mcp__ocaml_type_at_pos` to get the type at a specific location
- This works after running `dune build` to ensure artifacts are up-to-date
- Use `mcp__ocaml-mcp__ocaml_find_definition` to jump to where symbols are defined
- Use `mcp__ocaml-mcp__dune_build_status` to check for compilation errors

**ONLY WHEN NEEDED: Add type annotations to localize errors**

When you encounter type errors you don't understand or need to narrow down where the issue is:

- **DO:** Add type annotations at the call site reflecting what you EXPECT the types to be
- Use abstract types from module signatures (not their expansions)
- Let the compiler show you exactly where your expectations differ from reality
- Read the error message carefully - it tells you precisely what's wrong

- **DON'T:** Try to manually reason through complex type unification
- Don't guess at fixes without understanding the actual type mismatch
- Don't remove type annotations when they cause errors (they're revealing the problem!)

**Why:** The ocaml-mcp server gives you immediate access to type information from compiled artifacts. Type annotations are still useful as "checkpoints" to localize where type mismatches occur, but you should query the MCP server first to understand what types you're actually working with.

### 3. Iterate on Types with Stubs

The recommended workflow when designing new functions:

```ocaml
(* Step 1: Add to .mli with your desired signature *)
val my_function : input -> output

(* Step 2: Add stub to .ml *)
let my_function input = failwith "TODO: implement my_function"

(* Step 3: Use it at call sites with type annotations *)
let result : expected_type = my_function my_input

(* Step 4: If you get type errors, revise the signature in .mli *)
val my_function : better_input -> better_output

(* Step 5: Once types are right everywhere, implement for real *)
let my_function input = (* actual implementation *)
```

**Why:** This workflow separates concerns - first get the API right, then implement it. It's much easier to change a `failwith` stub than to refactor a full implementation.

### 4. Query Types First, Annotate When Localizing Errors

**Preferred approach - Query the MCP server:**
```ocaml
let process_deltas deltas =
  (* First, use mcp__ocaml-mcp__ocaml_type_at_pos to understand what types you have *)
  let pattern = Map.Pattern.add __ ignore in
  match_list pattern deltas ()
```

**When debugging type errors - Add annotations to localize:**
```ocaml
let process_deltas deltas =
  (* Add annotation to narrow down where the type error occurs *)
  let pattern : (Delta.t, unit, result) Pattern.t =
    Map.Pattern.add __ ignore
  in
  (* If this causes an error, you know the problem is in this binding *)
  match_list pattern deltas ()
```

**Why:** Use the MCP server to understand types interactively without cluttering code. Add annotations strategically when you need to pinpoint exactly where a type mismatch occurs.

## OCaml Code Style Guidelines

### Sequencing Expressions
- **Always use** `let () = a in b` instead of `a ; b` for sequencing
- Makes intent explicit and avoids type inference issues

### Custom Let Operators
- Prefer custom let operators for applicative/monadic patterns
- Examples:
  - `let*` for monads
  - `let+` for functors/applicatives
  - `let*!` for `('a, 'err) Result.t Monad.t` (e.g., `Result.t Lwt.t`)
- Makes control flow clear and reduces nesting

### Module Documentation
- **Always add `.mli` files** for modules you create
- Include docstrings for all public functions using `(** *)` style comments
- Document parameters, return values, and any side effects

### Data Structure Design
- **If a tuple has 3+ elements, use a record type instead**
- This applies to both standalone values and variant constructors
- Use inline record syntax for variants:
  ```ocaml
  (* Bad - positional arguments are error-prone *)
  | Constructor of string * int * bool * float

  (* Good - named fields are self-documenting *)
  | Constructor of {
      name : string;
      count : int;
      enabled : bool;
      threshold : float;
    }
  ```

**Why:** Named fields make code self-documenting, easier to refactor (can add fields without breaking all call sites), and prevent subtle bugs from swapping arguments.

### Error Handling: Never Use `_exn` Functions

**DO NOT use `_exn` functions** (like `List.hd_exn`, `Map.of_sequence_exn`, `Option.value_exn`).

- Use `Result.t` or `Option.t` to propagate errors explicitly
- Use `_reduce` variants with error logging when handling duplicates:
  ```ocaml
  Map.of_sequence_reduce (module String) ~f:(fun first second ->
      Logs.err (fun m -> m "duplicate: %s" key);
      first)
  ```
- **Only exception**: When the code structure guarantees the precondition holds (rare)

**Why:** `_exn` functions crash at runtime. Explicit error handling makes failures visible in types.

## General Principles

### Work with Module Signatures

- When working with modules, always refer to the `.mli` file first
- The abstract types defined in the interface are what you should use in annotations
- Don't try to work with concrete implementation types unless absolutely necessary

### Let the Type System Help You

- OCaml's type system is one of its greatest strengths
- Type errors are your friend - they prevent runtime bugs
- The more precise your types, the more the compiler can help you
- When refactoring, let type errors guide you to all the places that need changes

## Build Process

### Using Dune

- **ALWAYS** use `dune build` to build the project
- **NEVER** run `dune clean` - rely on the incremental build process
- **NEVER** try to remove `_build/.lock` manually
- **NEVER** run `dune runtest` - use `dune build @runtest` instead since a build daemon is running and holds the lock
- The build system has a running watch process that handles incremental compilation
- Just call `dune build` and let it handle everything
- After editing code, run `dune build @fmt || dune promote` to format it correctly and pass CI

**Why:** The project uses a persistent build watcher that maintains incremental build state. Cleaning or removing locks disrupts this process and wastes time.

## Summary

**The golden rule: Signature → Stub → Query Types (via MCP) → Implement**

This approach will save time, reduce bugs, and make code easier to maintain. Use `mcp__ocaml-mcp__ocaml_type_at_pos` to understand types interactively without cluttering code. Add type annotations strategically only when you need to localize where type errors occur.

**For setting up ocaml-mcp**, see `~/.claude/OCAML_MCP_SETUP.md` for detailed installation and configuration instructions.
