local M = {}

local set_hl = vim.api.nvim_set_hl

local default_colours = {
	foreground = "#cdd6f4",
	background = "#313244",
}

local function set_telescope_highlights(colours)
	set_hl(0, "TelescopeSelection", {
		foreground = colours.foreground,
		background = colours.background,
	})
end

local function set_nvimtree_highlights(colours)
	set_hl(0, "NvimTreeFolderArrowOpen", {
		foreground = colours.foreground,
	})
end

M.apply_highlights = function(opts)
	local colours = opts and opts.colours or default_colours
	set_telescope_highlights(colours)
	set_nvimtree_highlights(colours)
end

return M
