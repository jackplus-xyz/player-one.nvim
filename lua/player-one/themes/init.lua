local State = require("player-one.state")
local Utils = require("player-one.utils")

local M = {}

function M.setup()
	local theme = State.theme

	if not theme or theme == "" or theme == {} then
		return
	end

	if type(theme) ~= "table" and type(theme) ~= "string" then
		error("themes parameter must be a table or string")
	end

	State.curr_theme = theme
	Utils.load_theme(theme)
end

return M
