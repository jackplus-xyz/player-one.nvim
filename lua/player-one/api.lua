local Themes = require("player-one.themes")
local State = require("player-one.state")
local Utils = require("player-one.utils")

--- Player One API module
--- Provides the core functionality for sound playback and plugin control
---@module 'player-one.api'
local M = {}

local function handle_error(ok, err)
	if not ok then
		-- Clean up the error message from Rust/FFI
		local msg = tostring(err):gsub("^.*:%d+:%s*", "")
		vim.notify("PlayerOne: " .. msg, vim.log.levels.ERROR)
		return false
	end
	return true
end

---Play a sound immediately, interrupting any currently playing sounds
---@param params SoundParams Sound parameters
---@return boolean|nil success Whether the sound was played successfully
function M.play(params)
	if not State.is_enabled then
		return
	end
	local ok, err = pcall(Utils.play, params)
	return handle_error(ok, err)
end

---Queue a sound to play after current sounds finish
---@param params SoundParams Sound parameters
---@return boolean|nil success Whether the sound was queued successfully
function M.append(params)
	if not State.is_enabled then
		return
	end
	local ok, err = pcall(Utils.append, params)
	return handle_error(ok, err)
end

---Play a sound and wait for it to complete
---@param params SoundParams Sound parameters
---@return boolean|nil success Whether the sound was played successfully
function M.play_async(params)
	if not State.is_enabled then
		return
	end
	local ok, err = pcall(Utils.play_async, params)
	return handle_error(ok, err)
end

---Stop all currently playing sounds
---@return boolean|nil success Whether the stop operation succeeded
function M.stop()
	if not State.is_enabled then
		return
	end
	local ok, err = pcall(Utils.stop)
	return handle_error(ok, err)
end

---Load a sound theme
---@param theme string|PlayerOneTheme|nil Theme name or custom theme table
---@return boolean|nil success Whether the theme was loaded successfully
function M.load_theme(theme)
	if not State.is_enabled then
		return
	end
	local ok, err = pcall(Utils.load_theme, theme)
	return handle_error(ok, err)
end

---Enable the plugin
---@return boolean success Whether enable succeeded
function M.enable()
	local ok, err = pcall(function()
		State.is_enabled = true
		Themes.setup()
	end)
	return handle_error(ok, err)
end

---Disable the plugin and stop all sounds
---@return boolean success Whether disable succeeded
function M.disable()
	local ok, err = pcall(function()
		State.is_enabled = false
		Utils.clear_autocmds()
		Utils.stop()
	end)
	return handle_error(ok, err)
end

---Toggle the plugin enabled state
function M.toggle()
	if State.is_enabled then
		M.disable()
		vim.notify("Disabled Player One", vim.log.levels.INFO)
	else
		M.enable()
		vim.notify("Enabled Player One", vim.log.levels.INFO)
	end
end

-- TODO: add api to play internal presets & sfxr presets

function M.setup()
	vim.api.nvim_create_user_command("PlayerOneEnable", M.enable, { desc = "Enable Player One" })
	vim.api.nvim_create_user_command("PlayerOneDisable", M.disable, { desc = "Disable Player One" })
	vim.api.nvim_create_user_command("PlayerOneToggle", M.toggle, { desc = "Toggle Player One" })
	vim.api.nvim_create_user_command("PlayerOneLoad", function(opts)
		local theme = opts.args
		if theme ~= "" then
			M.load_theme(theme)
			vim.notify(theme .. " Loaded")
		else
			M.load_theme()
		end
	end, {
		nargs = "?",
		desc = "Load Player One theme",
		complete = function()
			return { "chiptune", "synth", "crystal" }
		end,
	})
end

return M
