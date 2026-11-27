return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")
            local actions = require("telescope.actions")
            local themes = require("telescope.themes")

            telescope.setup({
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = "❯ ",
                    path_display = { "smart" },
                    winblend = 10,
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    layout_config = {
                        horizontal = { preview_width = 0.5, width = 0.85, height = 0.8 },
                        vertical = { width = 0.9, height = 0.9 },
                    },
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<C-u>"] = actions.preview_scrolling_up,
                        },
                        n = {
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<C-u>"] = actions.preview_scrolling_up,
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = themes.get_dropdown({}),
                },
            })

            telescope.load_extension("ui-select")

            local function git_or_files()
                if vim.fn.finddir(".git", ".;") ~= "" then
                    builtin.git_files({ show_untracked = true })
                else
                    builtin.find_files({ hidden = true })
                end
            end

            vim.keymap.set("n", "<leader>ff", function() builtin.find_files({ hidden = true }) end, { desc = "Telescope find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
            vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep word under cursor" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope recent files" })
            vim.keymap.set("n", "<leader>fc", git_or_files, { desc = "Telescope git files / find files" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
        end,
    },
}
