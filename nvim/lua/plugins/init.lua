
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  	use "wbthomason/packer.nvim"
	use "neovim/nvim-lspconfig"
	use {
		"hrsh7th/nvim-cmp",
		requires = { "hrsh7th/cmp-nvim-lsp" }
	}
  	use {
	  	"ibhagwan/fzf-lua",
	  	requires = { "nvim-tree/nvim-web-devicons" }
	}
	use "ap/vim-css-color"
	use "vimwiki/vimwiki"
	use "echasnovski/mini.pairs"
	use "barrettruth/live-server.nvim"
	use "andweeb/presence.nvim"
	use {
		"3rd/image.nvim",
		config = function()
			require("image").setup({
				processor = "magick_cli",
				backend = "kitty",

				integrations = {
					markdown = {
						enabled = true,
						filetypes = {"markdown", "vimwiki"},
					},
				},
			})
		end,
	}
end)

