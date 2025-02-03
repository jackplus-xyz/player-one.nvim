local Debug = require("player-one.debug")
local Utils = require("player-one.utils")
local Lib = require("player-one.lib")

local notes = {
	{ freq_base = 392.00 },
	{ freq_base = 369.99 },
	{ freq_base = 311.13 },
	{ freq_base = 220.00 },
	{ freq_base = 207.65 },
	{ freq_base = 329.63 },
	{ freq_base = 415.30 },
	{ freq_base = 523.25 },
}

-- for i, note in ipairs(notes) do
-- 	Utils.play(note)
-- end

-- local jump = [[{
--   "oldParams": true,
--   "wave_type": 0,
--   "p_env_attack": 0,
--   "p_env_sustain": 0.34286412148113554,
--   "p_env_punch": 0,
--   "p_env_decay": 0.20511448102273347,
--   "p_base_freq": 0.5665901654494735,
--   "p_freq_limit": 0,
--   "p_freq_ramp": 0.2214903001863388,
--   "p_freq_dramp": 0,
--   "p_vib_strength": 0,
--   "p_vib_speed": 0,
--   "p_arp_mod": 0,
--   "p_arp_speed": 0,
--   "p_duty": 0.5348042063800236,
--   "p_duty_ramp": 0,
--   "p_repeat_speed": 0,
--   "p_pha_offset": 0,
--   "p_pha_ramp": 0,
--   "p_lpf_freq": 0.8513423205031941,
--   "p_lpf_ramp": 0,
--   "p_lpf_resonance": 0,
--   "p_hpf_freq": 0.2556842631206413,
--   "p_hpf_ramp": 0,
--   "sound_vol": 0.25,
--   "sample_rate": 44100,
--   "sample_size": 8
-- }]]

Utils.play(jump)
