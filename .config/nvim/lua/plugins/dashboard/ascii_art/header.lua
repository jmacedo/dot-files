local M = {}

local header

function M.get()
    if header then
        return header
    end

    math.randomseed(tonumber(vim.uv.hrtime() % 2147483647))

    local images_dir = vim.fn.stdpath("config")
        .. "/lua/plugins/dashboard/ascii_art/images"
    local files = vim.fn.glob(images_dir .. "/*.ascii.art", false, true)

    header = {}

    if #files == 0 then
        return header
    end

    local file = files[math.random(#files)]

    for line in io.lines(file) do
        header[#header + 1] = line
    end

    return header
end

return M