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
					callback(sound)
				else
					Utils.play(sound)
				end
			end
		end,
	})
end

-- TODO: add more preset?
--
-- "chiptune"
-- "synth"
-- "crystal"
-- "mechanical"
-- "minimal"
-- "retro"
-- "ambient"
-- "digital"

function M.load(theme)
	local presets = { "chiptune", "synth", "crystal" }

	if not theme then
		error("Sound theme not provided. Please specify one of: " .. table.concat(presets, ", "))
	end

	if type(theme) ~= "table" and type(theme) ~= "string" then
		error("themes parameter must be a table or string")
	end

	if type(theme) == "string" then
		if not vim.tbl_contains(presets, theme) then
			error(string.format("Invalid preset '%s'. Available presets: %s", theme, table.concat(presets, ", ")))
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

return M
