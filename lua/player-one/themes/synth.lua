local Utils = require("player-one.utils")
local group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

return {
	{
		event = "VimEnter",
		sound = {
			-- A deep, rich synth chord. Lower frequencies help make things sound more bassy.
			{
				wave_type = 2,
				base_freq = 65.41, -- C2
				env_attack = 0.05,
				env_sustain = 0.15,
				env_decay = 0.2,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 82.41, -- E2
				env_attack = 0.05,
				env_sustain = 0.15,
				env_decay = 0.2,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 98.00, -- G2
				env_attack = 0.05,
				env_sustain = 0.15,
				env_decay = 0.2,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 130.81, -- C3
				env_attack = 0.05,
				env_sustain = 0.15,
				env_decay = 0.3,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
		},
		callback = function(sound)
			Utils.play(sound)

			-- Delay registering the CursorMoved autocmd until 1 second after VimEnter.
			vim.defer_fn(function()
				vim.api.nvim_create_autocmd("CursorMoved", {
					group = group,
					callback = function()
						local cursor_sound = {
							wave_type = 2,
							base_freq = 55.00, -- A1 for a deep pulse on movement
							env_attack = 0.01,
							env_sustain = 0.1,
							env_decay = 0.05,
							duty = 43.55,
							duty_ramp = 0,
							lpf_freq = 29910,
							lpf_ramp = 4.645,
							lpf_resonance = 92.65,
							hpf_freq = 0,
							hpf_ramp = 3.300,
						}
						Utils.play(cursor_sound)
					end,
				})
			end, 1000)
		end,
	},
	{
		event = "VimLeavePre",
		sound = {
			-- An electric farewell in the upper bass range.
			{
				wave_type = 2,
				base_freq = 98.00, -- G2
				env_attack = 0.0,
				env_sustain = 0.05,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 123.47, -- B2
				env_attack = 0.0,
				env_sustain = 0.05,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
		},
		callback = function(sound)
			Utils.play_async(sound)
		end,
	},
	{
		event = "BufWritePost",
		sound = {
			-- A short, bass-punch combo triggered on file save.
			{
				wave_type = 2,
				base_freq = 82.41, -- E2
				env_attack = 0.02,
				env_sustain = 0.1,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 73.42, -- D2
				env_attack = 0.02,
				env_sustain = 0.1,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
		},
	},
	{
		event = "TextChangedI",
		sound = {
			-- A quick electric pulse as you change text.
			wave_type = 2,
			base_freq = 87.31, -- F2
			env_attack = 0.02,
			env_sustain = 0.07,
			env_decay = 0.05,
			duty = 43.55,
			duty_ramp = 0,
			lpf_freq = 29910,
			lpf_ramp = 4.645,
			lpf_resonance = 92.65,
			hpf_freq = 0,
			hpf_ramp = 3.300,
		},
	},
	{
		event = "TextYankPost",
		sound = {
			-- Two-note confirmation with an electric edge.
			{
				wave_type = 2,
				base_freq = 110.00, -- A2
				env_attack = 0.0,
				env_sustain = 0.08,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 123.47, -- B2
				env_attack = 0.0,
				env_sustain = 0.08,
				env_decay = 0.15,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
		},
	},
	{
		event = "CmdlineEnter",
		sound = {
			-- A set of dual tones to signal command-line engagement.
			{
				wave_type = 2,
				base_freq = 73.42, -- D2
				env_attack = 0.03,
				env_sustain = 0.1,
				env_decay = 0.05,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
			{
				wave_type = 2,
				base_freq = 82.41, -- E2
				env_attack = 0.03,
				env_sustain = 0.1,
				env_decay = 0.05,
				duty = 43.55,
				duty_ramp = 0,
				lpf_freq = 29910,
				lpf_ramp = 4.645,
				lpf_resonance = 92.65,
				hpf_freq = 0,
				hpf_ramp = 3.300,
			},
		},
	},
	{
		event = "CmdlineChanged",
		sound = {
			-- An electric pulse on command change.
			wave_type = 2,
			base_freq = 98.00, -- G2
			env_attack = 0.03,
			env_sustain = 0.1,
			env_decay = 0.05,
			duty = 43.55,
			duty_ramp = 0,
			lpf_freq = 29910,
			lpf_ramp = 4.645,
			lpf_resonance = 92.65,
			hpf_freq = 0,
			hpf_ramp = 3.300,
		},
	},
}
