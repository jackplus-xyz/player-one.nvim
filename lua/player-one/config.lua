--- Configuration module for PlayerOne
---@module 'player-one.config'

local Api = require("player-one.api")
local State = require("player-one.state")

local M = {}

---@type PlayerOne.Config
local defaults = {
	is_enabled = true,
	min_interval = 0.05,
	theme = "chiptune",
	binary = {
		auto_update = true,
		cache_timeout = 3600,
		download_timeout = 60,
		verify_checksum = true,
		use_development = true,
		github_api_token = nil,
		proxy = {
			url = nil,
			from_env = true,
		},
	},
}

--- Setup PlayerOne with the provided configuration
---@param options? PlayerOne.Config Configuration table to override defaults
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
	options = options or {}

	M.options = vim.tbl_deep_extend("force", defaults, options)

	State.setup(M.options)
	Api.setup()

	if State.is_enabled then
		Api.enable()
	end
end

---Reload the binary
---@return boolean success Whether reload succeeded
function M.reload_binary()
	local binary = require("player-one.binary")
	binary.clear_cache()
	return binary.load_binary() ~= nil
end

M.reload_binary = M.reload_binary

M.play = Api.play
M.play_async = Api.play_async
M.append = Api.append
M.stop = Api.stop

M.load_theme = Api.load_theme

M.enable = Api.enable
M.disable = Api.disable
M.toggle = Api.toggle

return M
