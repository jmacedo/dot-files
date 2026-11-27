return {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    opts = {
        event_handlers = {
            {
                event = "file_opened",
                handler = function(args)
                    local path = (args.filedata and args.filedata.path) or vim.fn.expand("%:p")

                    if path == "" then
                        return
                    end

                    local dir = vim.fs.dirname and vim.fs.dirname(path) or vim.fn.fnamemodify(path, ":h")

                    vim.schedule(function()
                        vim.cmd("Neotree dir=" .. vim.fn.fnameescape(dir) .. " focus")
                    end)
                end,
            },
        },
    },
    dependencies = {
        { "MunifTanjim/nui.nvim", },
        { "nvim-lua/plenary.nvim", },
        { "nvim-tree/nvim-web-devicons", },
        {
            "Crysthamus/nvim-file-operations",
            config = function ()
                require("nvim-file-operations").setup()
            end
        },
        {
            "3rd/image.nvim",
            build = false,
            opts = {
                processor = "magick_cli",
            },
        },
        {
            's1n7ax/nvim-window-picker',
            name = 'window-picker',
            event = 'VeryLazy',
            config = function()
                require("window-picker").setup()
            end,
        },
    },
}