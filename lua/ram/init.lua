local config = require("ram.config")

local M = {}

---@return table
local function buffer()
  return require("ram.buffer")
end

---Open the global ram note (toggle if already open).
function M.global()
  buffer().open("global")
end

---Open the project ram note (toggle if already open).
function M.project()
  buffer().open("project")
end

---Toggle last-opened ram note (defaults to global).
function M.toggle()
  buffer().toggle()
end

---Close the ram window.
function M.close()
  buffer().close()
end

local function set_keymap(lhs, fn, desc)
  if not lhs then
    return
  end
  vim.keymap.set("n", lhs, fn, { silent = true, desc = desc })
end

local function register_lsp_guard()
  local group = vim.api.nvim_create_augroup("ram_lsp_guard", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      if not vim.b[ev.buf].ram then
        return
      end
      local client_id = ev.data.client_id
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          pcall(vim.lsp.buf_detach_client, ev.buf, client_id)
        end
      end)
    end,
  })
end

---Configure ram.nvim.
---@param opts table|nil
function M.setup(opts)
  config.setup(opts)
  local km = config.options.keymaps or {}
  set_keymap(km.global, M.global, "Ram: global note")
  set_keymap(km.project, M.project, "Ram: project note")
  set_keymap(km.toggle, M.toggle, "Ram: toggle")
  set_keymap(km.close, M.close, "Ram: close")
  register_lsp_guard()
end

return M
