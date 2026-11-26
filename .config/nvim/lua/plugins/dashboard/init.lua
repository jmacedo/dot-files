local random_header = require("plugins.dashboard.ascii_art.header").get()

local plugin = {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local dashboard = require("dashboard")

        dashboard.setup({
            theme = "hyper",
            hide = {
                statusline = false,
                tabline = false,
                winbar = false,
            },
            config = {
                header = random_header,
                shortcut = {
                    {
                        desc = "󰈔  New file",
                        group = "DashboardShortCut",
                        action = "enew",
                        key = "n",
                    },
                    {
                        desc = "󰙅  File explorer",
                        group = "DashboardShortCut",
                        action = "Neotree toggle",
                        key = "e",
                    },
                    {
                        desc = "󰄉  Recent files",
                        group = "DashboardShortCut",
                        action = "Telescope oldfiles",
                        key = "r",
                    },
                    {
                        desc = "󰒲  Plugin manager",
                        group = "DashboardShortCut",
                        action = "Lazy",
                        key = "l",
                    },
                    {
                        desc = "󰗼  Quit Neovim",
                        group = "DashboardShortCut",
                        action = "qa",
                        key = "q",
                    },
                },

                week_header = {
                    enable = false,
                },

                project = {
                    enable = true,
                    limit = 3,
                    icon = "󰉋 ",
                    label = " Recent projects:",
                    action = "Telescope find_files cwd=",
                },

                mru = {
                    limit = 5,
                    icon = "󰋚 ",
                    label = " Recent files:",
                    cwd_only = false,
                },

                footer = function()
                    local version = vim.version()

                    return {
                        "",
                        string.format(
                            "Neovim %d.%d.%d",
                            version.major,
                            version.minor,
                            version.patch
                        ),
                    }
                end,
            },
        })
    end,
}

return plugin
