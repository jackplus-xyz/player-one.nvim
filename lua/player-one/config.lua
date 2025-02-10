local Api = require("player-one.api")
local State = require("player-one.state")

local M = {}

-- TODO:
-- 1. Sound Pack System Restructure
--    - Update defaults to support flexible sound configuration
--    - Add sound pack detection helper functions
--    - Implement sound pack registration logic
-- 2. Sound Pack Management
--    - Add API for loading/switching sound packs
--    - Create commands for pack management (:PlayerOneLoad)
--    - Implement pack listing functionality
-- 3. Flexible Configuration Options
--    - Support string input for preset packs
--    - Support direct sound definitions table
--    - Support multiple named sound packs
-- 4. Sound Pack Extension System
--    - Add 'extend' configuration option
--    - Implement pack extension logic
--    - Add protection for built-in packs
-- 5. User Feedback
--    - Add warnings for pack overwrites
--    - Add notifications for pack extensions
--    - Implement proper error handling
-- 6. Commands and API
--    - Update user commands to support new functionality
--    - Implement pack completion for commands
--    - Add pack management API functions

---@class PlayerOneConfig
---@field is_enabled boolean Whether the plugin is enabled
---@field theme string|table Either a preset name or custom sounds table, see :help player-one-sounds
---@field min_interval number Minimum interval between sounds in seconds
local defaults = {
	is_enabled = true,
	min_interval = 0.05,
	theme = "chiptune",
}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})

	State.setup(M.options)

	vim.api.nvim_create_user_command("PlayerOneEnable", Api.enable, { desc = "Enable Player One" })
	vim.api.nvim_create_user_command("PlayerOneDisable", Api.disable, { desc = "Disable Player One" })
	vim.api.nvim_create_user_command("PlayerOneToggle", Api.toggle, { desc = "Toggle Player One" })

	if State.is_enabled then
		Api.enable()
	end
end

return M
