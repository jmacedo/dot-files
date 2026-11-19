return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua, -- Lua
                null_ls.builtins.formatting.prettier, -- Javascript
                null_ls.builtins.formatting.black, -- Python
                null_ls.builtins.formatting.isort, -- Python imports
                --null_ls.builtins.diagnostics.eslint_d, -- Javascript
            },
        })

        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
}