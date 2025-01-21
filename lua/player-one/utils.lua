-- TODO: set up library path and load library based on the os
package.cpath = package.cpath .. ";/Users/jj/Developer/projects/player-one.nvim/target/debug/?.dylib"

-- Load the Rust module
local Lib = require("libplayerone")
local Sounds = require("player-one.sounds")

local M = {}

function M.play(sound_config)
	if type(sound_config) == "string" then
		-- If it's a JSON string, parse it
		sound_config = Sounds.parse_json_config(sound_config)
	elseif type(sound_config) == "table" then
		-- If it's a table, sanitize it
		sound_config = Sounds.sanitize_config(sound_config)
	else
		error("Invalid sound configuration type")
	end

	-- Play the sound using the Rust library
	return Lib.play_sound(sound_config)
end

function M.start()
	-- Initialize any required resources
end

function M.stop()
	return Lib.stop()
end

return M
