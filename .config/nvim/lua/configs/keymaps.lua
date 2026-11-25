-- Lazy nvim
vim.keymap.set("n", "<leader>pp", ":Lazy<CR>", { desc = "Open lazy nvim screen." })

-- Mason LSP manager
vim.keymap.set("n", "<leader>pm", ":Mason<CR>", { desc = "Open mason screen." })

-- Neotree
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neotree visualization." })
vim.keymap.set({"n", "i"}, "<C-e>", "normal :Neotree toggle<CR>", { desc = "Toggle Neotree visualization." })

-- Reload configs
vim.keymap.set("n", "<leader>r", ":update<CR>:source<CR>", { desc = "Reload nvim configurations." })

-- Save - CTRL + S
vim.keymap.set({ "n", "i" }, "<C-s>", "normal! :w<CR>", { desc = "Save document." })
vim.keymap.set({ "n", "i" }, "<C-S-s>", "normal! :wq<CR>", { desc = "Save document and quit." })

-- Close - CTRL + W
vim.keymap.set({"n", "i"}, "<C-w>", "normal! :q<CR>", { desc = "Close document." })
vim.keymap.set({"n", "i"}, "<C-S-W>", "normal! :q!<CR>", { desc = "Force close document without saving changes." })

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

-- Toggle folding - CTRL + ALT + F
vim.keymap.set("n", "<C-A-k>", "<Esc>za", { desc = "Toggle folding" })

-- Toggle all foldings - CTRL + ALT + SHIFT + F
vim.keymap.set("n", "<C-A-S-K>", function()
    if vim.wo.foldlevel == 0 then
        vim.cmd("normal! zR")
    else
        vim.cmd("normal! zM")
    end
end, { desc = "Toggle all foldings." })