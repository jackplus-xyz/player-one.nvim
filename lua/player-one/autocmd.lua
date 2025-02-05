local State = require("player-one.state")
local Utils = require("player-one.utils")
local SoundPreset = {}

local M = {}

local function create_autocmds()
	local group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			if State.is_enabled then
				Utils.play(SoundPreset.welcome)
			end
		end,
	})

	vim.api.nvim_create_autocmd("TextChangedI", {
		group = group,
		callback = function()
			if State.is_enabled then
				local variation = math.random(-20, 20)
				local type = vim.deepcopy(SoundPreset.type)
				type.base_freq = type.base_freq + variation
				Utils.play(type)
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		callback = function()
			if State.is_enabled then
				local variation = math.random(-10, 10)
				local move = vim.deepcopy(SoundPreset.move)
				move.base_freq = move.base_freq + variation
				Utils.play(move)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function()
			if State.is_enabled then
				Utils.play(SoundPreset.save)
			end
		end,
	})

	vim.api.nvim_create_autocmd("TextYankPost", {
		group = group,
		callback = function()
			if State.is_enabled then
				Utils.play(SoundPreset.yank)
			end
		end,
	})

	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = group,
		callback = function()
			if State.is_enabled then
				Utils.play(SoundPreset.cmdline)
			end
		end,
	})

	-- TextChangedP: after pasting
	-- CmdlineChanged

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			if State.is_enabled then
				Utils.play(SoundPreset.exit)
				os.execute("sleep 0.2") -- Play the sound before exiting
			end
		end,
	})
end

function M.setup(sound_preset)
	if sound_preset then
		SoundPreset = require("player-one.sounds.presets." .. sound_preset)
		create_autocmds()
	end
end

return M
