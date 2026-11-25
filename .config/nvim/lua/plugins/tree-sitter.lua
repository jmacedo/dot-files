return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local config = require("nvim-treesitter.config")
        config.setup({
            --ensure_installed = { "lua", "bash", "jq", "json", "kitty", "markdown", },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}