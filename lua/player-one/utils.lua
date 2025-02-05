local Lib = require("player-one.lib")

local M = {}

-- TODO: implement
local function sanitize_params(params)
	return params
end

local function sanitize_json_params(json_params)
	local ok, params = pcall(vim.json.decode, json_params)
	if not ok then
		error("Failed to parse sound configuration: " .. params)
	end

	local function clamp(value, min, max)
		return math.min(math.max(value, min), max)
	end

	local unsigned_params = {
		"p_env_attack",
		"p_env_sustain",
		"p_env_punch",
		"p_env_decay",
		"p_base_freq",
		"p_freq_limit",
		"p_vib_strength",
		"p_vib_speed",
		"p_arp_speed",
		"p_duty",
		"p_repeat_speed",
		"p_lpf_freq",
		"p_lpf_resonance",
		"p_hpf_freq",
		"sound_vol",
	}

	local signed_params = {
		"p_freq_ramp",
		"p_freq_dramp",
		"p_arp_mod",
		"p_duty_ramp",
		"p_pha_offset",
		"p_pha_ramp",
		"p_lpf_ramp",
		"p_hpf_ramp",
	}

	for _, param in ipairs(unsigned_params) do
		if params[param] then
			params[param] = clamp(params[param], 0, 1)
		end
	end

	for _, param in ipairs(signed_params) do
		if params[param] then
			params[param] = clamp(params[param], -1, 1)
		end
	end

	if params.sample_rate then
		params.sample_rate = math.floor(params.sample_rate)
	end
	if params.sample_size then
		params.sample_size = math.floor(params.sample_size)
	end
	if params.wave_type then
		params.wave_type = math.floor(params.wave_type)
	end

	return params
end

function M.play(params)
	if type(params) == "string" then
		params = sanitize_json_params(params)
	elseif type(params) == "table" then
		params = sanitize_params(params)
	else
		error("Invalid sound configuration type")
	end

	return Lib.play(params)
end

function M.play_async(params)
	return Lib.play_async(params)
end

function M.start()
	-- Initialize any required resources
end

function M.stop()
	return Lib.stop()
end

return M
