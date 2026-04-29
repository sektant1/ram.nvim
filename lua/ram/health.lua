local M = {}

local function h()
  return vim.health
end

local function file_exists(path)
  local uv = vim.uv or vim.loop
  return uv.fs_stat(path) ~= nil
end

function M.check()
  local health = h()
  health.start("ram.nvim")

  if vim.fn.has("nvim-0.10") == 1 then
    health.ok("Neovim >= 0.10")
  else
    health.error("Neovim 0.10+ required")
  end

  local ok_cfg, config = pcall(require, "ram.config")
  if not ok_cfg or not config.options then
    health.error("ram.config failed to load")
    return
  end
  health.ok("config loaded (display = " .. tostring(config.options.display) .. ")")

  health.start("ram.nvim: notes")
  local ok_notes, notes = pcall(require, "ram.notes")
  if not ok_notes then
    health.error("ram.notes failed to load")
  else
    local g = notes.global_path()
    health.info("global note: " .. g .. (file_exists(g) and " (exists)" or " (will be created)"))
    local root = notes.project_root()
    local p = notes.project_path()
    health.info("cwd: " .. vim.fn.getcwd())
    health.info("project root: " .. root)
    health.info("project note: " .. p .. (file_exists(p) and " (exists)" or " (will be created)"))
  end

  health.start("ram.nvim: keymaps")
  local km = config.options.keymaps or {}
  local any = false
  for _, k in ipairs({ "global", "project", "close" }) do
    if km[k] then
      health.ok(k .. " -> " .. tostring(km[k]))
      any = true
    end
  end
  if not any then
    health.info("no keymaps set in config — bind via your plugin manager or setup({ keymaps = ... })")
  end
end

return M
