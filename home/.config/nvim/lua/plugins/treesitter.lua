return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
            ensure_installed = { "lua", "c", "vim", "vimdoc", "query", "html", "php", "python", "go", "markdown" },
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
}
