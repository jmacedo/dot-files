return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"awk_ls",
				"bashls",
				"clangd",
				"cssls",
				"dockerls",
				"eslint",
				"html",
				"intelephense",
				"jsonls",
				"kotlin_lsp",
				"laravel_ls",
				"lua_ls",
				"luau_lsp",
				"nextls",
				"postgres_lsp",
				"pylsp",
				"rust_analyzer",
				"sqlls",
				"symfony_lsp",
				"ts_ls",
				"twiggy_language_server",
				"yamlls",
			},
			automatic_enable = {
				"awk_ls",
				"bashls",
				"clangd",
				"cssls",
				"dockerls",
				"eslint",
				"html",
				"intelephense",
				"jsonls",
				"kotlin_lsp",
				"laravel_ls",
				"lua_ls",
				"luau_lsp",
				"nextls",
				"postgres_lsp",
				"pylsp",
				"rust_analyzer",
				"sqlls",
				"symfony_lsp",
				"ts_ls",
				"twiggy_language_server",
				"yamlls",
			},
		},
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = { ui = { border = "rounded" }, },
			},
			{
				"neovim/nvim-lspconfig",
				config = function()
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.hover, {})
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {
						desc = "LSP Code Action",
					})
				end,
			},
		}
	},
}