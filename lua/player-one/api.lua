local Themes = require("player-one.themes")
local State = require("player-one.state")
local Utils = require("player-one.utils")

local M = {}

-- TODO: add error handling for public APIs
function M.enable()
	State.is_enabled = true
	Themes.setup()
end

function M.disable()
	State.is_enabled = false
	Utils.clear_autocmds()
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

function M.load_theme(theme)
	Utils.load_theme(theme)
end

-- TODO: add api to play internal presets & sfxr presets

return M
