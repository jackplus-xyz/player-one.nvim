local M = {}

-- Constants
local MIN_NVIM_VERSION = { major = 0, minor = 8 }
local HTTP_OK = 200
local GITHUB_URL = "https://github.com"
local TIMEOUT_SECONDS = 5

-- Platform specific commands
local AUDIO_COMMANDS = {
	Darwin = {
		check = "system_profiler SPAudioDataType",
		grep = "grep 'Output:'",
		format = "awk '{$1=\"\"; print $0}'",
	},
}

function M.check()
	vim.health.start("PlayerOne Binary")

	-- Check OS compatibility
	local os_name = vim.uv.os_uname().sysname
	local is_wsl = vim.fn.has("wsl") == 1

	if is_wsl then
		vim.health.warn("Running under WSL - audio output might not work correctly")
	end

	-- Check required system executables
	local required_executables = { "curl", "git" }
	if os_name == "Windows_NT" then
		table.insert(required_executables, "certutil")
	else
		table.insert(required_executables, "sha256sum")
	end

	for _, executable in ipairs(required_executables) do
		if vim.fn.executable(executable) == 0 then
			vim.health.error(string.format("%s is not installed", executable))
		else
			vim.health.ok(string.format("%s is installed", executable))
		end
	end

	-- Check audio output (platform specific)
	if os_name == "Darwin" then
		local cmd = AUDIO_COMMANDS.Darwin
		local check_result = vim.fn.system(cmd.check)
		local grep_result = vim.fn.system(string.format("echo '%s' | %s", check_result, cmd.grep))
		local audio_device = vim.fn.system(string.format("echo '%s' | %s", grep_result, cmd.format))

		if vim.v.shell_error ~= 0 then
			vim.health.warn("Could not detect audio output device")
		else
			vim.health.ok(
				string.format("Audio output device detected: %s", audio_device:gsub("^%s+", ""):gsub("%s+$", ""))
			)
		end
	end

	-- Version compatibility check
	local nvim_version = vim.version()
	if
		nvim_version.major < MIN_NVIM_VERSION.major
		or (nvim_version.major == MIN_NVIM_VERSION.major and nvim_version.minor < MIN_NVIM_VERSION.minor)
	then
		vim.health.error(
			string.format("Neovim version must be %d.%d or higher", MIN_NVIM_VERSION.major, MIN_NVIM_VERSION.minor)
		)
	else
		vim.health.ok(string.format("Neovim version compatible: %d.%d", nvim_version.major, nvim_version.minor))
	end
end

--- Validates and checks the status of the PlayerOne binary installation
--- Verifies that:
--- - The release directory exists and is accessible
--- - The binary exists and has correct permissions
--- - The binary path is secure (no path traversal)
--- @param opts {path: string, release_dir: string}
--- @return {path: string}?
function M.check_binary_status(opts)
	-- Validate paths for security
	if opts.path:match("%.%.") or opts.release_dir:match("%.%.") then
		vim.health.error("Invalid path detected - path traversal not allowed")
		return nil
	end

	if vim.fn.isdirectory(opts.release_dir) == 0 then
		vim.health.warn(string.format("Release directory does not exist: %s", opts.release_dir))
	else
		vim.health.ok(string.format("Release directory exists: %s", opts.release_dir))
	end

	if vim.fn.filereadable(opts.path) == 0 then
		vim.health.error(string.format("Binary not found: %s", opts.path))
		return nil
	else
		vim.health.ok(string.format("Binary is installed: %s", opts.path))
	end

	return { path = opts.path }
end

--- Checks connectivity to GitHub's API
--- Verifies that:
--- - Network connection is available
--- - GitHub API is accessible
--- - Response is received within timeout period
function M.check_github_status()
	local curl_cmd = string.format("curl -Is --connect-timeout %d %s", TIMEOUT_SECONDS, GITHUB_URL)
	local curl_handle = io.popen(curl_cmd)
	if not curl_handle then
		vim.health.error("Failed to initialize network check")
		return
	end

	local curl_output = curl_handle:read("*a")
	local exit_code = curl_handle:close()

	if not exit_code then
		vim.health.error("Connection to GitHub timed out")
		return
	end

	if curl_output and curl_output:match(string.format("HTTP/[%%d.]+ %d", HTTP_OK)) then
		vim.health.ok("GitHub connectivity: OK")
	else
		vim.health.warn("GitHub connectivity issues - binary downloads may fail. Please check your network connection")
	end
end

return M
