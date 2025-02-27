local M = {}

function M.print_table(t)
	for k, v in pairs(t) do
		print(k, v)
	end
end

return M
