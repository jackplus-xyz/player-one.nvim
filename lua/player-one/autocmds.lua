local Themes = require("player-one.themes")
local Api = require("player-one.api")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("PlayerOneEnable", Api.enable, { desc = "Enable Player One" })
	vim.api.nvim_create_user_command("PlayerOneDisable", Api.disable, { desc = "Disable Player One" })
	vim.api.nvim_create_user_command("PlayerOneToggle", Api.toggle, { desc = "Toggle Player One" })
	vim.api.nvim_create_user_command(
		"PlayerOneLoad",
		function(opts)
			local theme = opts.args
			if theme ~= "" then
				M.load_theme(theme)
				vim.notify(theme .. " Loaded")
			else
				-- TODO:add theme picker
				-- FIXME: not loading default theme
				M.load_theme()
			end
		end,
		--    {
		-- 	nargs = "?",
		-- 	desc = "Load Player One theme",
		-- 	complete = function()
		-- 		return Themes.get_theme_names()
		-- 	end,
		-- }
		{}
	)
end

return M
