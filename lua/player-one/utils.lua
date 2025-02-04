local Lib = require("player-one.lib")

local M = {}

-- TODO: implement
local function sanitize_params(params)
	return params
end

local function parse_json_params(json_params)
	local ok, params = pcall(vim.json.decode, json_params)
	if not ok then
		error("Failed to parse sound paramsuration: " .. params)
	end
	return sanitize_params(params)
end

function M.play(params)
	if type(params) == "string" then
		params = parse_json_params(params)
	elseif type(params) == "table" then
		params = sanitize_params(params)
	else
		error("Invalid sound configuration type")
	end

	return Lib.play(params)
end

function M.play_async(params)
	return Lib.play_async(params)
end

function M.start()
	-- Initialize any required resources
end

function M.stop()
	return Lib.stop()
end

return M
