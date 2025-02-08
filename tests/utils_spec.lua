local Utils = require("player-one.utils")
local assert = require("luassert")

describe("Utils", function()
	describe("play", function()
		it("should play a sequence of musical notes", function()
			local notes = {
				{ wave_type = 1, base_freq = 392.00, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 369.99, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 311.13, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 220.00, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 207.65, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 329.63, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 415.30, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
				{ wave_type = 1, base_freq = 523.25, env_attack = 0.0, env_sustain = 0.001367, env_decay = 0.1658 },
			}

			local ok, err = pcall(function()
				Utils.play(notes)
			end)
			-- assert.is_true(ok, string.format("Failed to play note %d: %s", i, tostring(err)))
		end)

		it("should play sound with a table", function()
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
			assert.is_true(ok, string.format("Failed to play sound with complex parameters: %s", tostring(err)))
			os.execute("sleep 0.5")
		end)

		it("should play sound with valid JSON", function()
			local json_params = [[
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
				Utils.play(json_params)
			end)
			assert.is_true(ok, string.format("Failed to play sound with JSON configuration: %s", tostring(err)))
			os.execute("sleep 0.5")
		end)

		it("should handle partial JSON", function()
			local json_partial = [[
		          {
		              "wave_type": 1,
		              "env_attack": 0.0
		          }
		          ]]

			local ok, err = pcall(function()
				Utils.play(json_partial)
			end)
			assert.is_true(ok, "Expected play() to succeed with partial JSON configuration")
			assert.is_nil(err, "Expected no error with partial JSON configuration")
		end)

		it("should handle invalid JSON", function()
			local invalid_json = [[
		          {
		              "wave_type": 1,
		              "env_attack": 0.0,
		              Invalid JSON content here
		              "env_decay": 0.1658
		          }
		          ]]

			local ok, err = pcall(function()
				Utils.play(invalid_json)
			end)
			assert.is_false(ok, "Expected play() to fail with invalid JSON configuration")
			assert.is_not_nil(err, "Expected an error with invalid JSON configuration")
		end)

		it("should play identical sounds with table and JSON", function()
			local table_params = {
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

			local json_params = [[
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
				Utils.play_async(table_params)
			end)
			assert.is_true(
				ok_table,
				string.format("Failed to play sound with table configuration: %s", tostring(err_table))
			)

			local ok_json, err_json = pcall(function()
				Utils.play_async(json_params)
			end)
			assert.is_true(
				ok_json,
				string.format("Failed to play sound with JSON configuration: %s", tostring(err_json))
			)
			os.execute("sleep 0.5")
		end)

		it("should handle different volume levels with table", function()
			local params = {
				wave_type = 1,
				base_freq = 440.0,
				env_attack = 0.0,
				env_sustain = 0.001,
				env_decay = 0.2,
				sound_vol = -6.0,
			}

			local volumes = { -60.0, -24.0, -12.0, -6.0, 10.0 }
			for _, volume in ipairs(volumes) do
				params.sound_vol = volume
				local ok, err = pcall(function()
					Utils.play_async(params)
				end)
				assert.is_true(
					ok,
					string.format("Failed to play sound at volume %f with table: %s", volume, tostring(err))
				)
			end
		end)

		it("should handle different volume levels with JSON", function()
			local base_params = {
				oldParams = true,
				wave_type = 1,
				p_env_attack = 0,
				p_env_sustain = 0.024555768060600138,
				p_env_punch = 0.4571553721133509,
				p_env_decay = 0.3423639066276736,
				p_base_freq = 0.5500696633190347,
				p_freq_limit = 0,
				p_freq_ramp = 0,
				p_freq_dramp = 0,
				p_vib_strength = 0,
				p_vib_speed = 0,
				p_arp_mod = 0.5329522492796008,
				p_arp_speed = 0.689393158112304,
				p_duty = 0,
				p_duty_ramp = 0,
				p_repeat_speed = 0,
				p_pha_offset = 0,
				p_pha_ramp = 0,
				p_lpf_freq = 1,
				p_lpf_ramp = 0,
				p_lpf_resonance = 0,
				p_hpf_freq = 0,
				p_hpf_ramp = 0,
				sample_rate = 44100,
				sample_size = 8,
			}

			local volumes = { 0.05, 0.25, 0.5, 0.75, 1.0 }

			for _, volume in ipairs(volumes) do
				local params = vim.tbl_deep_extend("force", base_params, { sound_vol = volume })
				local json_str = vim.json.encode(params)

				local ok, err = pcall(function()
					Utils.play_async(json_str)
				end)

				assert.is_true(ok, string.format("Failed to play sound at volume %f: %s", volume, tostring(err)))
			end
		end)
	end)
end)
