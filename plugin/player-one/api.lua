local Utils = require("player-one.utils")
local State = require("player-one.state")

local M = {}

function M.enable()
	State.is_enabled = true
	Utils.start()
end

function M.disable()
	if State.is_enabled then
		State.is_enabled = false
	end
	Utils.stop()
end

function M.toggle()
	if State.is_enabled then
		M.disable()
	else
		M.enable()
	end
	vim.notify(string.format("**PlayerOne** %s", State.is_enabled and "enabled" or "disabled"))
end

return M
