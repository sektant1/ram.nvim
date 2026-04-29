# ram.nvim

Persistent quick-note buffer for Neovim. Always loaded, always accessible, zero friction.

## Why RAM

Two notes, one keystroke away:

- **Global** — one note shared across every session
- **Project** — one note scoped to the current working directory

Files persist on disk. Open, type, close, reopen later. No state loss.

## Features

- Configurable display: `float` (default), `split`, `vsplit`, `tab`
- Toggle behavior — reopening the same note closes it
- Autosave on `BufLeave`
- Cursor restored per note on reopen
- Optional markdown preview via `render-markdown.nvim` or `glow` (graceful fallback)
- No required external dependencies
- Lazy-load friendly (`keys = {}`)

## Install (lazy.nvim)

```lua
{
  "gfe/ram.nvim",
  opts = {},
  keys = {
    { "<leader>rg", function() require("ram").global() end,  desc = "Ram: global note" },
    { "<leader>rp", function() require("ram").project() end, desc = "Ram: project note" },
    { "<leader>rv", function() require("ram").preview() end, desc = "Ram: preview" },
    { "<leader>rx", function() require("ram").close() end,   desc = "Ram: close" },
  },
  cmd = { "RamGlobal", "RamProject", "RamPreview", "RamClose" },
}
```

## Usage

| Mapping        | Action                       |
| -------------- | ---------------------------- |
| `<leader>rg`   | open global note             |
| `<leader>rp`   | open project note            |
| `<leader>rv`   | preview current note         |
| `<leader>rx`   | close ram window             |
| `q` (in buf)   | close ram (buffer-local)     |

## Configuration

Defaults:

```lua
require("ram").setup({
  display = "float",           -- "float"|"split"|"vsplit"|"tab"
  float = {
    width = 0.6,
    height = 0.7,
    border = "rounded",
    title = " RAM ",
  },
  global_note_path = nil,      -- override default path
  project_note_filename = ".project-notes.md",
  project_root_markers = {     -- walk up cwd to find project root
    ".git", ".hg", ".svn",
    "package.json", "Cargo.toml", "pyproject.toml", "go.mod",
    "Makefile", ".project-notes.md",
  },
  keymaps = {
    global = "<leader>rg",
    project = "<leader>rp",
    preview = "<leader>rv",
    close = "<leader>rx",
  },
  filetype = "markdown",
  autosave = true,
  commands = true,
})
```

Storage paths:

- Global: `vim.fn.stdpath("data") .. "/ram/global.md"` (or `global_note_path`)
- Project: `<project_root>/<project_note_filename>` — root is found by walking up the cwd matching any `project_root_markers` (falls back to cwd). Set `project_root_markers = {}` to force strict cwd.

Set any keymap to `false` to disable it.

## Commands

- `:RamGlobal` — open global note
- `:RamProject` — open project note
- `:RamPreview` — toggle preview
- `:RamClose` — close ram window

## Preview backends

Detected at preview time, in order:

1. [`render-markdown.nvim`](https://github.com/MeanderingProgrammer/render-markdown.nvim) — toggled in-buffer
2. `glow` CLI — opens a terminal split rendering the note
3. Native vim markdown syntax — fallback, notified once

## Health

```
:checkhealth ram
```

Reports Neovim version, config load, note paths, and preview backend status.

## License

MIT — see [LICENSE](./LICENSE).
