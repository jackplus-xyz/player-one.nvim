local Utils = require("player-one.utils")
local State = require("player-one.state")

local M = {}

-- TODO: add error handling for public APIs
-- Add error types and messages
-- Implement error recovery strategies
-- Add friendly error messages for users
function M.enable()
	State.is_enabled = true
	Utils.start()
end

-- TODO: add proper cleanup
-- Stop all playing sounds
-- Clear sound queue
-- Remove event listeners
-- Free resources
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

-- TODO: expose api for playing sounds
function M.play(params)
	Utils.play(params)
end

function M.stop()
	Utils.stop()
end

-- TODO: add api to play internal presets & sfxr presets

return M
