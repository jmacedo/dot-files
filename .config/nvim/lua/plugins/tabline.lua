return {
    {
        dir = "~/.config/nvim/local_plugins/tabline.nvim",
        name = "tabline.nvim",
        cmd = {
            "TablineNew",
            "TablineClose",
            "TablineNext",
            "TablinePrevious",
            "TablineRename",
        },
        config = function()
            require("tabline").setup({})
        end,
    },
}