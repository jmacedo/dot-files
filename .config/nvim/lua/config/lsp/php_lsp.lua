return {
  on_init = function (client)
    vim.lsp.config("php_lsp", {
      cmd = { "intelephense", "--stdio" },
      filetypes = { "php" },
      root_markers = { "composer.json", ".git" },
    })
  end,
}