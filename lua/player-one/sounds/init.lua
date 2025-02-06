-- TODO: [ ] Add more default presets
-- UI sounds
-- Typing sounds
-- Navigation sounds
--
--[[
-- To use a sound, you can:
-- 1. Use one of the predefined sounds
-- 2. Add a sound like this:
-- {
-- wave_type: 1
-- }
-- 3. 
-- or use serialized json from https://sfxr.me
--{
  "oldParams": true, -- This will be omitted
  "wave_type": 1,    -- 0: Square | 1: Sawtooth | 2: Sine | 3: Noise | 4: Triangle
  "p_env_attack": 0,
  "p_env_sustain": 0.05797740489811762,
  "p_env_punch": 0.5600970894946076,
  "p_env_decay": 0.21963045075325816,
  "p_base_freq": 0.40509329095226904,
  "p_freq_limit": 0,
  "p_freq_ramp": 0,
  "p_freq_dramp": 0,
  "p_vib_strength": 0,
  "p_vib_speed": 0,
  "p_arp_mod": 0.464301867909878,
  "p_arp_speed": 0.668963102418166,
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
--]]

local State = require("player-one.state")
local Utils = require("player-one.utils")

local M = {}

local group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

local function create_autocmds(autocmd, sound, callback)
	vim.api.nvim_create_autocmd(autocmd, {
		group = group,
		callback = function()
			if State.is_enabled then
				if callback then
					local opts = {
						group = group,
						sound = sound,
					}
					callback(opts)
				else
					Utils.play(sound)
				end
			end
		end,
	})
end

function M.load(sounds)
	local presets = { "tone", "synth", "crystal" }

	if sounds then
		if vim.tbl_contains(presets, sounds) then
			sounds = require("player-one.sounds." .. sounds)
		end

		for _, v in ipairs(sounds) do
			create_autocmds(v.event, v.sound, v.callback)
		end
	end
end

return M
