local M = {}

-- Predefined sound configurations
M.ui = {
	enter = {},
	select = {},
	back = {},
	error = {},
	success = {},
	notification = {},
}

-- Sound utilities
function M.parse_json_config(json_string)
	local ok, config = pcall(vim.json.decode, json_string)
	if not ok then
		error("Failed to parse sound configuration: " .. config)
	end
	return M.sanitize_config(config)
end

return M

