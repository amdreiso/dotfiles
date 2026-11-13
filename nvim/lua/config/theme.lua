
vim.cmd("syntax enable")

vim.o.background = "dark"
vim.cmd.colorscheme("retrobox")

vim.cmd.highlight({"Normal", "guibg=NONE"})
vim.cmd.highlight({"NormalNC", "guibg=NONE", "ctermbg=NONE"})

vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })
vim.api.nvim_set_hl(0, "WhiteSpace", { fg = "#202020", bold=true })

