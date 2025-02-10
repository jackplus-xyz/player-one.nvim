local M = {}

function M.setup(options)
	for k, v in pairs(options) do
		M[k] = v
	end

	if options.theme then
		M.curr_theme = options.theme
	end
end

return M
