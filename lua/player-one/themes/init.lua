local Config = require("player-one.config")
local Utils = require("player-one.utils")

local M = {}

function M.setup()
	local theme = Config.theme

	if not theme or theme == "" or theme == {} then
		return
	end

	if type(theme) ~= "table" and type(theme) ~= "string" then
		error("themes parameter must be a table or string")
	end

	Config.curr_theme = theme
	Utils.load_theme(theme)
end

return M
