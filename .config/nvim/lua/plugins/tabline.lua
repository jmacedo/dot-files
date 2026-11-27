return {
    {
        dir = vim.fn.stdpath("config") .. "/local_plugins/tabline.nvim",
        name = "tabline.nvim",
        config = function()
            local palette = require("catppuccin.palettes").get_palette("mocha")

            require("tabline").setup({
                theme = {
                    current_tab = { fg = palette.crust, bg = palette.mauve },
                    inactive_tabs = { fg = palette.text, bg = palette.surface0 },
                    fill = { fg = palette.overlay0, bg = palette.mantle },
                },
            })

            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("TablineCatppuccin", { clear = true }),
                callback = function()
                    require("tabline").apply_highlights()
                end,
            })
        end,
    },
}
