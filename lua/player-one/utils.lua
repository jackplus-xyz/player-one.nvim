local Sounds = require("player-one.sounds")
local NvimSounds = require("nvim_sounds")

local M = {}

-- TODO: figure out how to build the rust program

function M.play(sound)
	if not sound or not Sounds.sound then
		return
	end

	-- TODO: integrate NvimSounds
	vim.notify("Played a sound")
	NvimSounds.play_tone(Sounds.sound)
end

function M.start()
	--[[
  --  1. vim.notify()?
  --  2. Map autocmds and sounds
  --]]
	M.play("ui.select")
end

function M.stop()
	--[[
  --  1. vim.notify()?
  --  2. Remove autocmds mappings
  --]]
end

return M
