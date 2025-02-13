local M = {}

function M.setup(options)
	for k, v in pairs(options) do
		M[k] = v
	end

	if options.theme then
		M.curr_theme = options.theme
	end

	M.themes = { "chiptune", "synth", "crystal" }
	M.group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })

	-- Handle state for default themes
	M._is_cursormoved_enabled = false
end

return M
