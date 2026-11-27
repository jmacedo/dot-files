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
local autocmd_startup = vim.api.nvim_create_autocmd("BufEnter", { callback = function(args)
    if not Tabline.runtime.startup.tabpage then
        return
    end

    if vim.bo[args.buf].buftype ~= "" then
        return
    end

    vim.schedule(function()
        if not vim.api.nvim_tabpage_is_valid(Tabline.runtime.startup.tabpage) then
            return
        end

        if Tabline.runtime.startup.tabpage == vim.api.nvim_get_current_tabpage() then
            return
        end

        if #vim.api.nvim_list_tabpages() <= 1 then
            return
        end

        if not Tabline.runtime.startup_buffer_is_still_present() then
            return
        end

        local autocmd_startup = Tabline.runtime.autocmd.get("autocmd_startup")

        if autocmd_startup ~= nil then
            vim.api.nvim_del_autocmd(autocmd_startup.autocmd_id)
            Tabline.runtime.autocmd.remove("autocmd_startup")
            Tabline.set_runtime({ startup = { tabpage = nil, buffer = nil, }, })
        end

        vim.api.nvim_set_current_tabpage(Tabline.runtime.startup.tabpage)
        vim.cmd("tabclose")
    end)
end, })
Tabline.runtime.autocmd.add({
    id = "autocmd_startup",
    autocmd_id = autocmd_startup,
})