local Lib = require("player-one.lib")
local State = require("player-one.state")

local M = {}

local last_play_time = 0

local function sanitize_params(params)
	if not params then
		return {}
	end

	local valid_keys = {
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
		"sound_vol",
	}

	local sanitized = {}

	for _, key in ipairs(valid_keys) do
		local value = params[key]
		if value then
			if type(value) ~= "number" then
				error("Invalid type for " .. key .. ": expected number, got " .. type(value))
			end

			-- Value that should be passed as an integer
			if key == "wave_type" or key == "sample_rate" or key == "sample_size" then
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

	local valid_keys = {
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
		"p_freq_ramp",
		"p_freq_dramp",
		"p_arp_mod",
		"p_duty_ramp",
		"p_pha_offset",
		"p_pha_ramp",
		"p_lpf_ramp",
		"p_hpf_ramp",
		"sound_vol",
	}

	for _, key in ipairs(valid_keys) do
		local value = params[key]
		if value then
			if type(value) ~= "number" then
				error("Invalid type in json for " .. key .. ": expected number, got " .. type(value))
			end

			if key == "wave_type" or key == "sample_rate" or key == "sample_size" then
				params[key] = math.floor(value)
			else
				params[key] = value
			end
		end
	end

	return vim.json.encode(params)
end

local function process_sound_params(params, callback)
	local min_interval = State.min_interval or 0
	local current_time = vim.uv.now()
	local time_diff = (current_time - last_play_time) / 1000 -- Convert to seconds

	-- Prevents sounds from playing too frequently
	if time_diff < min_interval then
		return
	end

	last_play_time = current_time

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
			if #params > 1 then
				local results = {}
				for i, sound_params in ipairs(params) do
					local sanitized = sanitize_params(sound_params)
					results[i] = callback(sanitized)
				end
				return results
			else
				local sanitized = sanitize_params(params[1])
				return callback(sanitized)
			end
		else
			local sanitized = sanitize_params(params)
			return callback(sanitized)
		end
	end

	error(string.format("Invalid sound params type: %s", type(params)))
end

local function create_autocmds(autocmd, sound, callback)
	vim.api.nvim_create_autocmd(autocmd, {
		group = State.group,
		callback = function()
			if State.is_enabled then
				if callback then
					if type(callback) == "function" then
						callback(sound)
					elseif type(callback) == "string" then
						if callback == "append" then
							M.append(sound)
						elseif callback == "play" then
							M.play(sound)
						elseif callback == "play_async" then
							M.play_async(sound)
						else
							error("Invalid callback string: " .. callback)
						end
					else
						error("callback must be a function or a string")
					end
				else
					M.play(sound)
				end
			end
		end,
	})
end

function M.clear_autocmds()
	vim.api.nvim_clear_autocmds({ group = State.group })
end

function M.load_theme(theme)
	if theme == "default" or not theme then
		theme = State.curr_theme
		if not theme then
			return
		end
	end

	M.clear_autocmds()

	local themes = State.themes
	if type(theme) == "string" then
		if not vim.tbl_contains(themes, theme) then
			error(string.format("Invalid preset '%s'. Available presets: %s", theme, table.concat(themes, ", ")))
		end
		theme = require("player-one.themes." .. theme)
	end

	for i, v in ipairs(theme) do
		if type(v) ~= "table" then
			error(string.format("Invalid sound configuration at index %d", i))
		end
		if not v.event then
			error(string.format("Missing 'event' in sound configuration at index %d", i))
		end
		if not v.sound then
			error(string.format("Missing 'sound' in sound configuration at index %d", i))
		end
		create_autocmds(v.event, v.sound, v.callback)
	end
end

function M.play(params)
	return process_sound_params(params, Lib.play)
end

function M.append(params)
	return process_sound_params(params, Lib.append)
end

function M.play_async(params)
	return process_sound_params(params, Lib.play_async)
end

function M.stop()
	return Lib.stop()
end

return M
