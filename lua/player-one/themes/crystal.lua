--- @brief Crystal-style sound theme with pure sine waves and ethereal tones

local Utils = require("player-one.utils")
local Config = require("player-one.config")

local M = {}

local function setup_cursormoved()
	Utils._create_autocmds("CursorMoved", {
		wave_type = 0,
		base_freq = 2637.02,
		env_attack = 0.0,
		env_sustain = 0.001,
		env_decay = 0.04,
		volume = 0.3,
	})
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
			{
				wave_type = 0,
				base_freq = 1396.91,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.2,
				volume = 0.7,
			},
			{
				wave_type = 0,
				base_freq = 1760.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.18,
				volume = 0.6,
			},
			{
				wave_type = 0,
				base_freq = 2093.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				volume = 0.5,
			},
		},
		callback = function(sound)
			Utils.append(sound)
			vim.defer_fn(function()
				Config._is_cursormoved_enabled = true
				setup_cursormoved()
			end, 1000)
		end,
	},
	{
		event = "VimLeavePre",
		sound = {
			{
				wave_type = 0,
				base_freq = 2093.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				volume = 0.7,
			},
			{
				wave_type = 0,
				base_freq = 1760.00,
				env_attack = 0.05,
				env_sustain = 0.001,
				env_decay = 0.18,
				volume = 0.6,
			},
			{
				wave_type = 0,
				base_freq = 1396.91,
				env_attack = 0.1,
				env_sustain = 0.001,
				env_decay = 0.2,
				volume = 0.5,
			},
		},
		callback = "play_and_wait",
	},
	{
		event = "BufWritePost",
		sound = {
			{
				wave_type = 0,
				base_freq = 1661.22,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				volume = 0.6,
			},
			{
				wave_type = 0,
				base_freq = 2217.46,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.12,
				volume = 0.5,
			},
		},
		callback = "append",
	},
	{
		event = "TextChangedI",
		sound = {
			wave_type = 0,
			base_freq = 3136.0,
			env_attack = 0.0,
			env_sustain = 0.001,
			env_decay = 0.05,
			volume = 0.4,
		},
	},
	{
		event = "TextYankPost",
		sound = {
			{
				wave_type = 0,
				base_freq = 1864.66,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				volume = 0.6,
			},
			{
				wave_type = 0,
				base_freq = 2489.02,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.12,
				volume = 0.5,
			},
		},
		callback = "append",
	},
	{
		event = "CmdlineEnter",
		sound = {
			{
				wave_type = 0,
				base_freq = 1975.53,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				volume = 0.6,
			},
			{
				wave_type = 0,
				base_freq = 2793.83,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.12,
				volume = 0.5,
			},
		},
		callback = "append",
	},
	{
		event = "CmdlineChanged",
		sound = {
			wave_type = 0,
			base_freq = 2959.96,
			env_attack = 0.0,
			env_sustain = 0.001,
			env_decay = 0.05,
			volume = 0.4,
		},
	},
}
