local config = require("ram.config")
local notes = require("ram.notes")

local M = {}

---@class RamState
---@field bufnr integer|nil
---@field winid integer|nil
---@field kind "global"|"project"|nil
---@field path string|nil
---@field cursor table<string, integer[]>
M.state = { bufnr = nil, winid = nil, kind = nil, path = nil, cursor = {} }

---@return boolean
function M.is_open()
  return M.state.winid ~= nil and vim.api.nvim_win_is_valid(M.state.winid)
end

local function path_for(kind)
  if kind == "global" then
    return notes.global()
  else
    return notes.project()
  end
end

local function apply_window_opts(winid)
  local wo = vim.wo[winid]
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.number = false
  wo.relativenumber = false
  wo.spell = false
  wo.wrap = true
  wo.linebreak = true
  wo.cursorline = true
end

local function open_container(path)
  local opts = config.options
  local bufnr = vim.fn.bufnr(path, true)
  vim.fn.bufload(bufnr)
  vim.bo[bufnr].buflisted = false

  local winid
  if opts.display == "float" then
    local w = math.max(1, math.floor(vim.o.columns * opts.float.width))
    local h = math.max(1, math.floor(vim.o.lines * opts.float.height))
    local row = math.max(0, math.floor((vim.o.lines - h) / 2))
    local col = math.max(0, math.floor((vim.o.columns - w) / 2))
    winid = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = w,
      height = h,
      row = row,
      col = col,
      border = opts.float.border,
      title = opts.float.title,
      style = "minimal",
    })
  elseif opts.display == "split" then
    vim.cmd("split")
    winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winid, bufnr)
  elseif opts.display == "vsplit" then
    vim.cmd("vsplit")
    winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winid, bufnr)
  elseif opts.display == "tab" then
    vim.cmd("tabnew")
    winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winid, bufnr)
  else
    error("ram.nvim: unknown display mode: " .. tostring(opts.display))
  end

  apply_window_opts(winid)
  return bufnr, winid
end

local function detach_lsp(bufnr)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = bufnr })
      or vim.lsp.get_active_clients({ bufnr = bufnr })
    for _, client in ipairs(clients or {}) do
      pcall(vim.lsp.buf_detach_client, bufnr, client.id)
    end
  end)
end

local function setup_buffer(bufnr, kind, path)
  local opts = config.options
  vim.b[bufnr].ram = kind
  vim.b[bufnr].ram_path = path
  vim.bo[bufnr].filetype = opts.filetype
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "hide"
  detach_lsp(bufnr)

  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = bufnr, silent = true, desc = "Ram: close" })

  if opts.keymaps and opts.keymaps.preview then
    vim.keymap.set("n", opts.keymaps.preview, function()
      require("ram.preview").toggle()
    end, { buffer = bufnr, silent = true, desc = "Ram: preview" })
  end

  local group = vim.api.nvim_create_augroup("ram_buf_" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    buffer = bufnr,
    callback = function()
      if M.is_open() and M.state.winid and vim.api.nvim_win_is_valid(M.state.winid) then
        local ok, cur = pcall(vim.api.nvim_win_get_cursor, M.state.winid)
        if ok and M.state.kind then
          M.state.cursor[M.state.kind] = cur
        end
      end
      if config.options.autosave and vim.bo[bufnr].modified then
        pcall(vim.api.nvim_buf_call, bufnr, function()
          vim.cmd("silent! write")
        end)
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      if tonumber(ev.match) == M.state.winid then
        M.state.winid = nil
        M.state.bufnr = nil
        M.state.kind = nil
        M.state.path = nil
      end
    end,
  })
end

---Open a ram buffer for the given kind. Toggles if same kind already open.
---@param kind "global"|"project"
function M.open(kind)
  assert(kind == "global" or kind == "project", "ram: kind must be global|project")
  if M.is_open() then
    if M.state.kind == kind then
      M.close()
      return
    end
    M.close()
  end

  local path = path_for(kind)
  if not path then
    return
  end
  local bufnr, winid = open_container(path)
  M.state.bufnr = bufnr
  M.state.winid = winid
  M.state.kind = kind
  M.state.path = path

  setup_buffer(bufnr, kind, path)

  local cur = M.state.cursor[kind]
  if cur then
    local lc = vim.api.nvim_buf_line_count(bufnr)
    local row = math.min(cur[1], lc)
    pcall(vim.api.nvim_win_set_cursor, winid, { row, cur[2] })
  end
end

function M.close()
  if not M.is_open() then
    M.state.winid = nil
    M.state.bufnr = nil
    M.state.kind = nil
    M.state.path = nil
    return
  end
  local bufnr = M.state.bufnr
  local winid = M.state.winid
  if winid and vim.api.nvim_win_is_valid(winid) and M.state.kind then
    local ok, cur = pcall(vim.api.nvim_win_get_cursor, winid)
    if ok then
      M.state.cursor[M.state.kind] = cur
    end
  end
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) and config.options.autosave and vim.bo[bufnr].modified then
    pcall(vim.api.nvim_buf_call, bufnr, function()
      vim.cmd("silent! write")
    end)
  end
  if winid and vim.api.nvim_win_is_valid(winid) then
    pcall(vim.api.nvim_win_close, winid, true)
  end
  M.state.winid = nil
  M.state.bufnr = nil
  M.state.kind = nil
  M.state.path = nil
end

return M
