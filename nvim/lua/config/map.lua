
vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>q", "<C-^>")

vim.keymap.set('n', "<Leader>f", function()
  require('fzf-lua').files()
end)

vim.keymap.set("n", "<Leader> ", ":Ex<CR>")
vim.keymap.set("n", "<Leader>t", function()
	vim.cmd("terminal")
end)
vim.keymap.set("n", "<leader>r", ":source $MYVIMRC<CR>")

