--- @brief Modern synthesizer-style sound theme with rich harmonics and filtering

local Utils = require("player-one.utils")
local State = require("player-one.state")

local M = {}

local function setup_cursormoved()
	Utils._create_autocmds("CursorMoved", {
		wave_type = 1,
		base_freq = 277.18,
		env_attack = 0.001,
		env_sustain = 0.01,
		env_decay = 0.08,
		duty = 0.3,
		lpf_freq = 2000,
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
				wave_type = 1,
				base_freq = 277.18,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 369.99,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 440.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 554.37,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 739.99,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
		},
		callback = function(sound)
			Utils.append(sound)
			vim.defer_fn(function()
				State._is_cursormoved_enabled = true
				setup_cursormoved()
			end, 1000)
		end,
	},
	--- @type PlayerOne.Sound
	{
		event = "VimLeavePre",
		sound = {
			{
				wave_type = 1,
				base_freq = 220.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 293.66,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
		},
		callback = function(sound)
			Utils.play_async(sound)
		end,
	},
	--- @type PlayerOne.Sound
	{
		event = "BufWritePost",
		sound = {
			{
				wave_type = 1,
				base_freq = 880.0,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.3,
				lpf_freq = 3000,
			},
			{
				wave_type = 1,
				base_freq = 987.77,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.3,
				lpf_freq = 3000,
			},
		},
		callback = "append",
	},
	--- @type PlayerOne.Sound
	{
		event = "TextChangedI",
		sound = {
			wave_type = 1,
			base_freq = 415.30,
			env_attack = 0.001,
			env_sustain = 0.01,
			env_decay = 0.08,
			duty = 0.3,
			lpf_freq = 2000,
		},
		callback = "play",
	},
	--- @type PlayerOne.Sound
	{
		event = "TextYankPost",
		sound = {
			{
				wave_type = 1,
				base_freq = 587.33,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 659.25,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
		},
		callback = "append",
	},
	--- @type PlayerOne.Sound
	{
		event = "CmdlineEnter",
		sound = {
			{
				wave_type = 1,
				base_freq = 329.63,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
			{
				wave_type = 1,
				base_freq = 392.00,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.15,
				duty = 0.6,
				lpf_freq = 4000,
			},
		},
		callback = "append",
	},
	--- @type PlayerOne.Sound
	{
		event = "CmdlineChanged",
		sound = {
			wave_type = 1,
			base_freq = 493.88,
			env_attack = 0.001,
			env_sustain = 0.01,
			env_decay = 0.08,
			duty = 0.3,
			lpf_freq = 2000,
		},
		callback = "play",
	},
}
