-- Lazy nvim
vim.keymap.set("n", "<leader>pp", ":Lazy<CR>", { desc = "Open lazy nvim screen." })

-- Mason LSP manager
vim.keymap.set("n", "<leader>pm", ":Mason<CR>", { desc = "Open mason screen." })

-- Neotree
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neotree visualization." })
vim.keymap.set("n", "<C-e>", ":Neotree toggle<CR>", { desc = "Toggle Neotree visualization." })

-- Terminal mode: Use <Esc> to exit
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Close terminal mode." })

-- Reload configs
vim.keymap.set("n", "<leader>r", ":update<CR>:source<CR>", { desc = "Reload nvim configurations." })

-- Save - CTRL + S
vim.keymap.set({ "n", "i" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save document." })
vim.keymap.set({ "n", "i" }, "<C-S>", "<Esc>:wq<CR>", { desc = "Save document and quit." })

-- Close - CTRL + W
vim.keymap.set({"n", "i"}, "<C-w>", "<Esc>:q<CR>", { desc = "Close document." })
vim.keymap.set({"n", "i"}, "<C-W>", "<Esc>:q!<CR>", { desc = "Force close document without saving changes." })

-- Select all - CTRL + A
vim.keymap.set({"n", "i"}, "<C-a>", "<Esc>ggVG", { desc = "Select all text." })

-- Select word - CTRL + P
vim.keymap.set({"n", "i"}, "<C-p>", "<Esc>viw", { desc = "Select the word under cursor." })

-- Select context - CTRL + SHIFT + A
vim.keymap.set({"n", "i"}, "<C-S-a>", function()
    -- Requires tree-sitter.
    local node = vim.treesitter.get_node()

    if not node then
        vim.notify("No syntatic node found.")
        return
    end

    local sr, sc, er, ec = node:range()

    -- Put the cursor at start of the context node text.
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })

    -- Starts nvim"s visual mode.
    vim.cmd("normal! v")

    -- Move the cursor to the end of the context node text.
    vim.api.nvim_win_set_cursor(0, {
        er + 1,
        math.max(sc, ec - 1)
    })
end, { desc = "Select syntatic context." })

-- Toggle folding - CTRL + ALT + F
vim.keymap.set({"n", "i"}, "<C-M-f>", "<Esc>za", { desc = "Toggle folding" })

-- Toggle all foldings - CTRL + ALT + SHIFT + F
vim.keymap.set({"n", "i"}, "<C-M-S-f>", function()
    if vim.fn.foldclosed(".") == -1 then
        vim.cmd("normal! zM") -- Close all
    else
        vim.cmd("normal! zR") -- Open all
    end
end, { desc = "Toggle all foldings." })