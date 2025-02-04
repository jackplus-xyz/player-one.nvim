local Utils = require("player-one.utils")
local assert = require("luassert")

describe("utils", function()
	describe("play", function()
		it("should play a sequence of notes", function()
			local notes = {
				{ wave_type = 1, base_freq = 392.0, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 369.99, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 311.13, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 220.00, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 207.65, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 329.63, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 415.30, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
			}

			for i, note in ipairs(notes) do
				local ok, err = pcall(function()
					Utils.play(note)
				end)
				assert.is_true(ok, string.format("Failed to play note %d: %s", i, tostring(err)))
			end
			it("should play sound with specific parameters", function()
				local params = {
					wave_type = 0,
					env_attack = 0.000,
					env_sustain = 0.001367,
					env_punch = 45.72,
					env_decay = 0.2658,
					base_freq = 1071.0,
					freq_limit = 3.528,
					freq_ramp = 0.0,
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
					lpf_ramp = 0.0,
					lpf_resonance = 45.0,
					hpf_freq = 0.0,
					hpf_ramp = 0.0,
				}

				local ok, err = pcall(function()
					Utils.play(params)
				end)
				assert.is_true(ok, string.format("Failed to play sound with parameters: %s", tostring(err)))

				os.execute("sleep 0.5")
			end)

			it("should play sound with valid JSON string config", function()
				local json_config = [[
		    {
		      "oldParams": true,
		      "wave_type": 1,
		      "p_env_attack": 0,
		      "p_env_sustain": 0.024555768060600138,
		      "p_env_punch": 0.4571553721133509,
		      "p_env_decay": 0.3423639066276736,
		      "p_base_freq": 0.5500696633190347,
		      "p_freq_limit": 0,
		      "p_freq_ramp": 0,
		      "p_freq_dramp": 0,
		      "p_vib_strength": 0,
		      "p_vib_speed": 0,
		      "p_arp_mod": 0.5329522492796008,
		      "p_arp_speed": 0.689393158112304,
		      "p_duty": 0,
		      "p_duty_ramp": 0,
		      "p_repeat_speed": 0,
		      "p_pha_offset": 0,
		      "p_pha_ramp": 0,
		      "p_lpf_freq": 1,
		      "p_lpf_ramp": 0,
		      "p_lpf_resonance": 0,
		      "p_hpf_freq": 0,
		      "p_hpf_ramp": 0,
		      "sound_vol": 0.25,
		      "sample_rate": 44100,
		      "sample_size": 8
		    }
		 ]]

				local ok, err = pcall(function()
					Utils.play(json_config)
				end)
				os.execute("sleep 0.5")
				assert.is_true(ok, string.format("Failed to play json sound: %s", tostring(err)))
			end)

			it("#only should play identical sounds with table and JSON configurations", function()
				local table_config = {
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
				}

				local json_config = [[
    {
        "oldParams": true,
        "wave_type": 1,
        "p_env_attack": 0,
        "p_env_sustain": 0.024555768060600138,
        "p_env_punch": 0.4571553721133509,
        "p_env_decay": 0.3423639066276736,
        "p_base_freq": 0.5500696633190347,
        "p_freq_limit": 0,
        "p_freq_ramp": 0,
        "p_freq_dramp": 0,
        "p_vib_strength": 0,
        "p_vib_speed": 0,
        "p_arp_mod": 0.5329522492796008,
        "p_arp_speed": 0.689393158112304,
        "p_duty": 0,
        "p_duty_ramp": 0,
        "p_repeat_speed": 0,
        "p_pha_offset": 0,
        "p_pha_ramp": 0,
        "p_lpf_freq": 1,
        "p_lpf_ramp": 0,
        "p_lpf_resonance": 0,
        "p_hpf_freq": 0,
        "p_hpf_ramp": 0,
        "sound_vol": 0.25,
        "sample_rate": 44100,
        "sample_size": 8
    }
    ]]

				local ok_table, err_table = pcall(function()
					Utils.play_async(table_config)
				end)
				assert.is_true(
					ok_table,
					string.format("Failed to play sound with table config: %s", tostring(err_table))
				)

				local ok_json, err_json = pcall(function()
					Utils.play_async(json_config)
				end)
				assert.is_true(ok_json, string.format("Failed to play sound with JSON config: %s", tostring(err_json)))
			end)
		end)
	end)
end)
