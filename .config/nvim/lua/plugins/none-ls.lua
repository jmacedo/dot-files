return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            border = "rounded",
            update_in_insert = true,
            sources = {
                null_ls.builtins.formatting.stylua,
            },
        })

        vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
    end,
}