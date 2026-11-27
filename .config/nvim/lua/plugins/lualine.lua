return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require("lualine").setup({
            options = {
                theme = "catppuccin",
            },
            sections = {
                lualine_c = {
                    { "filename", path = 2, file_status = true },
                },
            },
            inactive_sections = {
                lualine_c = {
                    { "filename", path = 2, file_status = true },
                },
            },
        })
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons", }, },
}
