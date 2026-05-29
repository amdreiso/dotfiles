
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  	use 'wbthomason/packer.nvim'
	use 'neovim/nvim-lspconfig'
	use {
		'hrsh7th/nvim-cmp',
		requires = { 'hrsh7th/cmp-nvim-lsp' }
	}
  	use {
	  	'ibhagwan/fzf-lua',
	  	requires = { 'nvim-tree/nvim-web-devicons' }
	}
	use 'ap/vim-css-color'
	use 'vimwiki/vimwiki'
	use 'echasnovski/mini.pairs'
	--use 'lukas-reineke/headlines.nvim'
	--use 'MeanderingProgrammer/render-markdown.nvim'
	--use 'ellisonleao/glow.nvim'
	--use 'nvim-treesitter/nvim-treesitter'
	--use 'MiladGGG/neonwave.nvim'
	--use 'ellisonleao/gruvbox.nvim'
	--use 'dchinmay2/alabaster.nvim'
end)

