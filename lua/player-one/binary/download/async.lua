local uv = vim.uv

local M = {}

---Execute a function asynchronously with a timeout
---@param fn function Function to execute
---@param timeout? number Timeout in milliseconds (default: 60000)
---@return boolean success Whether execution succeeded
---@return any result Result from the function or error message
function M.with_timeout(fn, timeout)
	timeout = timeout or 60000
	local done = false
	local result = nil
	local success = false

	-- Create timer for timeout
	local timer = uv.new_timer()
	timer:start(timeout, 0, function()
		if not done then
			done = true
			timer:stop()
			timer:close()
			success = false
			result = string.format("Operation timed out after %d ms", timeout)
		end
	end)

	-- Execute function
	local ok, ret = pcall(fn)
	if not done then
		done = true
		timer:stop()
		timer:close()
		success = ok
		result = ret
	end

	return success, result
end

---Run a shell command asynchronously
---@param cmd table Command and arguments
---@param timeout? number Timeout in milliseconds
---@return boolean success Whether command succeeded
---@return string output Command output or error message
function M.run_command(cmd, timeout)
	local output = ""
	local error_output = ""
	local handle = nil
	local stdout = uv.new_pipe()
	local stderr = uv.new_pipe()

	local function on_exit(code)
		if handle then
			handle:close()
			stdout:close()
			stderr:close()
		end

		if code ~= 0 then
			return false, error_output ~= "" and error_output or "Command failed with code " .. code
		end
		return true, output
	end

	handle = uv.spawn(cmd[1], {
		args = vim.list_slice(cmd, 2),
		stdio = { nil, stdout, stderr },
	}, vim.schedule_wrap(on_exit))

	if not handle then
		stdout:close()
		stderr:close()
		return false, "Failed to spawn process"
	end

	stdout:read_start(function(err, data)
		if err then
			error_output = error_output .. "\nError reading stdout: " .. err
		end
		if data then
			output = output .. data
		end
	end)

	stderr:read_start(function(err, data)
		if err then
			error_output = error_output .. "\nError reading stderr: " .. err
		end
		if data then
			error_output = error_output .. data
		end
	end)

	return M.with_timeout(function()
		-- Wait for process to complete
		vim.wait(timeout or 60000, function()
			return not handle:is_active()
		end)
		return on_exit(handle:get_exit_code())
	end, timeout)
end

return M
