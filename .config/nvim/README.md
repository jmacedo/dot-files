- winborder:
    - "bold": Bold line box.
    - "double": Double-line box.
    - "none": No border.
    - "rounded": Like "single", but with rounded corners ("╭" etc.).
    - "shadow": Drop shadow effect, by blending with the background.
    - "single": Single-line box.
    - "solid": Adds padding by a single whitespace cell.
    - custom: comma-separated list of exactly 8 entries in clockwise order starting from topleft. Each entry may be a single char, a single space (filled with the background), or empty (no border on that side). Example:
        - vim.o.winborder = '+,-,+,|,+,-,+,|'
        - vim.o.winborder = ',,, ,,,, '  -- left/right padding only

## Melhorias sugeridas

### Correções prioritárias

- Corrigir o mapeamento `<leader>fh` do Telescope para `help_tags`.
- Corrigir o gerenciamento de autoc comandos do plugin local `tabline.nvim`,
  que usa inconsistentemente `M.runtime.autocmd` e
  `M.runtime.autocmd.list`.
- Corrigir `select_tab()` para chamar
  `nvim_tabpage_list_wins(tabpage)`.
- Corrigir o caminho das imagens do dashboard, atualmente diferente do
  diretório onde os arquivos `.ascii.art` estão armazenados.

### LSP e completion

- Implementar a configuração do `nvim-cmp`, LuaSnip e snippets.
- Centralizar a configuração LSP em um módulo próprio.
- Registrar atalhos LSP via `LspAttach`, tornando-os locais ao buffer.
- Adicionar atalhos para referências, rename, declarações e diagnósticos.
- Configurar diagnósticos visuais e formatação por tipo de arquivo.
- Avaliar a lista de servidores LSP instalados automaticamente e remover os
  que não forem utilizados.

### Editor

- Configurar folding baseado em Tree-sitter em vez de `foldmethod=manual`.
- Adicionar instalação automática de formatadores e linters via Mason.
- Revisar atalhos que sobrescrevem comportamentos tradicionais do Vim:
  `<C-w>`, `<C-p>`, `<C-a>` e `<C-e>`.
- Verificar a compatibilidade de `<C-S-s>` e `<C-S-W>` em diferentes terminais.

### Consistência e portabilidade

- Usar o tema Catppuccin também no Lualine, substituindo o tema Dracula.
- Substituir o caminho `~/.config/nvim/local_plugins/tabline.nvim` por
  `vim.fn.stdpath("config")`.
- Melhorar a mensagem de erro quando o Lazy precisa clonar o repositório e o
  Git não está disponível.
