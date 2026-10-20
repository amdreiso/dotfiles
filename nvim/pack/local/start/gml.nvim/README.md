# gml.nvim

Scope-aware syntax highlighting for GameMaker Language (GML) in Neovim.
No tree-sitter parser needed: a small tokenizer plus a scope pass classify every token and
apply highlights with extmarks.

Requires Neovim 0.9+.

## What gets highlighted

| Group | What it covers |
|---|---|
| `GmlKeyword` | `if else for var static function new return self other global ...` |
| `GmlConstant` | `true false undefined noone all pi NaN infinity pointer_null` |
| `GmlLocalVariable` | names declared with `var` / `catch (e)`, scoped per function and per `@event` block |
| `GmlParameter` | function parameters (links to `GmlLocalVariable` by default) |
| `GmlStaticVariable` | `static` declarations (links to `GmlLocalVariable`) |
| `GmlVariable` | any other bare identifier, i.e. instance variables |
| `GmlProperty` | `thing.member`, struct literal keys |
| `GmlGlobalVariable` | `global.name`, `globalvar` names |
| `GmlFunction` | calls to functions nothing else claims |
| `GmlMethod` | `thing.method(...)` |
| `GmlProjectFunction` | functions declared in your project (scanned from `scripts/` etc.) |
| `GmlBuiltinFunction` | `draw_text`, `ds_list_add`, `instance_create_layer`, ... (by prefix) |
| `GmlFunctionDecl` | the name in `function name(...)` |
| `GmlConstructor` | `new Foo(...)`, `: Parent(...)`, constructors in your project |
| `GmlEnumName` / `GmlEnumValue` | enums declared in the project; `Enum.Value` |
| `GmlMacro` | `#macro` names, declared here or anywhere in the project |
| `GmlAsset` | sprite / object / sound / room names taken from the project folders |
| `GmlBuiltinVariable` | `x y speed image_index room_width mouse_x argument0 ...` |
| `GmlBuiltinConstant` | `c_red vk_space mb_left fa_center bm_add buffer_u8 ...` |
| `GmlNumber`, `GmlString`, `GmlEscape`, `GmlTemplateDelim` | literals, incl. `$"template {x}"`, `@"verbatim"`, `$FF`, `0xFF`, `0b101` |
| `GmlComment`, `GmlDocComment`, `GmlDocTag` | `//`, `/* */`, `/// @param` |
| `GmlPreproc`, `GmlRegion` | `#macro`, `#region`, `#endregion` and the region label |
| `GmlID` | `@create`-style event header lines (glim-style single-file objects) |

## Install

lazy.nvim, from a local checkout:

```lua
{
  dir = "~/path/to/gml.nvim",
  ft = "gml",
  opts = { ... }, -- see below
}
```

Or drop the folder into `~/.config/nvim/pack/local/start/gml.nvim`.
It works with no configuration at all.

## Configuration

```lua
require("gml").setup({
  priority = 120,
  debounce = 60,
  highlights = {
    GmlVariable        = { fg = "#b2b1ff" },  -- instance variables, properties, globals
    GmlLocalVariable   = { fg = "#ffff88" },  -- locals, parameters, statics
    GmlKeyword         = { fg = "#ffb871", bold = true },
    GmlFunction        = { fg = "#ffb871" },  -- also method / project / builtin by default
    GmlNumber          = { fg = "#ff8080" },
    GmlConstant        = { fg = "#ff8080" },
    GmlEnumName        = { fg = "#ff8080" },
    GmlEnumValue       = { fg = "#ff8080" },
    GmlMacro           = { fg = "#ff8080" },
    GmlBuiltinConstant = { fg = "#ff8080" },
    GmlComment         = { fg = "#5b995b" },
    GmlString          = { fg = "#ffff00" },
    GmlID              = { fg = "#7777ff", bold = true, bg = "NONE" },
    -- split user functions from builtins if you like:
    -- GmlBuiltinFunction = { fg = "#ffd9a8" },
  },
  project = {
    source_dirs = { "objects", "scripts", "rooms" },  -- scanned for functions/enums/macros
    asset_dirs  = { "objects", "sprites", "sounds", "rooms", "scripts" },
  },
  builtins = {         -- extend the built-in heuristics (extensions, etc.)
    functions = {},
    function_prefixes = {},   -- e.g. { "steam" }
    constant_prefixes = {},   -- e.g. { "my_ext_" }
  },
})
```

Highlight values are either a table for `nvim_set_hl` or the name of a group to link to.
They are re-applied after `:colorscheme`.

## Project detection

A buffer belongs to a project when a parent directory contains `objects/` and `scripts/`,
a `.gm` directory, or a `*.yyp` file. The project is indexed incrementally (only changed files are
re-read) and refreshed on save, on focus gain, and with `:GmlRefresh`.

## Commands

- `:GmlRefresh` re-scan the project and re-highlight everything
- `:GmlInspect` show how the token under the cursor was classified, and which group it uses

## Notes and limits

- Locals are resolved per function body and per `@event` block. Nested functions do not see the
  locals of the enclosing function (that matches GML).
- A bare identifier that is not a local, parameter, project symbol or builtin is treated as an
  instance variable.
- Built-in functions are recognised by prefix (`draw_`, `ds_`, `array_`, ...), so new runtime
  functions work without updating the plugin; prefix guessing can be wrong for user-defined
  things that share a prefix. Project functions always win over the guess.
- Remove the old `syntax keyword` / `syntax match` autocmd and the enum-scanning code from your
  config; this plugin replaces them. Folding, indent, statusline and keymaps are untouched.
