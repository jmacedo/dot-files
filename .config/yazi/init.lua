--init.lua

-- FULL BORDER PLUGIN
require("full-border"):setup {
	-- type => PLAIN, ROUNDED
	type = ui.Border.ROUNDED,
}

-- GIT PLUGIN
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

-- SMART ENTER PLUGIN
require("smart-enter"):setup {
	open_multi = true,
}

-- DEFAULT CUSTOM LINEMODE
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)

	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%d/%m/%Y %H:%M", time)
	else
		time = os.date("%d/%m/%Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end