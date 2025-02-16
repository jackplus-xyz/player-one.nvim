local errors = require("player-one.binary.errors")
local paths = require("player-one.binary.paths")

local M = {}

---@class PlayerOne.VersionInfo
---@field current string|nil Currently installed version
---@field latest string|nil Latest available version
---@field dev boolean Whether a development build exists
---@field git table|nil Git repository information
---@field timestamp number When this info was last updated

function M.get_development_path()
	-- Use the same release directory for both dev and downloaded builds
	return paths.get_binary_path()
end

function M.get_install_path()
	-- Use the same path as development path
	return paths.get_binary_path()
end

function M.get_version_file()
	return paths.get_version_path()
end

-- Version checking
function M.get_git_info()
	local function get_git_command_output(...)
		local cmd = { "git", ... }
		local output = vim.fn.system(cmd)
		return vim.v.shell_error == 0 and vim.trim(output) or nil
	end

	local repo_path = paths.get_plugin_root()

	-- Check if we're in a git repo
	local is_git = vim.fn.finddir(".git", repo_path) ~= ""
	if not is_git then
		return nil
	end

	return {
		tag = get_git_command_output("-C", repo_path, "describe", "--tags", "--exact-match", "HEAD"),
		sha = get_git_command_output("-C", repo_path, "rev-parse", "HEAD"),
		branch = get_git_command_output("-C", repo_path, "rev-parse", "--abbrev-ref", "HEAD"),
	}
end

-- Rest of the functions remain the same, but use the new paths
function M.get_current_version()
	local version_file = M.get_version_file()
	if vim.fn.filereadable(version_file) == 1 then
		local content = vim.fn.readfile(version_file)
		if content and content[1] then
			return vim.trim(content[1])
		end
	end
	return nil
end

function M.get_latest_version()
	local cache_file = vim.fn.stdpath("cache") .. "/player-one-version"
	local current_time = os.time()

	if vim.fn.filereadable(cache_file) == 1 then
		local cache = vim.fn.readfile(cache_file)
		local timestamp = tonumber(cache[1])
		if current_time - timestamp < 86400 then -- 24 hours
			return cache[2]
		end
	end

	vim.defer_fn(function()
		local ok, result = pcall(vim.fn.system, {
			"curl",
			"--silent",
			"--fail",
			"https://api.github.com/repos/jackplus-xyz/player-one.nvim/releases/latest",
		})

		if ok then
			local release = vim.json.decode(result)
			if release and release.tag_name then
				vim.fn.writefile({ tostring(current_time), release.tag_name }, cache_file)
			end
		end
	end, 1000)

	-- Return cached or nil for now
	return vim.fn.filereadable(cache_file) == 1 and vim.fn.readfile(cache_file)[2] or nil
end

function M.has_development_build()
	local dev_path = M.get_development_path()
	return vim.fn.filereadable(dev_path) == 1
end

---Get complete version information
---@return PlayerOne.VersionInfo
function M.get_info()
	local ok, info = pcall(function()
		return {
			current = M.get_current_version(),
			latest = M.get_latest_version(),
			dev = M.has_development_build(),
			git = M.get_git_info(),
			timestamp = os.time(),
		}
	end)

	if not ok then
		error(errors.format_error("version_check_failed", info))
	end

	return info
end

---Check if binary needs updating
---@param info PlayerOne.VersionInfo Version information
---@return boolean needs_update
function M.needs_update(info)
	-- Development build takes precedence
	if info.dev then
		return false
	end

	-- No current version installed
	if not info.current then
		return true
	end

	-- Check cache validity (1 hour)
	if info.timestamp and (os.time() - info.timestamp) < 3600 then
		return false
	end

	-- Compare versions
	return info.current ~= info.latest
end

---Write version information to file
---@param version string Version to write
function M.write_version(version)
	local version_file = M.get_version_file()
	-- Ensure directory exists before writing
	local dir = vim.fn.fnamemodify(version_file, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok = pcall(vim.fn.writefile, { version }, version_file)
	if not ok then
		error(errors.format_error("version_write_failed", "Failed to write to " .. version_file))
	end
end

return M
