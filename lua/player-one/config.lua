--- Configuration module for PlayerOne
---@module 'player-one.config'

local Api = require("player-one.api")
local State = require("player-one.state")

local M = {}

---@type PlayerOneConfig
local defaults = {
	is_enabled = true,
	min_interval = 0.05,
	theme = "chiptune",
}

--- Setup PlayerOne with the provided configuration
---@param options? PlayerOneConfig Configuration table to override defaults
---@usage [[
--- # Basic setup with defaults
--- require('player-one').setup()
---
--- # Custom configuration
--- require('player-one').setup({
---   is_enabled = true,
---   theme = "crystal",
---   min_interval = 0.1
--- })
---
--- # Custom theme
--- require('player-one').setup({
---   theme = {
---     {
---       event = "TextChangedI",
---       sound = { wave_type = 1, base_freq = 440.0 },
---       callback = "play"
---     }
---   }
--- })
---]]
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})

	State.setup(M.options)
	Api.setup()

	if State.is_enabled then
		Api.enable()
	end

	return {
		setup = M.setup,

		play = Api.play,
		play_async = Api.play_async,
		append = Api.append,
		stop = Api.stop,

		load_theme = Api.load_theme,

		enable = Api.enable,
		disable = Api.disable,
		toggle = Api.toggle,
	}
end

return M
