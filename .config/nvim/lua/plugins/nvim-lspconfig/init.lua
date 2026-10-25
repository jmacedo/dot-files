vim.pack.add({
  {
    src = "https://github.com/neovim/nvim-lspconfig",
    version = "v2.12.0",
  },
})

-- Enable snippets support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", { capabilities = capabilities, })
vim.lsp.config("lua_ls", require("config.lsp.lua_ls"))
vim.lsp.config("php_lsp", require("config.lsp.php_lsp"))
vim.lsp.config("laravel_lsp", require("config.lsp.laravel_lsp"))

vim.lsp.enable({
  "html", -- HTML
  "cssls", -- CSS
  "jsonls", -- JSON
  "ts_ls", -- TYPESCRIPT
  "yamlls", -- YAML
  "basedpyright", -- PYTHON
  "bashls", -- BASH
  "vimls", -- VIMSCRIPT
  "awk_ls", -- AWK
  "dockerls", -- DOCKER FILE
  "docker_compose_language_service", -- DOCKER COMPOSE
  "gopls", -- GO
  "sqls", -- SQL
  "jdtls", -- JAVA
  "kotlin_lsp", -- KOTLIN
  "clangd", -- C/C++
  "rust_analyzer", -- RUST
  "lua_ls", -- LUA
  "php_lsp", -- PHP
  "laravel_lsp", -- LARAVEL
})