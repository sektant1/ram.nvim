---@class RamFloatConfig
---@field width number Fraction of editor columns (0..1)
---@field height number Fraction of editor lines (0..1)
---@field border string|string[] Any nvim border spec
---@field title string Float window title

---@class RamKeymaps
---@field global string|false
---@field project string|false
---@field preview string|false
---@field close string|false

---@class RamConfig
---@field display "float"|"split"|"vsplit"|"tab"
---@field float RamFloatConfig
---@field global_note_path string|nil
---@field project_note_filename string
---@field project_root_markers string[]
---@field keymaps RamKeymaps
---@field filetype string
---@field autosave boolean
---@field commands boolean

local M = {}

---@type RamConfig
M.defaults = {
  display = "float",
  float = {
    width = 0.6,
    height = 0.7,
    border = "rounded",
    title = " RAM ",
  },
  global_note_path = nil,
  project_note_filename = ".project-notes.md",
  project_root_markers = {
    ".git",
    ".hg",
    ".svn",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "go.mod",
    "Makefile",
    ".project-notes.md",
  },
  keymaps = {
    global = false,
    project = false,
    preview = false,
    close = false,
  },
  filetype = "markdown",
  autosave = true,
  commands = true,
}

---@type RamConfig
M.options = vim.deepcopy(M.defaults)

---Merge user opts into defaults. Idempotent.
---@param user table|nil
---@return RamConfig
function M.setup(user)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user or {})
  return M.options
end

return M
