if vim.g.loaded_gml_nvim then return end
vim.g.loaded_gml_nvim = true

-- Works out of the box; calling require("gml").setup({...}) later just re-configures.
require("gml").setup()
