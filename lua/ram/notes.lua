local config = require("ram.config")

local M = {}

local uv = vim.uv or vim.loop

---@param path string
---@return boolean
local function exists(path)
  return uv.fs_stat(path) ~= nil
end

---@param path string
local function dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

---Ensure file exists at `path` with `header` if missing. Creates parent dirs.
---Returns true on success, false + reason on failure.
---@param path string
---@param header string
---@return boolean ok
---@return string? err
function M.ensure(path, header)
  local dir = dirname(path)
  if not exists(dir) then
    local ok = pcall(vim.fn.mkdir, dir, "p")
    if not ok or not exists(dir) then
      return false, "cannot create directory: " .. dir
    end
  end
  if not exists(path) then
    local fh, ferr = io.open(path, "w")
    if not fh then
      return false, "cannot create file: " .. path .. " (" .. tostring(ferr) .. ")"
    end
    fh:write(header)
    fh:close()
  end
  return true
end

local function notify_err(msg)
  vim.notify("ram.nvim: " .. msg, vim.log.levels.ERROR)
end

---@return string
function M.global_path()
  return config.options.global_note_path or (vim.fn.stdpath("data") .. "/ram/global.md")
end

---Walk up from `start` looking for any of `markers`. Returns the directory
---containing the first marker, or nil if none found.
---@param start string
---@param markers string[]
---@return string?
function M.find_root(start, markers)
  local found = vim.fs.find(markers, { upward = true, path = start, limit = 1 })
  if found and found[1] then
    return vim.fs.dirname(found[1])
  end
  return nil
end

---Resolve the project root for the cwd.
---Returns cwd if `project_root_markers` is empty (strict-cwd mode).
---Returns nil if markers are configured but none are found upward.
---@return string?
function M.project_root()
  local cwd = vim.fn.getcwd()
  local markers = config.options.project_root_markers or {}
  if #markers == 0 then
    return cwd
  end
  return M.find_root(cwd, markers)
end

---@return string?
function M.project_path()
  local root = M.project_root()
  if not root then
    return nil
  end
  return root .. "/" .. config.options.project_note_filename
end

---@return string|nil path nil if creation failed
function M.global()
  local p = M.global_path()
  local ok, err = M.ensure(p, "# RAM\n\n")
  if not ok then
    notify_err(err)
    return nil
  end
  return p
end

---@return string|nil path nil if creation failed or no project root
function M.project()
  local root = M.project_root()
  if not root then
    notify_err(
      "no project root found from "
        .. vim.fn.getcwd()
        .. " — set `project_root_markers = {}` for strict cwd, or create one of: "
        .. table.concat(config.options.project_root_markers or {}, ", ")
    )
    return nil
  end
  local p = root .. "/" .. config.options.project_note_filename
  local name = vim.fn.fnamemodify(root, ":t")
  local ok, err = M.ensure(p, "# " .. name .. " notes\n\n")
  if not ok then
    notify_err(err)
    return nil
  end
  return p
end

return M
