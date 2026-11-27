Tabline = require("tabline")

Tabline.set_runtime({
    startup = {
        tabpage = vim.api.nvim_get_current_tabpage(),
        buffer = vim.api.nvim_get_current_buf(),
    },
})

Tabline.runtime.event_listeners.autocmd_group = vim.api.nvim_create_augroup(Tabline.config.event_listeners.autocmd_group, { clear = true, })

--[[
USER COMMANDS
--]]

vim.api.nvim_create_user_command("TablineNew", function()
    Tabline.new_tab()
end, { desc = "Create new tab", })

vim.api.nvim_create_user_command("TablineClose", function()
    Tabline.close_tab()
end, { desc = "Close current tab", })

vim.api.nvim_create_user_command("TablineNext", function()
    Tabline.move_next_tab()
end, { desc = "Select next tab", })

vim.api.nvim_create_user_command("TablinePrevious", function()
    Tabline.move_previous_tab()
end, { desc = "Select previous tab", })

vim.api.nvim_create_user_command("TablineRename", function()
    Tabline.rename_tab()
end, { desc = "Rename current tab", })

--[[
AUTO COMMANDS
]]--

-- Closes startup tab when empty and a new tab was opened.
local startup = vim.api.nvim_create_autocmd("BufEnter", {
    group = Tabline.runtime.event_listeners.autocmd_group,
    callback = function(args)
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
    end,
})
Tabline.runtime.autocmd.add({
    id = "autocmd_startup",
    autocmd_id = startup,
})

--[[
WinClosed callback arguments:
    - args.id: ID do autocmd
    - args.event: "WinClosed"
    - args.match: ID da janela fechada (string)
    - args.file: Mesmo ID da janela fechada
    - args.buf: Buffer associado ao evento, quando disponível
--]]

local close_empty_file_explorer = vim.api.nvim_create_autocmd("WinClosed", {
    group = Tabline.runtime.event_listeners.autocmd_group,
    callback = function(_)
        vim.schedule(function()
            local tabpage = vim.api.nvim_get_current_tabpage()
            local windows = vim.api.nvim_tabpage_list_wins(tabpage)

            if #windows ~= 1 then
                return
            end

            local buffer = vim.api.nvim_win_get_buf(windows[1])

            if vim.bo[buffer].filetype ~= "neo-tree" then
                return
            end

            if #vim.api.nvim_list_tabpages() > 1 then
                vim.cmd("tabclose")
            else
                vim.cmd("quit")
            end
        end)
    end,
})
Tabline.runtime.autocmd.add({
    id = "close_empty_file_explorer",
    autocmd_id = close_empty_file_explorer,
})