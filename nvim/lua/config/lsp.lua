
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
    "clangd",
    "lua_ls",
}

for _, server in ipairs(servers) do
	vim.lsp.config(server, {
		capabilities = capabilities,
	})
    vim.lsp.enable(server)
end

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},

			diagnostics = {
				globals = {
					"_G",
					"vim",
				},
				enable = false
			},

			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
				maxPreload = 5000,
				preloadFileSize = 1000,
			},

			completion = {
				callSnippet = "Both",
			},

			hint = {
				enable = true,
			},
		},
	},
})

