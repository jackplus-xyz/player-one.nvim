--- State management module for PlayerOne
--- Maintains global configuration and plugin state
---@module 'player-one.state'
---@usage [[
---# Access plugin state
---local State = require("player-one.state")
---print(State.is_enabled) -- Check if plugin is enabled
---print(State.curr_theme) -- Get current theme
---]]
local M = {}

function M.setup(options)
	for k, v in pairs(options) do
		M[k] = v
	end

	if options.theme then
		M.curr_theme = options.theme
	end

	-- Available built-in themes
	---@type string[] List of available theme names
	M.themes = { "chiptune", "synth", "crystal" }

	if type(options.theme) == "table" then
		table.insert(M.themes, "user")
	end

	-- Create autocmd group for plugin events
	---@type number Autocmd group ID
	M.group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

	-- Internal state flags
	---@type boolean Whether cursor movement sounds are enabled
	M._is_cursormoved_enabled = false
end

return M
