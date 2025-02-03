local Api = require("player-one.api")
local State = require("player-one.state")

local M = {}

-- TODO: Add type annotations for better IDE support
local defaults = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})

	State.setup()

	vim.api.nvim_create_user_command("PlayerOneEnable", Api.enable, { desc = "Enable Player One" })
	vim.api.nvim_create_user_command("PlayerOneDisable", Api.disable, { desc = "Disable Player One" })
	vim.api.nvim_create_user_command("PlayerOneToggle", Api.toggle, { desc = "Toggle Player One" })

	if M.options.enabled then
		Api.enable()
	end
end

return M
