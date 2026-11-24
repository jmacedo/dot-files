return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"bashls",
				--"black",
				"cssls",
				"eslint_d",
				"html",
				"intelephense",
				--"isort",
				"laravel_ls",
				"lua_ls",
				--"prettier",
				"stylua",
				"symfony_lsp",
				"ts_ls",
				},
		},
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {},
			},
			{
				"neovim/nvim-lspconfig",
				lazy = false,
				config = function()
					local capabilities = require("cmp_nvim_lsp").default_capabilities()

					vim.lsp.config("lua_ls", {
						settings = {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									checkThirdParty = false,
									library = {
										vim.env.VIMRUNTIME,
									},
								},
								telemetry = {
									enable = false,
								},
							},
						},
						capabilities = capabilities,
					})

					vim.lsp.config("bashls", {capabilities = capabilities,})
					--vim.lsp.config("black", {capabilities = capabilities,})
					vim.lsp.config("cssls", {capabilities = capabilities,})
					vim.lsp.config("eslint_d", {capabilities = capabilities,})
					vim.lsp.config("html", {capabilities = capabilities,})
					vim.lsp.config("intelephense", {capabilities = capabilities,})
					--vim.lsp.config("isort", {capabilities = capabilities,})
					vim.lsp.config("laravel_ls", {capabilities = capabilities,})
					--vim.lsp.config("prettier", {capabilities = capabilities,})
					vim.lsp.config("stylua", {capabilities = capabilities,})
					vim.lsp.config("symfony_lsp", {capabilities = capabilities,})
					vim.lsp.config("ts_ls", {capabilities = capabilities,})

					vim.lsp.enable({
						"bashls",
						--"black",
						"cssls",
						"eslint_d",
						"html",
						"intelephense",
						--"isort",
						"laravel_ls",
						"lua_ls",
						--"prettier",
						"stylua",
						"symfony_lsp",
						"ts_ls",
					})

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