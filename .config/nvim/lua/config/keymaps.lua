-- KEYMAPS
-- See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Terminal mode: Use <Esc> to exit

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Close terminal mode." })

-- Document manipulation

-- Save - CTRL + S
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>write<CR>", { desc = "Save document." })

-- Close - CTRL + Q
vim.keymap.set("n", "<C-q>", "<cmd>quit<CR>", { desc = "Close document." })

-- Search - CTRL + F
vim.keymap.set("n", "<C-f>", "/", { desc = "Search in document." })

-- Select all - CTRL + A
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text." })

-- Select word - CTRL + P
vim.keymap.set("n", "<C-p>", "viw", { desc = "Select the word under cursor." })

-- Select context - CTRL + SHIFT + A
vim.keymap.set("n", "<C-S-a>", function()
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

-- Folding: based on tree-sitter.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99 -- Starts with all foldings open.
vim.opt.foldcolumn = "1" -- Shows folding column.

-- Toggle folding - CTRL + ALT + F
vim.keymap.set("n", "<C-M-f>", "za", { desc = "Toggle folding" })

-- Toggle all foldings - CTRL + ALT + SHIFT + F
vim.keymap.set("n", "<C-M-S-f>", function()
    if vim.fn.foldclosed(".") == -1 then
        vim.cmd("normal! zM") -- Close all
    else
        vim.cmd("normal! zR") -- Open all
    end
end, { desc = "Toggle all foldings." })