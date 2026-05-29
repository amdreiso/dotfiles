vim.cmd("syntax enable")

vim.o.background = "dark"
vim.cmd.colorscheme("quiet")

vim.cmd.highlight({"Normal", "guibg=NONE"})
vim.cmd.highlight({"NormalNC", "guibg=NONE", "ctermbg=NONE"})

vim.filetype.add({
	extension = {
		tolin = "tolin",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "tolin",
	callback = function()
		vim.cmd([[
			syntax keyword TolinKeyword func set if for while end include struct get assign array do return
			syntax match TolinNumber /\v<\d+>/
			syntax match TolinComment /\/\/.*/
			syntax region TolinString start=/"/ skip=/\\"/ end=/"/
		]])
	end,
})

local cs = {
	keyword = "#ffff55",
	popup = "#181818"
}

local group = {
	"Conditional",
	"Keyword",
	"Type",
	"Repeat",
	"PreProc",
	"@include",
	"@function.builtin",
	"Statement",
	"@type",
	"@keyword",
	"Include",
	"TolinKeyword",
}

local popups = {
	"Pmenu", "PmenuSel", "NormalFloat", "FloatBorder"
}

for i=1, #group do
	vim.api.nvim_set_hl(0, group[i], {
		fg = cs.keyword,
		bold = true,
	})
end

for i=1, #popups do
	vim.api.nvim_set_hl(0, popups[i], {
		bg = cs.popup
	})
end



--highlight TolinKeyword guifg=cs.keyword
--highlight TolinNumber guifg=cs.keyword
--highlight TolinComment guifg=cs.keyword
--highlight TolinString guifg=cs.keyword
