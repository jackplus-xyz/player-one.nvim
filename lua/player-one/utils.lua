local Lib = require("player-one.binary")
local State = require("player-one.state")

--- Sound utility functions for PlayerOne
--- Provides core functionality for sound parameter validation, playback control, and event handling.
---
---@module 'player-one.utils'
---
---@usage
--- local Utils = require("player-one.utils")
---
--- -- Basic sound playback
--- Utils.play({
---   wave_type = 1,
---   base_freq = 440.0,
---   env_decay = 0.1
--- })
---
--- -- Playing multiple sounds in sequence
--- Utils.append({
---   { wave_type = 1, base_freq = 523.25 },
---   { wave_type = 1, base_freq = 587.33 }
--- })
---
--- -- Loading a custom theme
--- Utils.load_theme({
---   {
---     event = "InsertEnter",
---     sound = { wave_type = 1, base_freq = 440 }
---   },
---   {
---     event = "InsertLeave",
---     sound = { wave_type = 2, base_freq = 880 }
---   }
--- })
---
---@see player-one.lib
---@see player-one.state
local M = {}

---@type number Time of last sound played (in milliseconds)
local last_play_time = 0

---Sanitize and validate sound parameters
---@param params PlayerOne.SoundParams|nil Raw parameters to sanitize
---@return PlayerOne.SoundParams Sanitized parameters
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
    local temp_params = vim.deepcopy(params) -- Avoid modifying original params table

    -- Handle 'volume' alias: if params.volume exists and params.sound_vol doesn't, use params.volume for sound_vol
    if temp_params.volume ~= nil and temp_params.sound_vol == nil then
        if type(temp_params.volume) ~= "number" then
            error("Invalid type for 'volume' alias: expected number, got " .. type(temp_params.volume))
        end
        temp_params.sound_vol = temp_params.volume
        temp_params.volume = nil -- Remove the alias
    end

    -- Copy all valid keys from temp_params to sanitized
    for _, key in ipairs(valid_keys) do
        local value = temp_params[key]
        if value ~= nil then
            if type(value) ~= "number" then
                error("Invalid type for " .. key .. ": expected number, got " .. type(value))
            end

            if key == "wave_type" or key == "sample_rate" or key == "sample_size" then
                sanitized[key] = math.floor(value)
            else
                sanitized[key] = value
            end
        end
    end

    -- Apply master_volume logic
    if State.master_volume ~= nil then
        local base_vol_for_calc = (sanitized.sound_vol == nil) and 1.0 or sanitized.sound_vol
        local final_vol = base_vol_for_calc * State.master_volume
        sanitized.sound_vol = math.max(0.0, math.min(1.0, final_vol))
    elseif sanitized.sound_vol ~= nil then
        -- Ensure individual sound_vol is clamped even if master_volume is not set
        sanitized.sound_vol = math.max(0.0, math.min(1.0, sanitized.sound_vol))
    end
    -- If State.master_volume is nil and params.sound_vol (or alias) was also nil,
    -- sanitized.sound_vol remains nil, and the binary will use its default volume.

    return sanitized
end

---Sanitize and validate JSON format sound parameters
---@param json_params string JSON string containing sound parameters
---@return string Sanitized JSON string
local function sanitize_json_params(json_params)
    local ok, params_decoded = pcall(vim.json.decode, json_params)
    if not ok then
        error("Failed to parse sound configuration: " .. params_decoded)
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

    -- Validate types for existing keys in params_decoded
    for _, key in ipairs(valid_keys) do
        local value = params_decoded[key]
        if value ~= nil then
            if type(value) ~= "number" then
                error("Invalid type in json for " .. key .. ": expected number, got " .. type(value))
            end
            -- No integer casting needed here as per original logic for json params
        end
    end

    -- Apply master_volume logic to params_decoded.sound_vol
    if State.master_volume ~= nil then
        local base_vol_for_calc = (params_decoded.sound_vol == nil) and 1.0 or params_decoded.sound_vol
        local final_vol = base_vol_for_calc * State.master_volume
        params_decoded.sound_vol = math.max(0.0, math.min(1.0, final_vol))
    elseif params_decoded.sound_vol ~= nil then
        -- Ensure individual sound_vol is clamped even if master_volume is not set
        params_decoded.sound_vol = math.max(0.0, math.min(1.0, params_decoded.sound_vol))
    end
    -- If State.master_volume is nil and params_decoded.sound_vol was also nil,
    -- params_decoded.sound_vol remains nil.

    return vim.json.encode(params_decoded)
end

---Process and validate sound parameters before playing
---@param params PlayerOne.SoundParams|PlayerOne.SoundParams[]|string Sound parameters to process
---@param callback function Function to call with processed parameters
---@return any Result from the callback
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

---Create autocommands for sound events
---@param autocmd string|string[] Neovim autocommand event(s)
---@param sound PlayerOne.SoundParams|PlayerOne.SoundParams[] Sound(s) to play
---@param callback? PlayCallback How to play the sound
function M._create_autocmds(autocmd, sound, callback)
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
                        elseif callback == "play_and_wait" then
                            M.play_and_wait(sound)
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

---Clear all plugin autocommands
function M.clear_autocmds()
    vim.api.nvim_clear_autocmds({ group = State.group })
end

---Load a sound theme
---@param theme? string|PlayerOne.Theme Theme name or custom theme table
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
        M._create_autocmds(v.event, v.sound, v.callback)
    end
end

---Play a sound immediately
---@param params PlayerOne.SoundParams|PlayerOne.SoundParams[]|string Sound parameters
---@return any Result from sound playback
function M.play(params)
    return process_sound_params(params, Lib.play)
end

---Queue a sound to play after current sounds
---@param params PlayerOne.SoundParams|PlayerOne.SoundParams[]|string Sound parameters
---@return any Result from sound queueing
function M.append(params)
    return process_sound_params(params, Lib.append)
end

---Play a sound and wait for completion
---@param params PlayerOne.SoundParams|PlayerOne.SoundParams[]|string Sound parameters
---@return any Result from play_and_wait playback
function M.play_and_wait(params)
    return process_sound_params(params, Lib.play_and_wait)
end

---Stop all currently playing sounds
---@return any Result from stop operation
function M.stop()
    return Lib.stop()
end

return M
