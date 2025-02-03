local Lib = require("player-one.lib")
local Sounds = require("player-one.sounds")

local M = {}

function M.play(params)
	-- TODO: add validation
	-- if type(sound_config) == "string" then
	-- 	-- If it's a JSON string, parse it
	-- 	sound_config = Sounds.parse_json_config(sound_config)
	-- elseif type(sound_config) == "table" then
	-- 	-- If it's a table, sanitize it
	-- 	sound_config = Sounds.sanitize_config(sound_config)
	-- else
	-- 	error("Invalid sound configuration type")
	-- end
	--
	-- Play the sound using the Rust library
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
