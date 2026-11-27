Tabline = require("tabline")

Tabline.set_runtime({
    startup = {
        tabpage = vim.api.nvim_get_current_tabpage(),
        buffer = vim.api.nvim_get_current_buf(),
    },
})

--[[
USER COMMANDS
--]]

vim.api.nvim_create_user_command("TablineNew", function()
    Tabline.new_tab()
end, {})

vim.api.nvim_create_user_command("TablineClose", function()
    Tabline.close_tab()
end, {})

vim.api.nvim_create_user_command("TablineNext", function()
    Tabline.move_next_tab()
end, {})

vim.api.nvim_create_user_command("TablinePrevious", function()
    Tabline.move_previous_tab()
end, {})

vim.api.nvim_create_user_command("TablineRename", function()
    Tabline.rename_tab()
end, {})

--[[
AUTO COMMANDS
Arguments passed to the autocmd event (args):
    - args.event: Event name (eg. BufAdd).
    - args.buf: Associated buffer ID.
    - args.file: File name associated.
    - args.match: Value associated with the event.
]]--

-- Closes startup tab when empty and a new tab was opened.
vim.api.nvim_create_autocmd("BufEnter", { callback = function(args)
    if not Tabline.startup.tabpage then
        return
    end

    if vim.bo[args.buf].buftype ~= "" then
        return
    end

    if vim.api.nvim_buf_get_name(args.buf) == "" then
        return
    end

    vim.schedule(function()
        if not vim.api.nvim_tabpage_is_valid(Tabline.startup.tabpage) then
            return
        end

        if Tabline.startup.tabpage == vim.api.nvim_get_current_tabpage() then
            return
        end

        if #vim.api.nvim_list_tabpages() <= 1 then
            return
        end

        if not Tabline.runtime.startup_buffer_is_still_present() then
            return
        end

        if not Tabline.runtime.startup_buffer_is_empty() then
            return
        end

        vim.api.nvim_tabpage_close(Tabline.startup.tabpage, false)
    end)
end, })