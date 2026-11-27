-- Highlight when yanking (copying) text.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text.",
  callback = function()
    vim.hl.on_yank()
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