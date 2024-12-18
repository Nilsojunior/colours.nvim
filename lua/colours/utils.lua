local M = {}

-- Table of CSS colour names and their equivalent hex values
local css_colours = require("colours.css_colours")

-- Match all colour formats and normalize to hex
M.find_colours = function(line, filetype)
	local patterns = {
		{
			"#%x%x%x%x%x%x",
			function(c)
				return c
			end,
		}, -- Full hex (#RRGGBB)
		{ "#%x%x%x", M.expand_short_hex }, -- Short hex (#RGB)
		{ "rgb%(%d+,%s?%d+,%s?%d+%)", M.rgb_to_hex }, -- RGB format
		{ "rgba%(%d+,%s?%d+,%s?%d+,%s?[%d%.]+%)", M.rgba_to_hex }, -- RGBA format
		{ "hsl%(%d+,%s?%d+%%,%s?%d+%%%)", M.hsl_to_hex }, -- HSL format
	}

	-- Add CSS colour names only for CSS or HTML files
	if filetype == "css" or filetype == "html" then
		table.insert(patterns, { "%a+", M.colour_name_to_hex })
	end

	return coroutine.wrap(function()
		for _, pattern in ipairs(patterns) do
			for match in string.gmatch(line, pattern[1]) do
				local colour = pattern[2](match)
				if colour then
					coroutine.yield(match, colour)
				end
			end
		end
	end)
end

-- Expand short hex (#RGB) to full hex (#RRGGBB)
M.expand_short_hex = function(hex)
	local r, g, b = hex:sub(2, 2), hex:sub(3, 3), hex:sub(4, 4)
	return string.format("#%s%s%s%s%s%s", r, r, g, g, b, b)
end

-- Convert rgb(r, g, b) to hex (#RRGGBB)
M.rgb_to_hex = function(rgb)
	local r, g, b = rgb:match("(%d+),%s?(%d+),%s?(%d+)")
	if r and g and b then
		return string.format("#%02X%02X%02X", r, g, b)
	end
	return nil
end

-- Convert rgba(r, g, b, a) to hex (ignores alpha for highlights)
M.rgba_to_hex = function(rgba)
	local r, g, b = rgba:match("(%d+),%s?(%d+),%s?(%d+),%s?[%d%.]+")
	if r and g and b then
		return string.format("#%02X%02X%02X", r, g, b)
	end
	return nil
end

-- Convert hsl(h, s%, l%) to hex (#RRGGBB)
M.hsl_to_hex = function(hsl)
	local h, s, l = hsl:match("(%d+),%s?(%d+)%%,%s?(%d+)%%")
	if h and s and l then
		h, s, l = tonumber(h), tonumber(s) / 100, tonumber(l) / 100
		local function hue_to_rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		local r = hue_to_rgb(p, q, h / 360 + 1 / 3)
		local g = hue_to_rgb(p, q, h / 360)
		local b = hue_to_rgb(p, q, h / 360 - 1 / 3)

		return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
	end
	return nil
end

-- Convert CSS colour names to their hex values
M.colour_name_to_hex = function(name)
	local lowercase_name = name:lower()
	return css_colours[lowercase_name]
end

return M
