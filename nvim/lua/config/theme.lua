vim.cmd("syntax enable")

vim.o.background = "dark"
vim.cmd.colorscheme("quiet")

vim.opt.guicursor = "a:block"

vim.cmd.highlight({"Normal", "guibg=NONE"})
vim.cmd.highlight({"NormalNC", "guibg=NONE", "ctermbg=NONE"})

vim.opt.foldenable = true
vim.opt.foldmethod = "syntax"
vim.opt.foldcolumn = "2"
vim.opt.fillchars = {
	foldopen = "^",
	foldclose = ">",
	fold = " ",
	foldsep = " ",
}

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		vim.cmd("silent! loadview")
	end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
	callback = function()
		vim.cmd("silent! mkview")
	end,
})

vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })

vim.filetype.add({
	extension = {
		tolin = "tolin",
		gml = "gml",
	},
})

require("config.gml")

local name = 0

local theme = {
	keyword 	= {fg = "#feff7a", bold = true},
	fn 			= {fg = "#ff5555"},
	special 	= {fg = "#ff55ff"},
	constant 	= {fg = "#ffff55"},
	statement 	= {fg = "#888888"},
	identifier 	= {fg = "#dddddd"},
	str 		= {fg = "#ccc855"},
	visual		= {fg = "#ffffff", bg = "#3344bb"},
	number		= {fg = "#ff5555"},

	lua = {
		variable 		= {fg = "#ff597f", bold = true},
		variableMember 	= {fg = "#ff59d5"},
		functionCall	= {fg = "#cf59ff", bold = true},
		boolean 		= {fg = "#ff5555"},
		property 		= {fg = "#a2f7ff"},
	},
}

vim.api.nvim_set_hl(0, "Keyword", theme.keyword)
vim.api.nvim_set_hl(0, "Function", theme.fn)
vim.api.nvim_set_hl(0, "Special", theme.special)
vim.api.nvim_set_hl(0, "Statement", theme.keyword)
vim.api.nvim_set_hl(0, "Operator", theme.statement)
vim.api.nvim_set_hl(0, "Identifier", theme.identifier)
vim.api.nvim_set_hl(0, "String", theme.str)
vim.api.nvim_set_hl(0, "Visual", theme.visual)
vim.api.nvim_set_hl(0, "Number", theme.number)

vim.api.nvim_set_hl(0, "@boolean.lua", theme.lua.boolean)
vim.api.nvim_set_hl(0, "@property.lua", theme.lua.property)
vim.api.nvim_set_hl(0, "@variable.lua", theme.lua.variable)
vim.api.nvim_set_hl(0, "@variable.member.lua", theme.lua.variableMember)
vim.api.nvim_set_hl(0, "@function.call.lua", theme.lua.functionCall)

