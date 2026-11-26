local M = {}

local colors = {
    "#F5C2E7", -- Rosa
    "#CBA6F7", -- Roxo
    "#B4BEFE", -- Lavanda
    "#89B4FA", -- Azul
}

local function hex_to_rgb(hex)
    return {
        tonumber(hex:sub(2, 3), 16),
        tonumber(hex:sub(4, 5), 16),
        tonumber(hex:sub(6, 7), 16),
    }
end

local function rgb_to_hex(rgb)
    return string.format(
        "#%02X%02X%02X",
        rgb[1], rgb[2], rgb[3]
    )
end

local function interpolate(a, b, t)
    local rgb_a = hex_to_rgb(a)
    local rgb_b = hex_to_rgb(b)
    local result = {}

    for i = 1, 3 do
        result[i] = math.floor(
            rgb_a[i] + (rgb_b[i] - rgb_a[i]) * t
        )
    end

    return rgb_to_hex(result)
end

local function get_gradient_color(index, total)
    local position = (index - 1) / math.max(total - 1, 1)
    local segments = #colors - 1
    local segment = math.min(
        math.floor(position * segments) + 1,
        segments
    )

    local local_t = position * segments - (segment - 1)

    return interpolate(
        colors[segment],
        colors[segment + 1],
        local_t
    )
end

function M.apply(buf, header)
    local ns = vim.api.nvim_create_namespace("DashboardGradient")
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    for i, art_line in ipairs(header) do
        for row, buffer_line in ipairs(lines) do
            local start_col = buffer_line:find(art_line, 1, true)

            if start_col then
                local group = "DashboardGradient" .. i
                local color = get_gradient_color(i, #header)

                vim.api.nvim_set_hl(0, group, {
                    fg = color,
                    bold = true,
                })

                vim.api.nvim_buf_set_extmark(
                    buf,
                    ns,
                    row - 1,
                    start_col - 1,
                    {
                        end_col = start_col - 1 + #art_line,
                        hl_group = group,
                        priority = 200,
                    }
                )

                break
            end
        end
    end
end

return M