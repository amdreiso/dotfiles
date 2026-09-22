
local folder = "~/shared/vimwiki/"

vim.keymap.set("n", "<leader>ww", function()
	print("ran the thingy")
	vim.cmd("cd " .. folder)
	vim.cmd("VimwikiIndex")
end)

vim.keymap.set("n", "<F12>", function()
	vim.cmd("write")
	vim.fn.jobstart(
		{ vim.fn.expand(folder .. "upload.sh") },
		{ detach = true }
	)
	print("Uploaded to github.")
end)

vim.g.vimwiki_list = {
  {
    path = folder,
    syntax = "default",
    ext = ".wiki",
  }
}

vim.filetype.add({
  extension = {
    wiki = "default",
  },
})

vim.api.nvim_set_hl(0, "VimwikiHeader1", {
	fg = "#ffffff",
	underline = true,
	bold = true,
})

vim.api.nvim_set_hl(0, "VimwikiHeaderChar", {
	fg = "#ffffff",
	conceal = true,
})

vim.api.nvim_set_hl(0, "VimwikiHeader2", {
	fg = "#dddddd",
	italic = true,
})

vim.api.nvim_set_hl(0, "VimwikiLink", {
	fg = "#bb99ff",
	underline = true,
})

vim.api.nvim_set_hl(0, "VimwikiListTodo", {
	fg = "#8080f0",
})

vim.api.nvim_set_hl(0, "VimwikiTodo", {
	bg = "#aa3333",
})

local colors = {
  "#f38ba8",
  "#fab387",
  "#f9e2af",
  "#a6e3a1",
  "#89dceb",
  "#89b4fa",
  "#cba6f7",
}

local i = 1

vim.fn.timer_start(100, function()
  vim.api.nvim_set_hl(0, "VimwikiHeader1", {
    fg = colors[i],
    bold = true,
  })

  i = i % #colors + 1
end, { ["repeat"] = -1 })

