local M = {}

M.config = {
    indicators = {
        empty_name = "[No name]",
        modified_char = " +",
    },
    theme = {
        current_tab = {
            fg = "#ffffff",
            bg = "#444444",
        },
        inactive_tabs = {
            fg = "#888888",
            bg = "#202020",
        },
        fill = {
            fg = "#666666",
            bg = "#181818",
        },
    },
}

function M.setup(custom_configs)
    M.config = vim.tbl_extend("force",
        {},
        M.config,
        custom_configs or {}
    )

    vim.api.nvim_set_hl(0, "TabLine", { fg = M.config.theme.inactive_tabs.fg, bg = M.config.theme.inactive_tabs.bg, })
    vim.api.nvim_set_hl(0, "TabLineSel", { fg = M.config.theme.current_tab.fg, bg = M.config.theme.current_tab.bg, bold = true, })
    vim.api.nvim_set_hl(0, "TabLineFill", { fg = M.config.theme.fill.fg, bg = M.config.theme.fill.bg, })

    _G.NativeTabline = M._render
    vim.o.tabline = "%!v:lua.NativeTabline()"
end

function M._render()
    local current_tabpage = vim.api.nvim_get_current_tabpage()
    local tabpages_list = vim.api.nvim_list_tabpages()
    local result = {}

    for tab_index, tabpage in ipairs(tabpages_list) do
        local highlight = tabpage == current_tabpage
            and "%#TabLineSel#"
            or "%#TabLine#"

        -- Active/Inactive tab
        table.insert(result, highlight)

        -- Clickable tab
        table.insert(result, string.format("%%%dT", tab_index))

        -- Tab index
        table.insert(result, string.format(" %d: ", tab_index))

        -- Tab name
        table.insert(result, string.format("%s", M._get_tab_label(tabpage)))

        -- Tab closing
        table.insert(result, "%=%#TabLine#%999X X%T")
    end

    table.insert(result, "%#TabLineFill#")

    return table.concat(result)
end

function M._get_buffer_name(buffer_id)
        local name = vim.api.nvim_buf_get_name(buffer_id)

    if name == "" then
        return M.config.indicators.empty_name
    end

    -- Shows only file name, no paths.
    return vim.fn.fnamemodify(name, ":t")
end

function M._get_tab_label(tabpage)
    local window = vim.api.nvim_tabpage_get_win(tabpage)
    local buffer_id = vim.api.nvim_win_get_buf(window)

    local buffer_name = M._get_buffer_name(buffer_id)
    local modified_str = vim.bo[buffer_id].modified and M.config.indicators.modified_char or ""

    local windows_list = vim.api.nvim_tabpage_list_wins(tabpage)
    local window_count_str = #windows_list > 1
        and string.format(" [%d]", #windows_list)
        or ""

    -- Escapes tabline escapes.
    buffer_name = buffer_name:gsub("%%", "%%%%")

    return buffer_name .. modified_str .. window_count_str
end

function M.new_tab()
    vim.cmd("tabnew")

    return vim.api.nvim_get_current_tabpage()
end

function M.close_tab()
    vim.cmd("tabclose")
end

function M.move_next_tab()
    vim.cmd("tabnext")

    return vim.api.nvim_get_current_tabpage()
end

function M.move_previous_tab()
    vim.cmd("tabprevious")

    return vim.api.nvim_get_current_tabpage()
end

function M.rename_tab()
    -- TODO: Not implemented yet.
end

return M