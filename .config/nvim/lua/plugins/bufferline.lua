local __return = {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers", -- "buffers" | "tabs"
                numbers = "ordinal", -- "ordinal" | "buffer_id" | "both" | "function()"
                right_mouse_command = nil,
                middle_mouse_command = "bdelete! %d",
                indicator = {
                    style = "icon", -- "icon" | "underline" | "none"
                },
                tabsize = 20,
                separator_style = "slant", -- "thin" | "thick" | "slant" | "padded_slant" | -- "slope" | "padded_slope" | { "left", "right" }
                show_buffer_icons = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_inidicators = true,
                show_duplicate_prefix = true,
                always_show_bufferline = false,
                persist_buffer_sort = true,
                sort_by = "insert_after_current", -- "id" | "insert_after_current" | "insert_at_end" | "extension" | "relative_directory" | "directory" | "tabs" | função
                diagnostics = "nvim_lsp",
            },
        })
    end,
}

local _return = {}
return _return