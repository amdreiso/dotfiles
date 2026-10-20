
require("plugins") 
require("config.map") 
require("config.fzf") 
require("config.minipairs") 
require("config.options") 
require("config.theme") 
require("config.vimwiki")
require("config.gml")

vim.opt.shortmess:append("I")

vim.keymap.set("n", "r", function()
  local cursor = vim.o.guicursor
  vim.opt.guicursor = "n:hor50"
  local char = vim.fn.getcharstr()
  vim.opt.guicursor = cursor

  if char ~= "\27" then
    vim.api.nvim_feedkeys("r" .. vim.fn.keytrans(char), "n", false)
  end
end, { noremap = true })

