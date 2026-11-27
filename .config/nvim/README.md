## Melhorias sugeridas pelo chat
### LSP e completion
- Implementar a configuração do `nvim-cmp`, LuaSnip e snippets.
- Centralizar a configuração LSP em um módulo próprio.
- Registrar atalhos LSP via `LspAttach`, tornando-os locais ao buffer.
- Adicionar atalhos para referências, rename, declarações e diagnósticos.
- Configurar diagnósticos visuais e formatação por tipo de arquivo.
- Avaliar a lista de servidores LSP instalados automaticamente e remover os que não forem utilizados.
### Editor
- Adicionar instalação automática de formatadores e linters via Mason.
- Revisar atalhos que sobrescrevem comportamentos tradicionais do Vim: `<C-w>`, `<C-p>`, `<C-a>` e `<C-e>`.
### Consistência e portabilidade
- [x] Usar o tema Catppuccin também no Lualine, substituindo o tema Dracula.
- [x] Substituir o caminho `~/.config/nvim/local_plugins/tabline.nvim` por `vim.fn.stdpath("config")`.
- [ ] Melhorar a mensagem de erro quando o Lazy precisa clonar o repositório e o Git não está disponível.