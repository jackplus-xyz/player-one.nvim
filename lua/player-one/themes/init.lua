local Config = require("player-one.config")
local Utils = require("player-one.utils")

local M = {}

function M.setup()
	-- Prioritize Config.curr_theme (set by M.load_theme or initial options.theme)
	-- Fall back to Config.theme (initial options.theme or default from config)
	local theme_to_load = Config.curr_theme or Config.theme

	if not theme_to_load then
		-- No theme specified or configured, so nothing to load.
		return
	end

	-- Handle empty theme specification (e.g. empty string or empty table)
	if theme_to_load == "" or (type(theme_to_load) == "table" and vim.tbl_isempty(theme_to_load)) then
		return
	end

	if type(theme_to_load) ~= "table" and type(theme_to_load) ~= "string" then
		vim.notify("PlayerOne: Theme to load must be a table or string, got " .. type(theme_to_load), vim.log.levels.ERROR)
		return
	end

	Utils.load_theme(theme_to_load)
end

return M
