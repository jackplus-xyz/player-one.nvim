local Lib = require("player-one.lib")

local M = {}

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function sanitize_params(params)
	if not params then
		return {}
	end

	local allowed_keys = {
		"wave_type",
		"base_freq",
		"freq_limit",
		"freq_ramp",
		"freq_dramp",
		"duty",
		"duty_ramp",
		"vib_speed",
		"vib_strength",
		"env_attack",
		"env_sustain",
		"env_punch",
		"env_decay",
		"lpf_freq",
		"lpf_ramp",
		"lpf_resonance",
		"hpf_freq",
		"hpf_ramp",
		"pha_offset",
		"pha_ramp",
		"repeat_speed",
		"arp_speed",
		"arp_mod",
		"sample_rate",
		"sample_size",
	}

	local sanitized = {}

	for _, key in ipairs(allowed_keys) do
		if params[key] then
			local value = params[key]
			-- Value that should be passed as an integer
			if type(value) == "number" and (key == "wave_type" or key == "sample_rate" or key == "sample_size") then
				sanitized[key] = math.floor(value)
			else
				sanitized[key] = value
			end
		end
	end

	return sanitized
end

local function sanitize_json_params(json_params)
	local ok, params = pcall(vim.json.decode, json_params)
	if not ok then
		error("Failed to parse sound configuration: " .. params)
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

	return vim.json.encode(params)
end

local function process_sound_params(params, callback)
	if type(callback) ~= "function" then
		error("Callback must be a function")
	end

	if type(params) == "string" then
		local sanitized = sanitize_json_params(params)
		return callback(sanitized)
	end

	if type(params) == "table" then
		-- Handle a sequence of sound
		if params[1] and type(params[1]) == "table" then
			local results = {}
			for i, sound_params in ipairs(params) do
				local sanitized = sanitize_params(sound_params)
				results[i] = callback(sanitized)
			end
			return results
		else
			local sanitized = sanitize_params(params)
			return callback(sanitized)
		end
	end

	error(string.format("Invalid sound params type: %s", type(params)))
end

function M.play(params)
	return process_sound_params(params, Lib.play)
end

function M.play_async(params)
	return process_sound_params(params, Lib.play_async)
end

function M.stop()
	return Lib.stop()
end

return M
