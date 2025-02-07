local Utils = require("player-one.utils")
local group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

return {
	{
		event = "VimEnter",
		sound = {
			{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 369.99, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 311.13, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 220.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 207.65, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 329.63, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 415.30, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		},
		callback = function(sound)
			Utils.play(sound)

			-- Wait 1 second after VimEnter before registering the CursorMoved autocmd.
			vim.defer_fn(function()
				vim.api.nvim_create_autocmd("CursorMoved", {
					group = group,
					callback = function()
						local cursor_moved = {
							wave_type = 1,
							base_freq = 440.0,
							env_attack = 0.0,
							env_sustain = 0.001,
							env_decay = 0.05,
						}
						Utils.play(cursor_moved)
					end,
				})
			end, 1000)
		end,
	},
	{
		event = "VimLeavePre",
		sound = {
			{ wave_type = 1, base_freq = 1046.50, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.1 },
			{ wave_type = 1, base_freq = 1318.51, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.08 },
		},
		callback = function(sound)
			Utils.play(sound)
			-- add a delay
			local duration = 0
			for _, v in pairs(sound) do
				duration = duration + (v.env_attack or 0)
				duration = duration + (v.env_sustain or 0)
				duration = duration + (v.env_decay or 0)
			end
			os.execute("sleep " .. duration + 0.0001)
		end,
	},
	{
		event = "BufWritePost",
		sound = {
			{ wave_type = 2, base_freq = 636.7, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
			{ wave_type = 2, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		},
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
	},
	{
		event = "CmdlineEnter",
		sound = {
			{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
			{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
		},
	},
	{
		event = "CmdlineChanged",
		sound = { wave_type = 1, base_freq = 880.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
	},
}
