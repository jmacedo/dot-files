# Neovim

This configuration is based on Neovim `0.12.*` and uses its native package manager to obtain `nvim-lspconfig` on first start.

## Language servers

`nvim-lspconfig` configures language servers but does not install their
executables. Install the servers you use and keep their executables in
Neovim's `PATH`.

Configured server names:
- `html`
- `cssls`
- `jsonls`
- `ts_ls`
- `yamlls`
- `basedpyright`
- `bashls`
- `vimls`
- `awk_ls`
- `dockerls`
- `docker_compose_language_service`
- `gopls`
- `sqls`
- `jdtls`
- `kotlin_lsp`
- `clangd`
- `rust_analyzer`
- `lua_ls`
- `php_lsp`
- `laravel_lsp`

Server-specific settings are loaded explicitly from `lua/config/lsp/<server.lua>`.
e.g. `lua/config/lsp/lua_ls.lua`, `lua/config/lsp/php_lsp.lua`