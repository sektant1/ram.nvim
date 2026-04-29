# ram.nvim

Quick-note buffer. Always there. Zero friction.

Two notes:
- **global** — one note, everywhere
- **project** — one note per project root

Files on disk. No state loss.

## Install (lazy.nvim)

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

## Keys

| key | does |
|---|---|
| `<leader>rg` | open global |
| `<leader>rp` | open project |
| `<leader>rv` | toggle preview |
| `<leader>rx` | close |
| `q` (in buf) | close |

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
    global = "<leader>rg", project = "<leader>rp",
    preview = "<leader>rv", close = "<leader>rx",
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
1. `render-markdown.nvim` — toggle in-buffer
2. `glow` CLI — terminal split
3. native markdown syntax — fallback

No hard deps. Pick none = still works.

## Health

```
:checkhealth ram
```

## License

MIT.
