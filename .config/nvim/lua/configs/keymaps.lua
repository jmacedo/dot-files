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
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text." })

-- Select word - CTRL + P
vim.keymap.set("n", "<C-p>", "viw", { desc = "Select the word under cursor." })

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

-- Seleção com SHIFT / SHIFT+CTRL (normal + visual).
local selection_motions = {
    { "<S-Left>", "<Left>" },
    { "<S-Right>", "<Right>" },
    { "<S-Up>", "<Up>" },
    { "<S-Down>", "<Down>" },
    { "<S-C-Left>", "<C-Left>" },
    { "<S-C-Right>", "<C-Right>" },
    { "<S-Home>", "<Home>" },
    { "<S-End>", "<End>" },
    { "<S-C-Home>", "<C-Home>" },
    { "<S-C-End>", "<C-End>" },
}

for _, motion in ipairs(selection_motions) do
    local key, move = motion[1], motion[2]
    vim.keymap.set("n", key, "v" .. move, { desc = "Start visual selection: " .. key })
    vim.keymap.set("v", key, move, { desc = "Extend visual selection: " .. key })
end

-- Toggle folding - Leader + z (lowercase)
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle folding" })

-- Toggle all foldings - Leader + Z (uppercase)
vim.keymap.set("n", "<leader>Z", function()
    if vim.wo.foldlevel > 0 then
        vim.cmd("normal! zM")
    else
        vim.cmd("normal! zR")
    end
end, { desc = "Toggle all foldings." })

-- Abas (tabs)
vim.keymap.set("n", "<leader>tn", "<cmd>TablineNew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tq", "<cmd>TablineClose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>tr", "<cmd>TablineRename<CR>", { desc = "Rename tab" })

-- Navegação (kitty → nvim): CTRL + PageUp/PageDown.
vim.keymap.set("n", "<C-PageUp>", "<cmd>TablinePrevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<C-PageDown>", "<cmd>TablineNext<CR>", { desc = "Next tab" })

-- Movimentação: CTRL + SHIFT + CMD + PageUp/PageDown.
vim.keymap.set("n", "<C-D-S-PageUp>", "<cmd>TablineMoveBackward<CR>", { desc = "Move tab backward" })
vim.keymap.set("n", "<C-D-S-PageDown>", "<cmd>TablineMoveForward<CR>", { desc = "Move tab forward" })

-- Seleção direta: CTRL + CMD + [1-9] ou <leader>t[1-9].
for i = 1, 9 do
    local desc = "Go to tab " .. i
    vim.keymap.set("n", "<C-D-" .. i .. ">", "<cmd>TablineSelect " .. i .. "<CR>", { desc = desc })
    vim.keymap.set("n", "<leader>t" .. i, "<cmd>TablineSelect " .. i .. "<CR>", { desc = desc })
end
