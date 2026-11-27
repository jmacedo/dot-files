-- Highlight when yanking (copying) text.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text.",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Folding: Treesitter quando há query de folds; indent como fallback.
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("FoldingFallback", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end

        local ok, lang = pcall(vim.treesitter.language.get_lang, vim.bo[args.buf].filetype)
        local has_ts_folds = false

        if ok and lang then
            local query_ok, query = pcall(vim.treesitter.query.get, lang, "folds")
            has_ts_folds = query_ok and query ~= nil
        end

        vim.wo.foldmethod = has_ts_folds and "expr" or "indent"
        vim.wo.foldexpr = has_ts_folds and "vim.treesitter.foldexpr()" or ""
    end,
})

-- Applies color gradient on dashboard ascii art.
vim.api.nvim_create_autocmd("User", {
  pattern = "DashboardLoaded",
  callback = function(args)
    local gradient = require("plugins.dashboard.ascii_art.colorscheme")

    gradient.apply(args.buf, require("plugins.dashboard.ascii_art.header").get())
  end,
})

-- Avoid increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:h "clipboard"`
--vim.api.nvim_create_autocmd("UIEnter", {
--  callback = function()
--    vim.o.clipboard = "unnamed,unnamedplus"
--  end,
--})