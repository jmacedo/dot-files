-- KEYMAPS
-- See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Terminal mode: Use <Esc> to exit
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Document manipulation
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>write<CR>', { desc = 'Save document' })
vim.keymap.set('n', '<C-q>', '<cmd>quit<CR>', { desc = 'Close document' })
vim.keymap.set('n', '<C-o>', ':<C-u>edit<Space>', { desc = 'Open' })

-- Tabs
vim.keymap.set('n', '<Leader>tn', '<cmd>tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<Leader>t<Left>', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
vim.keymap.set('n', '<Leader>t<Right>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '<Leader>t<Up>', '<cmd>silent! tabmove -1<CR>', { desc = 'Move tab to the left' })
vim.keymap.set('n', '<Leader>t<Down>', '<cmd>silent! tabmove +1<CR>', { desc = 'Move tab to the right' })