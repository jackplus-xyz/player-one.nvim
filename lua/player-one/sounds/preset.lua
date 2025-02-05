local M = {}

M.ui = {
	-- A sequece of welcome jingle
	welcome = {
		{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 369.99, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 311.13, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 220.00, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 207.65, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 329.63, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 415.30, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
		{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
	},
	-- A coin pickup sound
	save = {
		wave_type = 1,
		env_attack = 0.000,
		env_sustain = 0.001367,
		env_punch = 45.72,
		env_decay = 0.2658,
		base_freq = 1071.0,
		freq_dramp = 0.0,
		vib_strength = 0.0,
		vib_speed = 0.0,
		arp_mod = 1.343,
		arp_speed = 0.04447,
		duty = 50.0,
		duty_ramp = 0.0,
		repeat_speed = 0.0,
		pha_offset = 0.0,
		pha_ramp = 0.0,
		lpf_freq = 0.0,
		lpf_ramp = 1.0,
		lpf_resonance = 45.0,
		hpf_freq = 0.0,
		hpf_ramp = 0.0,
	},
	-- A short beep sound
	type = {
		wave_type = 1,
		env_sustain = 0.01,
		env_attack = 0.0,
		env_decay = 0.02,
		base_freq = 760.0,
		freq_ramp = -1.0,
	},
}

return M
