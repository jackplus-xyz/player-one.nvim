local Utils = require("player-one.utils")
local assert = require("luassert")

describe("playback", function()
	describe("play_sequence", function()
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

				-- Brief pause between notes
				os.execute("sleep " .. pause)
			end

			local duration = os.time() - start_time

			assert.is_true(
				duration >= #notes * pause,
				string.format("Sequence played too quickly: %d seconds", duration)
			)

			print(string.format("Sequence completed in %d seconds", duration))
		end)

		-- it("should handle invalid parameters gracefully", function()
		-- 	-- Test invalid frequency
		-- 	local invalid_freq = {
		-- 		freq_base = -1.0,
		-- 		volume = 0.5,
		-- 	}
		-- 	assert.has_error(function()
		-- 		Lib.play(invalid_freq)
		-- 	end)
		--
		-- 	-- Test invalid volume
		-- 	local invalid_volume = {
		-- 		freq_base = 440.0,
		-- 		volume = 1.5,
		-- 	}
		-- 	assert.has_error(function()
		-- 		Lib.play(invalid_volume)
		-- 	end)
		--
		-- 	-- Test invalid envelope
		-- 	local invalid_envelope = {
		-- 		freq_base = 440.0,
		-- 		volume = 0.5,
		-- 		env_attack = -0.1,
		-- 	}
		-- 	assert.has_error(function()
		-- 		Lib.play(invalid_envelope)
		-- 	end)
		-- end)

		-- it("should play various waveform types", function()
		-- 	local base_params = {
		-- 		freq_base = 440.0,
		-- 		volume = 0.5,
		-- 		env_attack = 0.01,
		-- 		env_sustain = 0.1,
		-- 		env_decay = 0.1,
		-- 	}
		--
		-- 	-- Test each waveform type
		-- 	for wave_type = 0, 4 do
		-- 		local params = vim.tbl_extend("force", base_params, { wave_type = wave_type })
		-- 		local success = Lib.play(params)
		-- 		assert.is_true(success, string.format("Failed to play waveform type %d", wave_type))
		-- 		os.execute("sleep 0.05")
		-- 	end
		-- end)

		-- it("should handle JSON format parameters", function()
		-- 	local json_params = [[{
		--       "wave_type": 0,
		--       "p_env_attack": 0.0,
		--       "p_env_sustain": 0.3,
		--       "p_env_punch": 0.0,
		--       "p_env_decay": 0.4,
		--       "p_base_freq": 0.3,
		--       "sound_vol": 0.25,
		--       "sample_rate": 44100,
		--       "sample_size": 8
		--     }]]
		--
		-- 	local success = Lib.play(json_params)
		-- 	assert.is_true(success, "Failed to play sound with JSON parameters")
		-- end)
	end)
end)
