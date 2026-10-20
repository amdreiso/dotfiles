local options = {
	number = true,
	relativenumber = true,
	tabstop = 4,
	shiftwidth = 4,
	smartindent = true,
	autoindent = true,
	ruler = true,
	cursorline = true,
	hlsearch = true,
	wrap = true,
	termguicolors = true,
	mouse = "",

	clipboard = "unnamedplus",

	list = true,
	listchars = {space="·", trail = "·", tab="→ "}, 
}

for key, val in pairs(options) do
	vim.opt[key] = val
end
