-- Highlight when yanking (copying) text.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text.",
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "DashboardLoaded",
  callback = function(args)
    local gradient = require("plugins.dashboard.ascii_art.colorscheme")
    local images_dir = vim.fn.stdpath("config") .. "/lua/plugins/dashboard/ascii_art/images"
    local files = vim.fn.glob(images_dir .. "/*.ascii.art", false, true)
    local header = {}

    if #files > 0 then
      local random_file = files[math.random(#files)]

      for line in io.lines(random_file) do
        table.insert(header, line)
      end
    end

    gradient.apply(args.buf, header)
  end,
})

-- Avoid increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:h "clipboard"`
--vim.api.nvim_create_autocmd("UIEnter", {
--  callback = function()
--    vim.o.clipboard = "unnamed,unnamedplus"
--  end,
--})