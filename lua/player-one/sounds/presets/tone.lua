return {
	vim_enter = {
		{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 369.99, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 311.13, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 220.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 207.65, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 329.63, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 415.30, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
	},
	vim_leave_pre = {
		{ wave_type = 1, base_freq = 1760.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 1, base_freq = 2197.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
	},

	buf_write_post = {
		{ wave_type = 2, base_freq = 636.7, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
		{ wave_type = 2, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.15 },
	},

	text_changed_i = { wave_type = 1, base_freq = 760.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
	text_yank_post = {
		{ wave_type = 1, base_freq = 1046.50, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.1 },
		{ wave_type = 1, base_freq = 1318.51, env_attack = 0.0, env_sustain = 0.02, env_decay = 0.08 },
	},

	cursor_moved = { wave_type = 1, base_freq = 440.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },

	cmdline_enter = {
		{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
		{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
	},
	cmdline_changed = { wave_type = 1, base_freq = 880.0, env_attack = 0.0, env_sustain = 0.001, env_decay = 0.05 },
}
