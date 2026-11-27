local M = {}

M.config = {
    indicators = {
        empty_name = "[No name]",
        modified_char = " +",
        close_tab_char = " X",
    },
    theme = nil, -- Definido por require("tabline").setup({ theme = ... })
    event_listeners = {
        autocmd_group = "TablineListeners",
    },
}

M.runtime = {
    startup = {
        tabpage = nil,
        buffer = nil,
    },
    autocmd = {
        list = {
            { id = nil, autocmd_id = nil },
        },
    },
    event_listeners = {
        autocmd_group = nil,
    },
}

function M.setup(custom_configs)
    M.config = vim.tbl_extend("force",
        {},
        M.config,
        custom_configs or {}
    )

    M.apply_highlights()

    _G.NativeTabline = M._render
    vim.o.tabline = "%!v:lua.NativeTabline()"
end

function M.apply_highlights()
    local theme = M.config.theme
    if not theme then
        return
    end

    vim.api.nvim_set_hl(0, "TabLine", { fg = theme.inactive_tabs.fg, bg = theme.inactive_tabs.bg })
    vim.api.nvim_set_hl(0, "TabLineSel", { fg = theme.current_tab.fg, bg = theme.current_tab.bg, bold = true })
    vim.api.nvim_set_hl(0, "TabLineFill", { fg = theme.fill.fg, bg = theme.fill.bg })
end

function M.set_default_config(cfg)
    M.config = vim.tbl_extend("force",
        {},
        M.config,
        cfg or {}
    )
end

function M.set_runtime(custom_runtime)
    M.runtime = vim.tbl_extend("force",
        {},
        M.runtime,
        custom_runtime or {}
    )
end

function M.runtime.startup_buffer_is_still_present()
    if not vim.api.nvim_tabpage_is_valid(M.runtime.startup.tabpage) then
        return false
    end

    for _, window in ipairs(vim.api.nvim_tabpage_list_wins(M.runtime.startup.tabpage)) do
        if vim.api.nvim_win_get_buf(window) == M.runtime.startup.buffer then
            return true
        end
    end

    return false
end

function M.runtime.startup_buffer_is_empty()
    if not vim.api.nvim_buf_is_valid(M.runtime.startup.buffer) then
        return false
    end

    return vim.bo[M.runtime.startup.buffer].buftype == ""
        and vim.api.nvim_buf_get_name(M.runtime.startup.buffer) == ""
        and not vim.bo[M.runtime.startup.buffer].modified
        and vim.api.nvim_buf_line_count(M.runtime.startup.buffer) == 1
        and vim.api.nvim_buf_get_lines(M.runtime.startup.buffer, 0, 1, false)[1] == ""
end

function M.runtime.autocmd.add(autocmd)
    table.insert(M.runtime.autocmd.list,
        vim.tbl_extend("force",
            { id = nil, autocmd_id = nil, },
            autocmd or {}
        )
    )
end

function M.runtime.autocmd.remove(id)
    for autocmd_index, autocmd in ipairs(M.runtime.autocmd.list) do
        if id == autocmd.id then
            table.remove(M.runtime.autocmd.list, autocmd_index)

            return true
        end
    end

    return false
end

function M.runtime.autocmd.get(id)
    for _, autocmd in ipairs(M.runtime.autocmd.list) do
        if autocmd.id == id then
            return autocmd
        end
    end

    return nil
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
        table.insert(result, string.format("%%=%%#TabLine#%%999X %s%%T", M.config.indicators.close_tab_char))
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

function M._get_tab_buffer(tabpage)
    local current_window = vim.api.nvim_tabpage_get_win(tabpage)
    local current_buffer = vim.api.nvim_win_get_buf(current_window)

    if vim.bo[current_buffer].filetype ~= "neo-tree" then
        return current_buffer
    end

    for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        local buffer = vim.api.nvim_win_get_buf(window)

        if vim.bo[buffer].filetype ~= "neo-tree"
            and vim.bo[buffer].buftype == "" then
            return buffer
        end
    end

    return current_buffer
end

