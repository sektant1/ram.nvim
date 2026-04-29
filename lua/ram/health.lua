local M = {}

local function h()
  return vim.health or require("health")
end

function M.check()
  local health = h()
  health.start("ram.nvim")

  if vim.fn.has("nvim-0.10") == 1 then
    health.ok("Neovim >= 0.10")
  else
    health.warn("Neovim < 0.10 — some APIs may be missing")
  end

  local ok_cfg, config = pcall(require, "ram.config")
  if ok_cfg and config.options then
    health.ok("config loaded (display = " .. tostring(config.options.display) .. ")")
  else
    health.error("config failed to load")
    return
  end

  local ok_notes, notes = pcall(require, "ram.notes")
  if ok_notes then
    local g = notes.global_path()
    local p = notes.project_path()
    health.info("global note: " .. g)
    health.info("project note: " .. p)
  end

  local ok_rm = pcall(require, "render-markdown")
  if ok_rm then
    health.ok("render-markdown.nvim detected")
  elseif vim.fn.executable("glow") == 1 then
    health.ok("glow CLI detected")
  else
    health.warn("no preview backend — falling back to native markdown syntax")
  end
end

return M
