# Neovim

## Servidores LSP

[https://github.com/neovim/nvim-lspconfig]
`nvim-lspconfig` fornece configurações para conectar o Neovim aos servidores
LSP; ele não instala os executáveis desses servidores.

Esta configuração habilita:

- `jsonls`
- `html`
- `bashls`
- `cssls`
- `tsc`
- `vimls`
- `dockerls`
- `php_lsp`
- `lua_ls`

Instale os servidores correspondentes e garanta que seus executáveis estejam
no `PATH` do Neovim. Para verificar a configuração e os servidores disponíveis,
execute `:checkhealth vim.lsp`.
