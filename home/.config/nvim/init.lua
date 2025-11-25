--LAZYVIM
require("config.lazy")

--GENERAL
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
--vim.cmd('set shiftwidth=2')
vim.g.mapleader = " "

--TELESCOPE
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

--TREESITTER
--local config = require("nvim-treesitter.configs")
--config.setup({
--    ensure_installed = { "lua", "c", "vim", "vimdoc", "query", "html", "php", "python", "go", "markdown" },
--    highlight = { enable = true },
--    indent = { enable = true },
--})

--CATPPUCCIN
require("catppuccin").setup()
vim.cmd.colorscheme("catppuccin")
