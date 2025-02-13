local Utils = require("player-one.utils")

local is_cursormoved_enabled = false

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
				is_cursormoved_enabled = true
			end, 1000)
		end,
	},
	{
		event = "CursorMoved",
		sound = {
			wave_type = 1,
			base_freq = 277.18,
			env_attack = 0.001,
			env_sustain = 0.01,
			env_decay = 0.08,
			duty = 0.3,
			lpf_freq = 2000,
		},
		callback = function(sound)
			if not is_cursormoved_enabled then
				return
			end
			Utils.play(sound)
		end,
	},
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
