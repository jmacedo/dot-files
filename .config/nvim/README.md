# Neovim

This configuration targets Neovim `0.12.4` and uses its native package manager
to obtain `nvim-lspconfig` on first start. An internet connection and `git` are
therefore required the first time Neovim starts.

## Language servers

`nvim-lspconfig` configures language servers but does not install their
executables. Install the servers you use and keep their executables in
Neovim's `PATH`.

Configured server names:

- `html`, `cssls`, `jsonls`, `yamlls`, `bashls`, `vimls`
- `tsc`, `basedpyright`, `php_lsp`, `symfony_lsp`, `laravel_lsp`
- `sqls`, `jdtls`, `kotlin_lsp`, `gopls`, `clangd`, `rust_analyzer`
- `lua_ls`, `awk_ls`, `dockerls`, `docker_compose_language_service`

Use `:checkhealth vim.lsp` to inspect enabled clients and diagnose missing
servers. Lua-specific settings are loaded explicitly from
`lua/config/lsp/lua_ls.lua`.
