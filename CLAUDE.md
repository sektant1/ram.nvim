You are a master Neovim plugin developer, software architect, and product designer.

## MISSION
Build `ram.nvim` — a persistent quick-note buffer accessible from anywhere in Neovim.
Named RAM: always loaded, always accessible, zero friction.

## CORE CONCEPT
Two note contexts:
1. **Global note** (~/.config/nvim/ram/global.md) — one note, accessible everywhere
2. **Project note** (./.project-notes.md at cwd) — scoped to current working directory

## ARCHITECTURE REQUIREMENTS

### Storage
- Global note: `vim.fn.stdpath("data") .. "/ram/global.md"` (auto-create dir)
- Project note: `vim.fn.getcwd() .. "/.project-notes.md"` (or .txt, configurable)
- Files persist on disk — no state loss on exit

### Display Modes (configurable)
- `float` (default) — centered floating window with border
- `split` — horizontal split
- `vsplit` — vertical split
- `tab` — new tab

### Keybinds (default, all overridable)
- `<leader>rg` — open global note
- `<leader>rp` — open project note
- `<leader>rv` — preview current note (render markdown)
- `<leader>rx` — close ram buffer

### Preview
- Use `render-markdown.nvim` if available, fallback to `glow` CLI, fallback to native
  vim markdown syntax — detect and degrade gracefully. No hard deps.

## FILE STRUCTURE

```
ram.nvim/
├── lua/
│   └── ram/
│       ├── init.lua        -- setup(), public API
│       ├── config.lua      -- defaults + merge
│       ├── buffer.lua      -- open/close/toggle buffer logic
│       ├── notes.lua       -- file I/O, path resolution
│       └── preview.lua     -- preview detection + rendering
├── plugin/
│   └── ram.lua             -- lazy-load entrypoint, register cmds
├── doc/
│   └── ram.txt             -- vimdoc
└── README.md
```

## CONFIG SCHEMA
```lua
require("ram").setup({
  display = "float",           -- "float"|"split"|"vsplit"|"tab"
  float = {
    width = 0.6,               -- % of editor width
    height = 0.7,
    border = "rounded",        -- any nvim border style
    title = " RAM ",
  },
  global_note_path = nil,      -- override default path
  project_note_filename = ".project-notes.md",
  keymaps = {
    global = "<leader>rg",
    project = "<leader>rp",
    preview = "<leader>rv",
    close = "<leader>rx",
  },
  filetype = "markdown",       -- buffer filetype
  autosave = true,             -- save on buffer leave
  commands = true,             -- register :Ram* user commands
})
```

## COMMANDS (when commands=true)
- `:RamGlobal` — open global note
- `:RamProject` — open project note
- `:RamPreview` — preview
- `:RamClose` — close

## BEHAVIOR RULES
- Toggle: calling open on an already-open RAM buffer closes it
- Autosave: `BufLeave` autocmd writes file if modified
- If project note doesn't exist, create it with a header `# <dirname> notes\n\n`
- If global note doesn't exist, create it with `# RAM\n\n`
- Single buffer instance — don't duplicate windows
- `q` inside RAM buffer closes it (like a quickfix feel)
- Cursor restores to previous position on reopen

## CODE QUALITY
- Full Lua idioms, no vimscript
- No required external dependencies (preview is optional enhancement)
- Works with lazy.nvim `keys = {}` lazy-loading
- All public functions documented with LuaLS annotations (`---@param`, `---@return`)
- Include a `health.lua` for `:checkhealth ram`

## DELIVERABLE
Complete, working plugin. Every file. README with lazy.nvim install snippet.
Start with `lua/ram/config.lua` → `notes.lua` → `buffer.lua` → `preview.lua` → `init.lua` → `plugin/ram.lua` → `doc/ram.txt` → `README.md`.
