vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.wrap = true
vim.o.swapfile = false
vim.o.cursorline = true
vim.o.number = true -- Show line numbers in a column.
vim.o.relativenumber = false
vim.o.scrolloff = 10 -- Keep this many screen lines above/below the cursor.

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.list = true -- Show <tab> and trailing spaces.

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s). See `:h 'confirm'`
vim.o.confirm = true

-- Folding: based on tree-sitter.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99 -- Starts with all foldings open.
vim.opt.foldcolumn = "1" -- Shows folding column.