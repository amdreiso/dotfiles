
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gml",
	callback = function()
		vim.cmd([[
			syntax keyword GmlKeyword new static constructor xor div self function for if else switch repeat return enum var 
			syntax match GmlKeyword /#macro\>/
			syntax match GmlNumber /\v<\d+>/
			syntax match GmlComment /\/\/.*/
			syntax match GmlID /^@.*$/
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

--vim.api.nvim_set_hl(0, "GmlID", {
--	fg = "#ff0000",
--	bg = "#202020",
--	bold = true,
--})

local function jump_gml_id(backward)
	local flags = backward and "bw" or "w"
	vim.cmd("normal! m'") -- save position so <C-o> jumps back
	for _ = 1, vim.v.count1 do
		vim.fn.search("^@", flags)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gml",
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }
		vim.keymap.set("n", "<leader>n", function() jump_gml_id(false) end,
			vim.tbl_extend("force", opts, { desc = "Next GmlID" }))
		vim.keymap.set("n", "<leader>N", function() jump_gml_id(true) end,
			vim.tbl_extend("force", opts, { desc = "Previous GmlID" }))
	end,
})

vim.api.nvim_set_hl(0, "GmlID", { fg = "#7777ff", bold = true, bg = "NONE" })

local ns = vim.api.nvim_create_namespace("gml_separator")

local function draw_separators(buf, win)
	buf = buf or vim.api.nvim_get_current_buf()
	win = win or vim.fn.bufwinid(buf)
	if win == -1 then return end -- buffer not visible

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local info = vim.fn.getwininfo(win)[1]
	local total = info.width - info.textoff - 1 -- textoff = number/sign columns
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for i, line in ipairs(lines) do
		if line:match("^@") then
			local w = vim.fn.strdisplaywidth(line)
			local space = math.max(total - w - 2, 2)
			local left = math.floor(space / 2)
			local right = space - left

			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
				virt_text = { { string.rep("─", left) .. " ", "GmlID" } },
				virt_text_pos = "inline",
			})

			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
				end_col = #line,
				hl_group = "GmlID",
				virt_text = { { " " .. string.rep("─", right), "GmlID" } },
				virt_text_pos = "eol",
			})
		end
	end
end

local function redraw_all()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "gml" then
			draw_separators(buf, win)
		end
	end
end

vim.api.nvim_create_autocmd(
	{ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI", "InsertLeave" },
	{
		pattern = "*.gml",
		callback = function(args)
			draw_separators(args.buf)
		end,
	}
)

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
	callback = redraw_all,
})

draw_separators()

