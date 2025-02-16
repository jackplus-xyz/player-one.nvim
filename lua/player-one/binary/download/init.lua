local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local files = require("player-one.binary.download.files")
local errors = require("player-one.binary.errors")

local M = {}

function M.get_download_urls(ver)
	local triple = system.get_target_triple()
	local base_url = string.format("https://github.com/jackplus-xyz/player-one.nvim/releases/download/%s", ver)

	return {
		binary = string.format("%s/%s%s", base_url, triple, system.get_lib_extension()),
		checksum = string.format("%s/%s%s.sha256", base_url, triple, system.get_lib_extension()),
	}
end

function M.download_file(url, output_path)
	local cmd = {
		"curl",
		"--fail",
		"--location",
		"--silent",
		"--show-error",
		url,
		"--output",
		output_path,
	}

	local ok, result = pcall(vim.fn.system, cmd)
	if not ok or vim.v.shell_error ~= 0 then
		error(errors.format_error("download_failed", string.format("Failed to download %s: %s", url, result)))
	end
end

---Safely download and install binary
---@param ver string Version to download
function M.ensure_binary(ver)
	local paths = files.get_paths()

	-- Ensure binary directory exists
	files.ensure_dir(paths.bin)

	-- Get download URLs
	local urls = M.get_download_urls(ver)

	vim.notify(string.format("PlayerOne: Downloading v%s binary...", ver), vim.log.levels.INFO)

	-- Download files with cleanup on failure
	local ok, err = pcall(function()
		-- Download to temporary location
		M.download_file(urls.binary, paths.temp)
		M.download_file(urls.checksum, paths.checksum)

		-- Verify checksum
		files.verify_checksum(paths.temp, paths.checksum)

		-- Atomic replace
		files.rename_file(paths.temp, paths.lib)

		-- Update version
		version.write_version(ver)
	end)

	-- Cleanup on failure
	if not ok then
		files.delete_file(paths.temp)
		error(err) -- Re-throw the error
	end

	vim.notify("PlayerOne: Binary downloaded successfully", vim.log.levels.INFO)
end

return M
