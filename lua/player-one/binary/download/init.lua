local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local files = require("player-one.binary.download.files")
local paths = require("player-one.binary.paths")
local errors = require("player-one.binary.errors")

local M = {}

function M.ensure_release_dir()
	local dir = paths.get_release_dir()
	if vim.fn.isdirectory(dir) == 0 then
		local ok = pcall(vim.fn.mkdir, dir, "p")
		if not ok then
			error(errors.format_error("dir_create_failed", dir))
		end
	end
end

function M.get_download_urls(ver)
	local triple = system.get_target_triple()
	local base = string.format("https://github.com/jackplus-xyz/player-one.nvim/releases/download/%s", ver)
	local name = paths.get_binary_name()

	return {
		binary = base .. "/" .. triple .. system.get_lib_extension(),
		checksum = base .. "/" .. triple .. system.get_lib_extension() .. ".sha256",
	}
end

function M.ensure_binary(ver)
	-- Ensure release directory exists
	M.ensure_release_dir()

	-- Get paths
	local binary_path = paths.get_binary_path()
	local temp_path = paths.get_temp_path()
	local checksum_path = paths.get_checksum_path()

	-- Get download URLs
	local urls = M.get_download_urls(ver)

	vim.notify(string.format("PlayerOne: Downloading v%s binary...", ver), vim.log.levels.INFO)

	-- Download and verify with cleanup on failure
	local ok, err = pcall(function()
		files.download_file(urls.binary, temp_path)
		files.download_file(urls.checksum, checksum_path)
		files.verify_checksum(temp_path, checksum_path)
		files.rename_file(temp_path, binary_path)
		version.write_version(ver)
	end)

	if not ok then
		files.delete_file(temp_path)
		error(err)
	end

	vim.notify("PlayerOne: Binary downloaded successfully", vim.log.levels.INFO)
end

return M
