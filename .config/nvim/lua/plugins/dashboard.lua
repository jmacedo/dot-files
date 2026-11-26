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
                    "",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠔⠒⠒⠒⠒⠐⠢⠄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠢⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⡇⣠⣴⣂⡭⢁⣐⠢⣀⠀⠀⡀⠀⠀⠀⠀⠀⠀⢘⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⠏⠁⠀⠀⠀⠙⢿⣿⣴⣿⣯⠯⠽⣭⣿⣮⣆⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠘⣿⣿⠛⠉⠀⠀⠉⠛⢿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣶⣌⣿⣧⣐⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⢿⣿⣿⣿⡿⡀⠀⠀⠀⠀⢀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣄⠀⠀⡐⠠⡀⠉⠈⠉⠀⠀⣄⣀⣠⣴⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡿⠋⠑⠲⢧⡑⢄⠀⠀⠀⠀⠀⠈⠀⠈⠙⢿⣿⣿⣿⣿⣿⣆⡀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⣠⣺⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠙⢦⠑⠄⢀⡴⠁⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣓⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⢀⡠⣪⣾⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠙⠚⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣧⡑⢄⡀⠀⠀⠀ ",
                    " ⠀⢀⠄⣫⣾⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣶⣄⠢⠀⠀ ",
                    " ⣠⣫⣾⣿⠿⠛⠻⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⡛⠛⠿⣿⣷⣜⡀ ",
                    " ⠙⠛⠁⠀⠀⠀⠀⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠉⠛⠋ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡗⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠈⠿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠈⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⢀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠣⠀⠁⠀⠠⠐⠐⠀⢄⠀⠀⠀⠀⠀⠀⢀⠀⠄⠂⠀⠀⠄⠀⠀⠛⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⢀⠐⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠈⠐⢤⡀⠀⣀⡴⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⡀⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠂⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⣿⡹⡎⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠸⠐⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⢄⠀⠀⠠⠀⠀⠀⠀⠀⠠⠈⠀⠀⠀⢀⠷⠽⠷⡀⠀⠀⠀⠈⠂⠄⡀⠀⠀⠀⠀⠄⠀⡠⠀⠀⠀⠀⠀⠀ ",
                    " ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠉⠁⠉⠈⠁⠁⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠉⠀⠁⠉⠈⠁⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀ ",
                    "         ┌───────┐ ┌───┐ ┌─┐ ┌───────┐ ┌───────┐               ",
                    "        ═│∙  ╒═╕·│═│∙  │═│∙│═╘═╕∙  ╒═╛═│∙ ╒╕╒╕·│               ",
                    "         │   │▓│ │░│   │█│ │ ▓▓│   │░▓ │  │╘╛│ │               ",
                    "        ░│   │▒│ │▒│   │▓│ │░░░│   │▓█░│  │▓▒│ │               ",
                    "        ▒│   │░│ │▓│   └─┘ │▒▒▒│   │░▒▒│  │▒░│ │               ",
                    "        ═│∙  │═│∙│═╘╕     ╒╛═┌─┘∙  └─┐═│∙ │══│∙│               ",
                    "         ╘═══╛ ╘═╛  ╘═════╛  ╘═══════╛ ╘══╛  ╘═╛               ",
                    "",
                },
                shortcut = {
                    {
                        desc = "󰈔  New file",
                        group = "DashboardShortcut",
                        action = "enew",
                        key = "n",
                    },
                    {
                        desc = "󰙅  File explorer",
                        group = "DashboardShortcut",
                        action = "Neotree toggle",
                        key = "e",
                    },
                    {
                        desc = "󰄉  Recent files",
                        group = "DashboardShortcut",
                        action = "Telescope oldfiles",
                        key = "r",
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
