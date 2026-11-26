local M = {}

local function buffer_name(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)

    if name == "" then
        return "[No Name]"
    end

    -- Shows only file name, no paths.
    return vim.fn.fnamemodify(name, ":t")
end

local function tab_label(tabpage)
    local win = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(win)

    local name = buffer_name(bufnr)
    local modified = vim.bo[bufnr].modified and " +" or ""

    local windows = vim.api.nvim_tabpage_list_wins(tabpage)
    local window_count = #windows > 1
        and string.format(" [%d]", #windows)
        or ""

    -- AI: Escapa o caractere usado pelo formato da tabline.
    name = name:gsub("%%", "%%%%")

    return name .. modified .. window_count
end

function M.render()
    local current_tabpage = vim.api.nvim_get_current_tabpage()
    local tabpages = vim.api.nvim_list_tabpages()
    local result = {}

    for index, tabpage in ipairs(tabpages) do
        local highlight = tabpage == current_tabpage
            and "%#TabLineSel#"
            or "%#TabLine#"

        -- AI: Permite clicar na tabpage correspondente.
        table.insert(result, highlight)
        table.insert(result, string.format("%%%dT", index))
        table.insert(result, string.format(" %d: %s ", index, tab_label(tabpage)))
    end

    -- AI: Preenche o espaço restante da tabline.
    table.insert(result, "%#TabLineFill#")
    table.insert(result, "%T")

    return table.concat(result)
end

_G.NativeTabline = M.render

vim.o.showtabline = 2
vim.api.nvim_set_hl(0, "TabLine", {
    fg = "#888888",
    bg = "#202020",
})

vim.api.nvim_set_hl(0, "TabLineSel", {
    fg = "#ffffff",
    bg = "#444444",
    bold = true,
})

vim.api.nvim_set_hl(0, "TabLineFill", {
    fg = "#666666",
    bg = "#181818",
})
vim.o.tabline = "%!v:lua.NativeTabline()"

return M