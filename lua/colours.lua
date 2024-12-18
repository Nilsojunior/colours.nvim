local M = {}

local colours_manager = require("colours.colours_manager")
local highlights = require("colours.highlights")

--- Setup function to configure the plugin
M.setup = function(opts)
	opts = opts or {}

	colours_manager.apply_colours(opts)
	highlights.apply_highlights(opts)
end

return M
