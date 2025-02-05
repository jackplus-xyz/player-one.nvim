local Autocmd = require("player-one.autocmd")
local State = require("player-one.state")
local Utils = require("player-one.utils")

local M = {}

-- TODO: add error handling for public APIs
function M.enable()
	State.is_enabled = true
	-- TODO: handle preset loading
	if State.preset and State.preset ~= "" and State.preset ~= "none" then
		Autocmd.setup(State.preset)
	end
end

-- TODO: add proper cleanup
-- - Stop all playing sounds
-- - Clear sound queue
-- - Remove event listeners
-- - Free resources
function M.disable()
	State.is_enabled = false
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

function M.play(params)
	Utils.play(params)
end

function M.stop()
	Utils.stop()
end

-- TODO: add api to play internal presets & sfxr presets

return M
