vim.cmd("syntax enable")

vim.o.background = "dark"
vim.cmd.colorscheme("quiet")

vim.opt.guicursor = "a:block"

vim.cmd.highlight({"Normal", "guibg=NONE"})
vim.cmd.highlight({"NormalNC", "guibg=NONE", "ctermbg=NONE"})

vim.filetype.add({
	extension = {
		tolin = "tolin",
		gml = "gml",
	},
})

require("config.gml")

local dark_cs = {
	foreground = "#d9d9d9",
	--keyword = "#4682b4",
	keyword = "#4682b4",
	popup = "#181818",
	bold = false,
	italic = false,
	cursorline = "#252525"
}

local light_cs = {
	foreground = "#000000",
	keyword = "#2222ff",
	popup = "#ffffff",
	bold = true,
	italic = false,
	cursorline = "#e0e0f0"
}

function colors(cs)
	vim.api.nvim_set_hl(0, "CursorLine", {
		bg = cs.cursorline,
	})


	for _, group in ipairs({
		"Normal",
		"NormalNC",
		"SignColumn",
		"CursorLineNr",
		"Comment",
		"Constant",
		"String",
		"Character",
		"PreProc",
		"Identifier",
		"Type",
		"Special",
		"Underlined",
		"Error",
		"Todo",
	}) do
		vim.api.nvim_set_hl(0, group, {
			fg = cs.foreground,
			bold = cs.bold,
		})
	end

	for _, group in ipairs({
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
	}) do
		vim.api.nvim_set_hl(0, group, {
			fg = cs.keyword,
			bold = false,
			italic = cs.italic,
		})
	end
end

local FILE = io.open(os.getenv("HOME") .. "/.config/theme/index")
local index = FILE:read("*a")
index = index:gsub("%s+", "")
FILE:close()

local cs = dark_cs

if index == "0" then
	colors(dark_cs)
	cs = dark_cs
elseif index == "1" then
	colors(light_cs)
	cs = light_cs
end


vim.api.nvim_create_autocmd("FileType", {
	pattern = "tolin",
	callback = function()
		vim.cmd([[
			syntax keyword TolinKeyword func set if for while end include struct get assign array do return call
			syntax match TolinNumber /\v<\d+>/
			syntax match TolinComment /\/\/.*/
			syntax region TolinString start=/"/ skip=/\\"/ end=/"/
		]])
	end,
})

local popups = {
	"Pmenu", "PmenuSel", "NormalFloat", "FloatBorder"
}

vim.api.nvim_set_hl(0, "TolinComment", {
	fg = "#aaaaaa"
})

for i=1, #popups do
	vim.api.nvim_set_hl(0, popups[i], {
		bg = cs.popup
	})
end

vim.api.nvim_set_hl(0, "Comment", {
	fg = "#999999",
})

