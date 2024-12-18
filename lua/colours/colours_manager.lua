local M = {}

local api = vim.api
local utils = require("colours.utils")

-- @param opts table: Plugin options
M.apply_colours = function(opts)
	local ns_id = api.nvim_create_namespace("colour_ns")

	-- Default options
	local icon = opts.icon or " " -- Default Nerd Font icon
	local virt_text_pos = "inline"

	api.nvim_create_autocmd({
		"TextChanged",
		"TextChangedI",
		"TextChangedP",
		"VimResized",
		"LspAttach",
		"WinScrolled",
		"BufEnter",
	}, {
		pattern = "*",
		callback = function()
			local filetype = vim.bo.filetype
			api.nvim_buf_clear_namespace(0, ns_id, 0, -1) -- Clear all previous highlights

			local lines = api.nvim_buf_get_lines(0, 0, -1, false)

			for line_num, line in ipairs(lines) do
				local seen_positions = {} -- Prevent duplicate highlights at the same position

				for match, colour in utils.find_colours(line, filetype) do
					local col_start = line:find(match, 1, true) -- Find the start position
					if col_start and not seen_positions[col_start] then
						seen_positions[col_start] = true -- Mark this position as processed

						local colour_group = "Colour_" .. colour:gsub("[^%w]", "")
						api.nvim_set_hl(0, colour_group, { fg = colour })

						-- Add virtual text only once at each position
						api.nvim_buf_set_extmark(0, ns_id, line_num - 1, col_start - 1, {
							virt_text = { { icon, colour_group } },
							virt_text_pos = virt_text_pos,
						})
					end
				end
			end
		end,
	})
end

return M
