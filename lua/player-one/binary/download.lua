local system = require("player-one.binary.system")

local M = {}

function M.get_plugin_root()
	local str = debug.getinfo(1).source
	return str:sub(2):gsub("/lua/player%-one/binary/download.lua$", "")
end

function M.get_binary_dir()
	local data_dir = vim.fn.stdpath("data")
	return data_dir .. "/player-one/bin"
end

function M.get_binary_path()
	local bin_dir = M.get_binary_dir()
	local prefix = system.get_lib_prefix()
	local ext = system.get_lib_extension()
	return bin_dir .. "/" .. prefix .. "player_one" .. ext
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
	if vim.v.shell_error ~= 0 then
		error(string.format("Failed to compute checksum: %s", result))
	end

	if vim.fn.filereadable(checksum_path) == 0 then
		error(string.format("Checksum file not found or not readable: %s", checksum_path))
	end

	-- Extract only the hash part from both strings
	local actual = vim.split(result, "%s+")[1]
	local expected = vim.split(vim.fn.readfile(checksum_path)[1], "%s+")[1]

	return actual == expected
end

function M.download_binary(version)
	M.ensure_binary_dir()

	local triple = system.get_target_triple()
	local base_url = string.format("https://github.com/jackplus-xyz/player-one.nvim/releases/download/%s", version)

	local bin_path = M.get_binary_path()
	local checksum_path = M.get_checksum_path()
	local temp_path = bin_path .. ".tmp"

	local bin_url = string.format("%s/%s%s", base_url, triple, system.get_lib_extension())
	local checksum_url = bin_url .. ".sha256"

	vim.notify("Downloading binary from: " .. bin_url, vim.log.levels.INFO)
	vim.notify("Downloading checksum from: " .. checksum_url, vim.log.levels.INFO)

	-- Download files with better error handling
	local ok, err = pcall(function()
		M.download_file(bin_url, temp_path)
		M.download_file(checksum_url, checksum_path)
	end)

	if not ok then
		-- Clean up temp files on error
		pcall(vim.fn.delete, temp_path)
		pcall(vim.fn.delete, checksum_path)
		error(string.format("Download failed: %s", err))
	end

	-- Single verification attempt with better error messages
	if not M.verify_checksum(temp_path, checksum_path) then
		local actual = vim.fn.system({ "shasum", "-a", "256", temp_path })
		local expected = vim.fn.readfile(checksum_path)[1]
		-- Clean up temp files
		pcall(vim.fn.delete, temp_path)
		pcall(vim.fn.delete, checksum_path)
		error(string.format("Checksum verification failed:\nExpected: %s\nActual: %s", expected, actual))
	end

	-- Atomic rename
	ok, err = pcall(function()
		os.rename(temp_path, bin_path)
		vim.fn.writefile({ version }, M.get_version_path())
	end)

	if not ok then
		pcall(vim.fn.delete, temp_path)
		error(string.format("Failed to install binary: %s", err))
	end

	vim.notify("Binary installed successfully", vim.log.levels.INFO)
end

function M.ensure_binary()
	local current_version = M.get_current_version()
	local required_version = vim.fn
		.system(
			"curl -s https://api.github.com/repos/jackplus-xyz/player-one.nvim/releases/latest | grep 'tag_name' | cut -d '\"' -f 4"
		)
		:gsub("%s+", "")

	if current_version ~= required_version then
		vim.notify("PlayerOne: Downloading binary...", vim.log.levels.INFO)
		M.download_binary(required_version)
		vim.notify("PlayerOne: Binary downloaded successfully", vim.log.levels.INFO)
	end
end

return M
