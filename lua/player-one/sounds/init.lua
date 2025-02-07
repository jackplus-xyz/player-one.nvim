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

function M.load(sounds)
	local presets = { "tone", "synth", "crystal" }

	if not sounds then
		return
	end

	if type(sounds) ~= "table" and type(sounds) ~= "string" then
		error("sounds parameter must be a table or string")
	end

	if type(sounds) == "string" then
		if not vim.tbl_contains(presets, sounds) then
			error(string.format("Invalid preset '%s'. Available presets: %s", sounds, table.concat(presets, ", ")))
		end
		sounds = require("player-one.sounds." .. sounds)
	end

	for i, v in ipairs(sounds) do
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
