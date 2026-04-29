<div align="center">

<img src="assets/logo.png" alt="ram.nvim logo" width="180" />

# ram.nvim

(Ready Access Markdown)

[![Neovim](https://img.shields.io/badge/Neovim-0.10+-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License: MIT](https://img.shields.io/github/license/sektant1/ram.nvim)](./LICENSE)
[![Stars](https://img.shields.io/github/stars/sektant1/ram.nvim?style=social)](https://github.com/sektant1/ram.nvim/stargazers)
[![Issues](https://img.shields.io/github/issues/sektant1/ram.nvim)](https://github.com/sektant1/ram.nvim/issues)

<img src="assets/demo.gif" alt="ram.nvim demo" width="720" />

</div>

---

Two notes:
- **global**  one note, everywhere
- **project**  one note per project root

Files on disk. No state loss.

## Install

### lazy.nvim

```lua
{
  "sektant1/ram.nvim",
  opts = {},
  keys = {
    { "<leader>rg", function() require("ram").global() end,  desc = "Ram global" },
    { "<leader>rp", function() require("ram").project() end, desc = "Ram project" },
    { "<leader>rv", function() require("ram").preview() end, desc = "Ram preview" },
    { "<leader>rx", function() require("ram").close() end,   desc = "Ram close" },
  },
  cmd = { "RamGlobal", "RamProject", "RamPreview", "RamClose" },
}
```

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({ "https://github.com/sektant1/ram.nvim" })
require("ram").setup({})
```

## Keys

No defaults. Bind whatever you want via lazy `keys = {}` (see install snippet) or `setup({ keymaps = { ... } })`.

Inside a ram buffer: `q` closes (buffer-local).

Reopen same note = close. Different note = swap.

## Where files live

- global: `stdpath("data")/ram/global.md`
- project: `<project_root>/.project-notes.md`

Project root = walk up cwd, find `.git` / `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `Makefile`. None? Use cwd.

## Config (defaults)

```lua
require("ram").setup({
  display = "float",  -- float | split | vsplit | tab
  float = { width = 0.6, height = 0.7, border = "rounded", title = " RAM " },
  global_note_path = nil,
  project_note_filename = ".project-notes.md",
  project_root_markers = {
    ".git", ".hg", ".svn",
    "package.json", "Cargo.toml", "pyproject.toml", "go.mod",
    "Makefile", ".project-notes.md",
  },
  keymaps = {
    -- no defaults — set explicitly or use lazy `keys = {}`
    global = false,   -- e.g. "<leader>rg"
    project = false,  -- e.g. "<leader>rp"
    preview = false,  -- e.g. "<leader>rv"
    close = false,    -- e.g. "<leader>rx"
  },
  filetype = "markdown",
  autosave = true,
  commands = true,
})
```

Any keymap = `false` to disable. `project_root_markers = {}` = strict cwd.

## Commands

`:RamGlobal` `:RamProject` `:RamPreview` `:RamClose`

## Preview

Tries in order:
1. `render-markdown.nvim` toggle in-buffer
2. `glow` CLI terminal split
3. native markdown syntax fallback

No hard deps.

## Health

```
:checkhealth ram
```

## License

MIT.
