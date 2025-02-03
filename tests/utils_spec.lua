local Utils = require("player-one.utils")
local assert = require("luassert")

describe("utils", function()
	describe("play", function()
		it("should play a sequence of notes", function()
			local notes = {
				{ base_freq = 392.00 },
				{ base_freq = 369.99 },
				{ base_freq = 311.13 },
				{ base_freq = 220.00 },
				{ base_freq = 207.65 },
				{ base_freq = 329.63 },
				{ base_freq = 415.30 },
				{ base_freq = 523.25 },
			}

			local start_time = os.time()
			local pause = 1

			for i, note in ipairs(notes) do
				local ok, err = pcall(function()
					Utils.play_async(note)
				end)
				assert.is_true(ok, string.format("Failed to play note %d: %s", i, tostring(err)))
			end

			local duration = os.time() - start_time

			assert.is_true(
				duration >= #notes * pause,
				string.format("Sequence played too quickly: %d seconds", duration)
			)

			print(string.format("Sequence completed in %d seconds", duration))
		end)

		it("should play sound with specific parameters", function()
			local params = {
				wave_type = 0, -- square wave
				env_attack = 0.000, -- 0 sec
				env_sustain = 0.001367, -- 0.001367 sec
				env_punch = 45.72, -- +45.72%
				env_decay = 0.2658, -- 0.2658 sec

				base_freq = 1071.0, -- 1071 Hz
				freq_limit = 3.528, -- 3.528 Hz
				freq_ramp = 0.0, -- 0 octaves/sec
				freq_dramp = 0.0, -- 0 octaves/sec^2

				-- Vibrato off
				vib_strength = 0.0,
				vib_speed = 0.0,

				-- Arpeggiation
				arp_mod = 1.343, -- x1.343
				arp_speed = 0.04447, -- 0.04447 sec

				-- Duty cycle
				duty = 50.0, -- 50%
				duty_ramp = 0.0, -- 0%/sec

				-- Retrigger OFF
				repeat_speed = 0.0,

				-- Flanger OFF
				pha_offset = 0.0,
				pha_ramp = 0.0,

				-- Low-pass filter
				lpf_freq = 0.0, -- OFF
				lpf_ramp = 0.0, -- OFF
				lpf_resonance = 45.0, -- 45%

				-- High-pass filter OFF
				hpf_freq = 0.0,
				hpf_ramp = 0.0,
			}

			local ok, err = pcall(function()
				Utils.play(params)
			end)
			assert.is_true(ok, string.format("Failed to play sound with parameters: %s", tostring(err)))

			-- Add a small delay to let the sound complete
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
			-- Lua table configuration
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

			-- Equivalent JSON configuration
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

			-- Play sound using table configuration
			local ok_table, err_table = pcall(function()
				Utils.play_async(table_config)
			end)
			assert.is_true(ok_table, string.format("Failed to play sound with table config: %s", tostring(err_table)))

			-- Play sound using JSON configuration
			local ok_json, err_json = pcall(function()
				Utils.play_async(json_config)
			end)
			assert.is_true(ok_json, string.format("Failed to play sound with JSON config: %s", tostring(err_json)))
		end)
	end)
end)
