local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local files = require("player-one.binary.download.files")
local paths = require("player-one.binary.paths")
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

---Safely download and install binary
---@param ver string Version to download
function M.ensure_binary(ver)
	-- Ensure release directory exists
	files.ensure_dir(paths.get_release_dir())

	-- Get download URLs
	local urls = M.get_download_urls(ver)

	vim.notify(string.format("PlayerOne: Downloading v%s binary...", ver), vim.log.levels.INFO)

	-- Download files with cleanup on failure
	local ok, err = pcall(function()
		-- Download to temporary location
		files.download_file(urls.binary, paths.get_temp_path())
		files.download_file(urls.checksum, paths.get_checksum_path())

		-- Verify checksum
		files.verify_checksum(paths.get_temp_path(), paths.get_checksum_path())

		-- Atomic replace
		files.rename_file(paths.get_temp_path(), paths.get_binary_path())

		-- Update version
		version.write_version(ver)
	end)

	-- Cleanup on failure
	if not ok then
		files.delete_file(paths.get_temp_path())
		error(err) -- Re-throw the error
	end

	vim.notify("PlayerOne: Binary downloaded successfully", vim.log.levels.INFO)
end

return M