function M._get_tab_label(tabpage)
    local ok, custom_name = pcall(
        vim.api.nvim_tabpage_get_var,
        tabpage,
        "tabline_name"
    )

    if ok and custom_name ~= "" then
        return custom_name
    end

    local buffer_id = M._get_tab_buffer(tabpage)

    local buffer_name = M._get_buffer_name(buffer_id)
    local modified_str = vim.bo[buffer_id].modified and M.config.indicators.modified_char or ""

    local windows_list = vim.api.nvim_tabpage_list_wins(tabpage)
    local window_count_str = #windows_list > 1
        and string.format(" [%d]", #windows_list)
        or ""

    -- Escapes tabline escapes.
    buffer_name = buffer_name:gsub("%%", "%%%%")

    return string.format("%s%s%s", buffer_name, modified_str, window_count_str)
end

function M.new_tab(buffer_id)
    if buffer_id == nil then
        vim.cmd("tabnew")
    else
        vim.cmd("tab sbuffer " .. buffer_id)
    end

    return vim.api.nvim_get_current_tabpage()
end

function M.select_tab(buffer_id)
    if buffer_id == nil then
        return
    end

    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
            if vim.api.nvim_win_get_buf(window) == buffer_id then
                vim.api.nvim_set_current_tabpage(tabpage)

                return vim.api.nvim_get_current_tabpage()
            end
        end
    end
end

function M.close_tab(buffer_id)
    if buffer_id == nil then
        if #vim.api.nvim_list_tabpages() == 1 then
            vim.cmd("quit")
        else
            vim.cmd("tabclose")
        end
    else
        local tabpages_list = vim.api.nvim_list_tabpages()

        for _, tabpage in ipairs(tabpages_list) do
            local windows_list = vim.api.nvim_tabpage_list_wins(tabpage)

            for _, window in ipairs(windows_list) do
                local bufnr = vim.api.nvim_win_get_buf(window)

                if bufnr == buffer_id then
                    if #windows_list > 1 then
                        vim.api.nvim_win_close(window, true)
                    else
                        if #tabpages_list == 1 then
                            vim.cmd("quit")
                        else
                            vim.api.nvim_set_current_tabpage(tabpage)
                            vim.cmd("tabclose")
                        end
                    end
                else if #windows_list == 2 and vim.bo[bufnr].filetype == "neo-tree" then
                    if #tabpages_list == 1 then
                            vim.cmd("quit")
                        else
                            vim.api.nvim_set_current_tabpage(tabpage)
                            vim.cmd("tabclose")
                        end
                    end
                end
            end
        end
    end
end

function M.move_next_tab()
    vim.cmd("tabnext")

    return vim.api.nvim_get_current_tabpage()
end

function M.move_previous_tab()
    vim.cmd("tabprevious")

    return vim.api.nvim_get_current_tabpage()
end

function M.select_tab(index)
    local tabpage = vim.api.nvim_list_tabpages()[index]

    if not tabpage then
        vim.notify("Tab " .. index .. " does not exist.", vim.log.levels.WARN)
        return nil
    end

    vim.api.nvim_set_current_tabpage(tabpage)
    return tabpage
end

function M.move_tab(direction)
    local step = direction == "forward" and "+1" or "-1"

    vim.cmd("tabmove " .. step)
    vim.cmd("redrawtabline")

    return vim.api.nvim_get_current_tabpage()
end

function M.rename_tab()
    local tabpage = vim.api.nvim_get_current_tabpage()

    local ok, current_name = pcall(
        vim.api.nvim_tabpage_get_var,
        tabpage,
        "tabline_name"
    )

    vim.ui.input(
        {
            prompt = "Rename tab: ",
            default = ok and current_name or "",
        },
        function(name)
            if name == nil then
                return
            end

            if name == "" then
                pcall(vim.api.nvim_tabpage_del_var, tabpage, "tabline_name")
            else
                vim.api.nvim_tabpage_set_var(tabpage, "tabline_name", name)
            end

            vim.cmd("redrawtabline")
        end
    )
end

return M