local M = {}

function M.setup(options)
	for k, v in pairs(options) do
		M[k] = v
	end

	if options.theme then
		M.curr_theme = options.theme
	end

	-- TODO: add more preset?
	-- { "chiptune" ,"synth" ,"crystal" ,"mechanical" ,"minimal" ,"retro" ,"ambient" ,"digital" }
	M.presets = { "chiptune", "synth", "crystal" }
	M.group = vim.api.nvim_create_augroup("PlayerOne", { clear = true })
end

return M
