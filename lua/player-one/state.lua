local M = {}

function M.setup(options)
	for k, v in pairs(options) do
		M[k] = v
	end
end

return M
