
vim.g.mapleader = " "

vim.api.nvim_create_user_command("W", "write", {})

vim.keymap.set("n", "<Leader>q", "<C-^>")

vim.keymap.set('n', "<Leader>f", function()
	require('fzf-lua').files()
end)

vim.keymap.set("n", "<Leader> ", ":Ex<CR>")
vim.keymap.set("n", "<Leader>t", function()
	vim.cmd("terminal")
end)
vim.keymap.set("n", "<leader>r", ":source $MYVIMRC<CR>")

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

