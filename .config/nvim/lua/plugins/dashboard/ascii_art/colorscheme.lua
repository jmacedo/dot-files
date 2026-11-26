local M = {}

-- O dashboard-nvim aplica DashboardHeader com prioridade 4096
-- (nvim_buf_add_highlight). O gradiente precisa ficar acima disso.
local PRIORITY = 4097

local fallback = { "#F5C2E7", "#CBA6F7", "#B4BEFE", "#89B4FA" }

local function palette()
    local ok, p = pcall(function()
        return require("catppuccin.palettes").get_palette()
    end)

    if ok and type(p) == "table" and p.pink and p.mauve and p.lavender and p.blue then
        return { p.pink, p.mauve, p.lavender, p.blue }
    end

    return fallback
end

local function hex_to_rgb(hex)
    return {
        tonumber(hex:sub(2, 3), 16),
        tonumber(hex:sub(4, 5), 16),
        tonumber(hex:sub(6, 7), 16),
    }
end

local function interpolate(a, b, t)
    local ca, cb = hex_to_rgb(a), hex_to_rgb(b)
    local result = {}

    for i = 1, 3 do
        result[i] = math.floor(ca[i] + (cb[i] - ca[i]) * t)
    end

    return string.format("#%02X%02X%02X", result[1], result[2], result[3])
end

-- `steps` cores distribuídas uniformemente entre as cores da paleta.
local function gradient(steps)
    local colors = palette()
    local result = {}

    if steps <= 0 then
        return result
    end

    if steps == 1 then
        return { colors[1] }
    end

    local segments = #colors - 1

    for i = 1, steps do
        local pos = (i - 1) / (steps - 1) * segments
        local segment = math.min(math.floor(pos) + 1, segments)

        result[i] = interpolate(
            colors[segment],
            colors[segment + 1],
            pos - (segment - 1)
        )
    end

    return result
end

local function trim(line)
    return (line:match("^%s*(.-)%s*$"))
end

function M.apply(buf, header)
    local ns = vim.api.nvim_create_namespace("DashboardGradient")
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    -- Mapeia o conteúdo visível de cada linha da arte para a sua ordem.
    local art_index = {}
    local art_order = {}

    for i, line in ipairs(header) do
        local text = trim(line)

        if text ~= "" then
            art_index[text] = art_index[text] or i
            art_order[#art_order + 1] = i
        end
    end

    if #art_order == 0 then
        return
    end

    local step = {}
    for position, i in ipairs(art_order) do
        step[i] = position
    end

    local colors = gradient(#art_order)

    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local text = trim(line)
        local i = art_index[text]

        if i then
            local start_col = line:find(text, 1, true)
            local group = "DashboardGradient" .. step[i]

            vim.api.nvim_set_hl(0, group, {
                fg = colors[step[i]],
                bold = true,
            })

            vim.api.nvim_buf_set_extmark(buf, ns, row - 1, start_col - 1, {
                end_col = start_col - 1 + #text,
                hl_group = group,
                priority = PRIORITY,
            })
        end
    end
end

return M