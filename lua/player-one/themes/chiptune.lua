--- @brief Chiptune-style sound theme inspired by 8-bit game consoles

local Utils = require("player-one.utils")
local State = require("player-one.state")

local M = {}

local function setup_cursormoved()
	if State._is_cursormoved_enabled then
		Utils._create_autocmds("CursorMoved", {
			wave_type = 1,
			base_freq = 440.0,
			env_attack = 0.0,
			env_sustain = 0.001,
			env_decay = 0.05,
		})
	end
end

function M.setup()
	setup_cursormoved()
end

M.setup()

---@type PlayerOne.Theme
return {
	{
		event = "VimEnter",
		sound = {
			{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 587.33, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 659.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 783.99, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		},
		callback = function(sound)
			Utils.append(sound)
			vim.defer_fn(function()
				State._is_cursormoved_enabled = true
				setup_cursormoved()
			end, 1000)
		end,
	},
	{
		event = "VimLeavePre",
		sound = {
			{ wave_type = 1, base_freq = 1046.50, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.1 },
			{ wave_type = 1, base_freq = 1318.51, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.08 },
		},
		callback = "play_async",
	},
	{
		event = "BufWritePost",
		sound = {
			{ wave_type = 2, base_freq = 636.7, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 2, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		},
		callback = "append",
	},
	{
		event = "TextChangedI",
		sound = { wave_type = 1, base_freq = 760.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
	},
	{
		event = "TextYankPost",
		sound = {
			{ wave_type = 1, base_freq = 1760.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 2197.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		},
		callback = "append",
	},
	{
		event = "CmdlineEnter",
		sound = {
			{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
			{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
		},
		callback = "append",
	},
	{
		event = "CmdlineChanged",
		sound = { wave_type = 1, base_freq = 880.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
	},
}
