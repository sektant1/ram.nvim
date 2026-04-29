if vim.g.loaded_ram then
  return
end
vim.g.loaded_ram = 1

local function call(fn)
  return function()
    require("ram")[fn]()
  end
end

vim.api.nvim_create_user_command("RamGlobal", call("global"), { desc = "Ram: open global note" })
vim.api.nvim_create_user_command("RamProject", call("project"), { desc = "Ram: open project note" })
vim.api.nvim_create_user_command("RamClose", call("close"), { desc = "Ram: close ram window" })
