return { 
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha",
        auto_integrations = false,
        integrations = {
            dashboard = true, -- nvimdev/dashboard-nvim
            telescope = true, -- nvim-telescope/telescope.nvim
            neotree = true, -- nvim-neo-tree/neo-tree.nvim
            mason = true, -- williamboman/mason.nvim
            dap = true, -- mfussenegger/nvim-dap
            dap_ui = true, -- rcarriga/nvim-dap-ui
            window_picker = true, -- s1n7ax/nvim-window-picker
        },
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin-mocha")
    end,
}