return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            -- Telescope
            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>ff", builtin.find_files, {
                desc = "Telescope find files"
            })

            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
                desc = "Telescope live grep"
            })

            vim.keymap.set("n", "<leader>fh", builtin.live_grep, {
                desc = "Telescope help tags"
            })
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {
                            -- More opts
                        }
                    },
                },
            })

            require("telescope").load_extension("ui-select")
        end,
    },
}