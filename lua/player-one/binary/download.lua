local system = require("player-one.binary.system")

local M = {}

-- FIXME: conflict with `blink.cmp`
function M.get_plugin_root()
	local str = debug.getinfo(1).source
	return str:sub(2):gsub("/lua/player%-one/binary/download.lua$", "")
end

function M.get_binary_dir()
	local data_dir = vim.fn.stdpath("data")
	-- Add 'playerone' subdirectory
	return data_dir .. "/player-one/bin/playerone"
end

function M.get_binary_path()
	local bin_dir = M.get_binary_dir()
	local prefix = system.get_lib_prefix()
	local ext = system.get_lib_extension()
	return bin_dir .. "/" .. prefix .. "playerone" .. ext
end

function M.get_version_path()
	return M.get_binary_dir() .. "/version"
end

function M.get_checksum_path()
	return M.get_binary_path() .. ".sha256"
end

function M.ensure_binary_dir()
	local bin_dir = M.get_binary_dir()
	if vim.fn.isdirectory(bin_dir) == 0 then
		-- Create nested directories
		vim.fn.mkdir(bin_dir, "p")
	end
end

function M.get_current_version()
	local version_file = M.get_version_path()
	if vim.fn.filereadable(version_file) == 0 then
		return nil
	end
	return vim.fn.readfile(version_file)[1]
end

function M.download_file(url, output)
	local cmd = {
		"curl",
		"--fail",
		"--location",
		"--silent",
		url,
		"--output",
		output,
	}

	local result = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		error(string.format("Failed to download %s: %s", url, result))
	end
end

function M.verify_checksum(binary_path, checksum_path)
	local cmd
	if system.get_os() == "macos" then
		cmd = { "shasum", "-a", "256", binary_path }
	else
		cmd = { "sha256sum", binary_path }
	end

	local result = vim.fn.system(cmd)
	local actual = vim.split(result, "%s+")[1]
	local expected = vim.fn.readfile(checksum_path)[1]

	return actual == expected
end

function M.download_binary(version)
	M.ensure_binary_dir()

	local triple = system.get_target_triple()
	local base_url = string.format("https://github.com/jackplus-xyz/player-one.nvim/releases/download/%s", version)

	local bin_path = M.get_binary_path()
	local checksum_path = M.get_checksum_path()
	local temp_path = bin_path .. ".tmp"

	-- Download binary and checksum
	M.download_file(base_url .. "/" .. triple .. system.get_lib_extension(), temp_path)
	M.download_file(base_url .. "/" .. triple .. system.get_lib_extension() .. ".sha256", checksum_path)

	-- Verify checksum
	if not M.verify_checksum(temp_path, checksum_path) then
		os.remove(temp_path)
		error("Binary checksum verification failed")
	end

	-- Replace binary and save version
	os.rename(temp_path, bin_path)
	vim.fn.writefile({ version }, M.get_version_path())
end

function M.ensure_binary()
	local current_version = M.get_current_version()
	local required_version = "v0.1.0" -- or fetch latest from GitHub API

	if current_version ~= required_version then
		vim.notify("PlayerOne: Downloading binary...", vim.log.levels.INFO)
		M.download_binary(required_version)
		vim.notify("PlayerOne: Binary downloaded successfully", vim.log.levels.INFO)
	end
end

return M
