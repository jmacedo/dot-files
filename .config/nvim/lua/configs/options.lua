-- Indent and tabulation.
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.autoindent = true
vim.o.copyindent = true
vim.o.smartindent = false
vim.o.smarttab = true

-- Window
vim.o.winborder = "rounded"
vim.o.signcolumn = "yes:1"
vim.o.showtabline = 2
vim.o.ruler = true
vim.o.rulerformat = "%l (%L):%c - %p%%"

-- Cursor
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.number = true
vim.o.relativenumber = false
vim.o.numberwidth = 2
vim.o.scrolloff = 10 -- Keep this many screen lines above/below the cursor.

-- Visual and formating
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.linebreak = true
vim.o.list = true ---- Show <tab> and trailing spaces.

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = true

-- Files and directories
vim.o.swapfile = false
vim.o.autochdir = false
vim.o.autoread = true
vim.o.autowrite = false
vim.o.confirm = true

-- Autocompĺete
vim.o.autocomplete = true

-- Folding
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldopen = "all"
vim.o.foldclose = "all"
vim.o.foldlevel = 99 -- All opened
vim.o.foldlevelstart = 0 -- All closed at startup
vim.o.foldtext = "getline(v:foldstart)" -- "foldtext()", "getline(v:foldstart)"
vim.o.foldcolumn = "1"

-- Mouse
vim.o.mouse = "a"
vim.o.mousefocus = true
vim.o.mousehide = true
vim.o.mousemodel = "popup_setpos"
vim.o.pumborder = "rounded"
vim.o.mousemoveevent = false
vim.o.mousescroll = "ver:4,hor:2"

-- Clipboard
vim.o.clipboard = "unnamed,unnamedplus"

-- Encoding
vim.o.fileencodings = "utf-8,default,latin1"