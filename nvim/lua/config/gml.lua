
require("gml").setup({
  highlights = {
    GmlVariable        = { fg = "#b2b1ff" },
    GmlLocalVariable   = { fg = "#ffff88" },
    GmlKeyword         = { fg = "#ffb871", bold = true },
    GmlPreproc         = { fg = "#ffb871", bold = true },
    GmlFunction        = { fg = "#ffb871" },
    GmlConstructor     = { fg = "#ffb871" },
    GmlNumber          = { fg = "#ff8080" },
    GmlConstant        = { fg = "#ff8080" },
    GmlEnumName        = { fg = "#ff8080" },
    GmlEnumValue       = { fg = "#ff8080" },
    GmlMacro           = { fg = "#ff8080" },
    GmlBuiltinConstant = { fg = "#ff8080" },
    GmlAsset 			= { fg = "#ff8080", bold = true },
    GmlBuiltinVariable = { fg = "#50ff50" },
    GmlComment         = { fg = "#5b995b" },
    GmlString          = { fg = "#ffff00" },
    GmlID              = { fg = "#7777ff", bold = true, bg = "NONE", nocombine = true },
  },
})

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

vim.opt.foldmethod = "marker"
vim.opt.foldmarker = "#region,#endregion"
vim.keymap.set("n", "<leader>p", "za", { desc = "Toggle fold" })

vim.keymap.set("n", "<leader>s", function()
	local path = vim.fn.expand("%:p:h")

	while path ~= "/" do
		if vim.fn.isdirectory(path.."/.gm") == 1 then
			local project = vim.fn.fnamemodify(path.."/.gm", ":h")

			vim.fn.jobstart({
				"glim",
				"sync",
			}, {
				cwd = project,
			})

			print("Synchronized gml project")
			return
		end

		path = vim.fn.fnamemodify(path, ":h")
	end
end)

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


-- GML Indentation
function _G.GetGmlIndent()
	local lnum = vim.v.lnum
	local prev_lnum = vim.fn.prevnonblank(lnum - 1)
	if prev_lnum == 0 then
		return 0
	end

	local prev = (vim.fn.getline(prev_lnum):gsub("%s*//.*$", ""))
	local cur = vim.fn.getline(lnum)
	local sw = vim.fn.shiftwidth()
	local indent = vim.fn.indent(prev_lnum)

	if prev:match("{%s*$") then
		indent = indent + sw
	end
	if cur:match("^%s*}") then
		indent = indent - sw
	end

	return math.max(indent, 0)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gml",
	callback = function(args)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(args.buf) then return end
			local bo = vim.bo[args.buf]
			bo.cindent = false
			bo.smartindent = false
			bo.autoindent = true
			bo.indentexpr = "v:lua.GetGmlIndent()"
			bo.indentkeys = "0{,0},0),0],!^F,o,O,e"
		end)
	end,
})


function _G.GmlStatusEvent()
  for i = vim.fn.line("."), 1, -1 do
    local event = vim.fn.getline(i):match("@([%w_]+)")
    if event then
      return event:upper()
    end
  end
  return ""
end

vim.opt.statusline = "%f %h%m%r%=%l:%c %p%% %{v:lua.GmlStatusEvent()}"

