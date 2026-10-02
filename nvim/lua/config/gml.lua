
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gml",
	callback = function()
		vim.cmd([[
			syntax keyword GmlKeyword new static constructor xor div self function for if else switch repeat return enum var 
			syntax match GmlKeyword /#macro\>/
			syntax match GmlNumber /\v<\d+>/
			syntax match GmlComment /\/\/.*/
			syntax match GmlID /@.*$/
			syntax region GmlString start=/"/ skip=/\\"/ end=/"/
		]])
	end,
})

vim.api.nvim_set_hl(0, "GmlComment", {
	fg = "#33aa55",
})

vim.api.nvim_set_hl(0, "GmlKeyword", {
	fg = "#ffff55",
	bold = true,
})

vim.api.nvim_set_hl(0, "GmlNumber", {
	fg = "#ff5555",
})

vim.api.nvim_set_hl(0, "GmlID", {
	fg = "#ff0000",
})


