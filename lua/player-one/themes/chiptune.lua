--- @brief Chiptune-style sound module that maps musical notes to sound effects
--- Each sound is generated from a base musical note to create an 8-bit/retro feel
local Utils = require("player-one.utils")

local is_cursormoved_enabled = false

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
				is_cursormoved_enabled = true
			end, 1000)
		end,
	},
	{
		event = "CursorMoved",
		sound = {
			wave_type = 1,
			base_freq = 440.0,
			env_attack = 0.0,
			env_sustain = 0.001,
			env_decay = 0.05,
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
