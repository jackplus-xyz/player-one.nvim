local Api = require("player-one.api")
local Autocmds = require("player-one.autocmds")
local State = require("player-one.state")

local M = {}

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
	Autocmds.setup()

	if State.is_enabled then
		Api.enable()
	end
end

return M
