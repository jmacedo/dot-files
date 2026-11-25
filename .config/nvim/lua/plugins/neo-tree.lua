return {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    dependencies = {
        { "MunifTanjim/nui.nvim", },
        { "nvim-lua/plenary.nvim", },
        { "nvim-tree/nvim-web-devicons", },
        {
            "Crysthamus/nvim-file-operations",
            config = function ()
                require("nvim-file-operations").setup()
            end
        },
        {
            "3rd/image.nvim",
            build = false,
            opts = {
                processor = "magick_cli",
            },
        },
        {
            's1n7ax/nvim-window-picker',
            name = 'window-picker',
            event = 'VeryLazy',
            config = function()
                require("window-picker").setup()
            end,
        },
    },
}