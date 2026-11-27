-- Reload configs
vim.keymap.set("n", "<leader>r", ":update<CR>:source<CR>", { desc = "Reload nvim configurations." })

-- Plugin Manager: Lazy nvim
vim.keymap.set("n", "<leader>pp", ":Lazy<CR>", { desc = "Open lazy nvim screen." })

-- Mason LSP manager
vim.keymap.set("n", "<leader>pm", ":Mason<CR>", { desc = "Open mason screen." })

-- Neotree
vim.keymap.set("n", "<leader>eo", ":Neotree<CR>", { desc = "Open neotree visualization." })
vim.keymap.set("n", "<leader>ec", ":Neotree close<CR>", { desc = "Close neotree visualization." })
vim.keymap.set({"n", "i"}, "<C-e>", ":Neotree toggle<CR>", { desc = "Toggle neotree visualization." })

-- Save - CTRL + S
vim.keymap.set({ "n", "i" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save document." })
vim.keymap.set({ "n", "i" }, "<C-S-s>", "<Esc>:wq<CR>", { desc = "Save document and quit." })

-- Close - CTRL + W
vim.keymap.set({"n", "i"}, "<C-w>", "<Esc>:q<CR>", { desc = "Close document." })
vim.keymap.set({"n", "i"}, "<C-S-W>", "<Esc>:q!<CR>", { desc = "Force close document without saving changes." })

-- Select all - CTRL + A
vim.keymap.set({"n", "i"}, "<C-a>", "normal! ggVG", { desc = "Select all text." })

-- Select word - CTRL + P
vim.keymap.set({"n", "i"}, "<C-p>", "normal! viw", { desc = "Select the word under cursor." })

-- Select context - CTRL + SHIFT + A
vim.keymap.set({"n", "i"}, "<C-S-a>", function()
    -- Requires tree-sitter.
    local node = vim.treesitter.get_node()

    if not node then
        vim.notify("No syntatic node found.")
        return
    end

    local start_row, start_column, end_row, end_column = node:range()

    -- Put the cursor at start of the context node text.
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_column })

    -- Starts nvim"s visual mode.
    vim.cmd("normal! v")

    -- Move the cursor to the end of the context node text.
    vim.api.nvim_win_set_cursor(0, {
        end_row + 1,
        math.max(start_column, end_column - 1)
    })
end, { desc = "Select syntatic context." })

-- Toggle folding - Leader + z (lowercase)
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle folding" })

-- Toggle all foldings - Leader + Z (uppercase)
vim.keymap.set("n", "<leader>Z", function()
    if vim.wo.foldlevel == 0 then
        vim.cmd("normal! zR")
    else
        vim.cmd("normal! zM")
    end
end, { desc = "Toggle all foldings." })

-- Abas (buffers)
vim.keymap.set("n", "<leader>tn", "<cmd>TablineNew<CR>")
vim.keymap.set("n", "<leader>tq", "<cmd>TablineClose<CR>")
vim.keymap.set("n", "<C-D-PageUp>", "<cmd>TablinePrevious<CR>")
vim.keymap.set("n", "<C-D-PageDown>", "<cmd>TablineNext<CR>")

--for i = 1, 9 do
--    vim.keymap.set("n", "<S-D>" .. i, function()
--        require("bufferline").go_to(i, true)
--    end, { desc = "Go to tab " .. i })
--end
