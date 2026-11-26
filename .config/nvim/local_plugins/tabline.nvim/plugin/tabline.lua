vim.api.nvim_create_user_command(
    "TablineNew",
    function()
        require("tabline").new_tab()
    end,
    {}
)

vim.api.nvim_create_user_command(
    "TablineClose",
    function()
        require("tabline").close_tab()
    end,
    {}
)

vim.api.nvim_create_user_command(
    "TablineNext",
    function()
        require("tabline").move_next_tab()
    end,
    {}
)

vim.api.nvim_create_user_command(
    "TablinePrevious",
    function()
        require("tabline").move_previous_tab()
    end,
    {}
)

vim.api.nvim_create_user_command(
    "TablineRename",
    function()
        require("tabline").rename_tab()
    end,
    {}
)