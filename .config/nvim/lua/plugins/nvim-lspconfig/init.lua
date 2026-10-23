vim.pack.add({
  {
    src = "https://github.com/neovim/nvim-lspconfig",
    version = "v2.12.0",
  },
})

-- Enable snippets support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Load laravel server only on laravel project folders.
vim.lsp.config("laravel_lsp", {
  cmd = { "laravel-lsp" },
  filetypes = { "php", "blade" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "artisan")

    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.enable({
  "html", -- HTML
  "cssls", -- CSS
  "jsonls", -- JSON
  "tsc", -- TYPESCRIPT
  "yamlls", -- YAML
  "php_lsp", -- PHP
  "symfony_lsp",-- SYMFONY
  "laravel_lsp",-- LARAVEL
  "sqls", -- SQL
  "basedpyright", -- PYTHON
  "jdtls", -- JAVA
  "kotlin_lsp", -- KOTLIN
  "gopls", -- GO
  "clangd", -- C/C++
  "rust_analyzer", -- RUST
  "lua_ls", -- LUA
  "bashls", -- BASH
  "awk_ls", -- AWK
  "vimls", -- VIMSCRIPT
  "dockerls", -- DOCKER FILE
  "docker_compose_language_service", -- DOCKER COMPOSE
})
