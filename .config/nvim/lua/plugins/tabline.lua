return {
    {
        dir = "~/.config/nvim/local_plugins/tabline.nvim",
        name = "tabline.nvim",
        config = function()
            require("tabline").setup({})
        end,
    },
}