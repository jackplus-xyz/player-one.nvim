--- Configuration module for PlayerOne
---@module 'player-one.config'

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
	debug = false,
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
	M.options = vim.deepcopy(defaults)
	M.options = vim.tbl_deep_extend("force", M.options, options)

	local State = require("player-one.state")
	local Api = require("player-one.api")
	State.setup(M.options)
	Api.setup()
	setmetatable(M, Api)

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

return M
