return {
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
                header = {
                    --"",
                    --"",
                    --" ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                    --" ████╗  ██║██║   ██║██║████╗ ████║",
                    --" ██╔██╗ ██║██║   ██║██║██╔████╔██║",
                    --" ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                    --" ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                    --" ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚══╝",
                    --"",
                    "",
                    "",
                    " ███╗   ██╗██╗   ██╗██╗███╗   ███╗        .--. ",
                    " ████╗  ██║██║   ██║██║████╗ ████║       |o_o | ",
                    " ██╔██╗ ██║██║   ██║██║██╔████╔██║       |:_/ | ",
                    " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║      //   \\ \\ ",
                    " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║     (|     | ) ",
                    " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚══╝    /'\\_   _/`\\ ",
                    "",
                    "               Configure. Code. Create.",
                    "",
                },

                shortcut = {
                    {
                        desc = "󰈞  Find file",
                        group = "DashboardShortcut",
                        action = "Telescope find_files",
                        key = "f",
                    },
                    {
                        desc = "󰈔  New file",
                        group = "DashboardShortcut",
                        action = "enew",
                        key = "n",
                    },
                    {
                        desc = "󰱼  Find text",
                        group = "DashboardShortcut",
                        action = "Telescope live_grep",
                        key = "g",
                    },
                    {
                        desc = "󰄉  Recent files",
                        group = "DashboardShortcut",
                        action = "Telescope oldfiles",
                        key = "r",
                    },
                    {
                        desc = "󰙅  File explorer",
                        group = "DashboardShortcut",
                        action = "Neotree toggle",
                        key = "e",
                    },
                    {
                        desc = "󰒲  Plugin manager",
                        group = "DashboardShortcut",
                        action = "Lazy",
                        key = "l",
                    },
                    {
                        desc = "󰗼  Quit Neovim",
                        group = "DashboardShortcut",
                        action = "qa",
                        key = "q",
                    },
                },

                week_header = {
                    enable = true,
                },

                project = {
                    enable = true,
                    limit = 8,
                    icon = "󰉋 ",
                    label = " Recent projects:",
                    action = "Telescope find_files cwd=",
                },

                mru = {
                    limit = 10,
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
