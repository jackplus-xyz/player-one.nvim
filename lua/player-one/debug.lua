local M = {}

function M.print_table(t)
	for k, v in pairs(t) do
		print(k, v)
	end
end

function M.log_time(label, start_time)
	local elapsed = (vim.uv.hrtime() - start_time) / 1e6 -- Convert to ms
	vim.notify(string.format("PlayerOne: %s took %f ms", label, elapsed * 100))
end

return M
