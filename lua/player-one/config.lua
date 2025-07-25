--- Configuration and state management module for PlayerOne
--- Maintains global configuration and plugin state
---@module 'player-one.config'
---@usage [[
---# Access plugin configuration and state
---local Config = require("player-one.config")
---print(Config.is_enabled) -- Check if plugin is enabled
---print(Config.curr_theme) -- Get current theme
---]]

local M = {}

---@type PlayerOne.Config
local defaults = {
	is_enabled = true,
	min_interval = 0.05,
	theme = "chiptune",
	master_volume = 0.5,
	theme_config = {
		-- Only specify sounds you want to disable
		-- All sounds are enabled by default
	},
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

-- Available built-in themes
---@type string[] List of available theme names
M.themes = { "chiptune", "synth", "crystal" }

--- Check if a sound event is enabled for the current theme
---@param event string The event name to check
---@return boolean enabled Whether the event should play sounds
function M.is_sound_enabled(event)
	if not M.is_enabled then
		return false
	end

	-- Get current theme name
	local current_theme = M.curr_theme or M.theme
	if type(current_theme) == "table" then
		-- Custom theme - default to enabled
		return true
	end

	-- Check theme-specific toggle (only if explicitly set to false)
	if M.theme_config[current_theme] and M.theme_config[current_theme][event] == false then
		return false
	end

	-- Default to enabled (all sounds enabled unless explicitly disabled)
	return true
end

-- Internal state properties
---@type boolean Whether cursor movement sounds are enabled
M._is_cursormoved_enabled = false

---@type number|nil Autocmd group ID
M.group = nil

---@type string|table Current theme name or custom theme table
M.curr_theme = nil

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

	-- Copy options to top level for direct access
	for k, v in pairs(M.options) do
		M[k] = v
	end

	-- Handle master_volume validation
	if options.master_volume ~= nil then
		M.master_volume = math.max(0.0, math.min(1.0, options.master_volume))
	end

	-- Handle theme setup
	if options.theme then
		M.curr_theme = options.theme
	end

	-- Add user theme if a custom theme table was provided
	if type(options.theme) == "table" then
		table.insert(M.themes, "user")
	end

	-- Create autocmd group for plugin events
	---@type number Autocmd group ID
	M.group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

	local Api = require("player-one.api")
	Api.setup()
	setmetatable(M, Api)

	if M.is_enabled then
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
