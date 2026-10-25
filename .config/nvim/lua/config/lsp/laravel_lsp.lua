vim.lsp.config("laravel_lsp", {
  cmd = { "laravel-lsp" },
  filetypes = { "php", "blade" },
  root_markers = { "artisan", "composer.json", ".git" },
  -- Load laravel server only on laravel project folders.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "artisan")

    if root then
      on_dir(root)
    end
  end,
})