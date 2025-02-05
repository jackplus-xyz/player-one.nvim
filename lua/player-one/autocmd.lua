local State = require("player-one.state")
local Utils = require("player-one.utils")
local SoundPreset = {}

local M = {}

local group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

local function create_autocmds(autocmd, sound, callback)
	vim.api.nvim_create_autocmd(autocmd, {
		group = group,
		callback = callback or function()
			if State.is_enabled then
				Utils.play(sound)
			end
		end,
	})
end

local function vim_leave_pre_callback()
	if State.is_enabled then
		Utils.play(SoundPreset.vim_leave_pre)
		os.execute("sleep 0.5")
	end
end

local function cursor_moved_callback()
	vim.defer_fn(function()
		vim.api.nvim_create_autocmd({ "CursorMoved" }, {
			group = group,
			callback = function()
				if State.is_enabled then
					Utils.play(SoundPreset.cursor_moved)
				end
			end,
		})
	end, 1000) -- add 1 second delay so it won't trigger on VimEnter
end

function M.setup(sound_preset)
	if sound_preset then
		SoundPreset = require("player-one.sounds.presets." .. sound_preset)
	end

	create_autocmds("VimEnter", SoundPreset.vim_enter)
	create_autocmds("VimLeavePre", SoundPreset.vim_leave_pre, vim_leave_pre_callback)
	create_autocmds("BufWritePost", SoundPreset.buf_write_post)
	create_autocmds("TextChangedI", SoundPreset.text_changed_i)
	create_autocmds("TextYankPost", SoundPreset.text_yank_post)
	create_autocmds("VimEnter", SoundPreset.cursor_moved, cursor_moved_callback)
	create_autocmds("CmdlineEnter", SoundPreset.cmdline_enter)
	create_autocmds("CmdlineChanged", SoundPreset.cmdline_changed)
end

return M
