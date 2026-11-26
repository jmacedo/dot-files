local function get_random_header()
    local images_dir = vim.fn.stdpath("config")
        .. "/lua/plugins/dashboard/ascii_art/images"
    local files = vim.fn.glob(images_dir .. "/*.ascii.art", false, true)
    local header = {}

    if #files == 0 then
        return header
    end

    local file = files[math.random(#files)]

    for line in io.lines(file) do
        table.insert(header, line)
    end

    return header
end

math.randomseed(tonumber(vim.uv.hrtime() % 2147483647))
local random_header = get_random_header()

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

plugin.header = random_header

return plugin
