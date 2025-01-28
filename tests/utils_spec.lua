local Utils = require("player-one.utils")
local assert = require("luassert")

describe("utils", function()
	describe("play", function()
		it("should play a sequence of notes", function()
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

			local start_time = os.time()
			local pause = 0.1

			for i, note in ipairs(notes) do
				local ok, err = pcall(function()
					Utils.play(note)
				end)
				assert.is_true(ok, string.format("Failed to play note %d: %s", i, tostring(err)))

				os.execute("sleep " .. pause)
			end

			local duration = os.time() - start_time

			assert.is_true(
				duration >= #notes * pause,
				string.format("Sequence played too quickly: %d seconds", duration)
			)

			print(string.format("Sequence completed in %d seconds", duration))
		end)

		it("should play sound with valid JSON string config", function()
			local json_config = [[{
  "oldParams": true,
  "wave_type": 1,
  "p_env_attack": 0,
  "p_env_sustain": 0.04411743910371005,
  "p_env_punch": 0.4350212384906197,
  "p_env_decay": 0.4211059470727624,
  "p_base_freq": 0.7196594711465818,
  "p_freq_limit": 0,
  "p_freq_ramp": 0,
  "p_freq_dramp": 0,
  "p_vib_strength": 0,
  "p_vib_speed": 0,
  "p_arp_mod": 0.378708522940697,
  "p_arp_speed": 0.6285888669803376,
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
}]]

			local ok, err = pcall(function()
				Utils.play(json_config)
			end)
			assert.is_true(ok, string.format("Failed to play json sound: %s", tostring(err)))
		end)
	end)
end)
