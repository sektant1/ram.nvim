local buffer = require("ram.buffer")

local M = {}

local notified_fallback = false
local glow_term = { winid = nil, bufnr = nil }
local rm_active = false

local function close_glow()
  if glow_term.winid and vim.api.nvim_win_is_valid(glow_term.winid) then
    pcall(vim.api.nvim_win_close, glow_term.winid, true)
  end
  glow_term.winid = nil
  glow_term.bufnr = nil
end

local function open_glow(path)
  vim.cmd("botright split")
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.fn.termopen({ "glow", "-p", path })
  glow_term.winid = winid
  glow_term.bufnr = bufnr
  vim.keymap.set("n", "q", close_glow, { buffer = bufnr, silent = true })
end

---Toggle preview using best available backend.
function M.toggle()
  local state = buffer.state
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.notify("ram.nvim: no ram buffer open", vim.log.levels.WARN)
    return
  end

  local ok_rm, rm = pcall(require, "render-markdown")
  if ok_rm then
    if rm_active then
      pcall(rm.disable)
      rm_active = false
    else
      pcall(rm.enable)
      rm_active = true
    end
    return
  end

  if vim.fn.executable("glow") == 1 then
    if glow_term.winid and vim.api.nvim_win_is_valid(glow_term.winid) then
      close_glow()
    else
      open_glow(state.path)
    end
    return
  end

  vim.bo[state.bufnr].filetype = "markdown"
  if not notified_fallback then
    vim.notify(
      "ram.nvim: render-markdown.nvim/glow not found — using native markdown syntax",
      vim.log.levels.INFO
    )
    notified_fallback = true
  end
end

return M
