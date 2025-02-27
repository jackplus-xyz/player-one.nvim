local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local files = require("player-one.binary.download.files")
local paths = require("player-one.binary.paths")
local errors = require("player-one.binary.errors")

-- FIXME: Binary error on first installation on Linux (Fedora) #12
local M = {}

---Get download URLs for binary and checksum
---@param ver string Version to download
---@return {binary: string, checksum: string} URLs for binary and checksum
function M.get_download_urls(ver)
	if not ver then
		error(errors.format_error("download_failed", "No version specified"))
	end

	local triple = system.get_target_triple()
	if not triple then
		error(errors.format_error("unsupported_system", "Could not determine system triple"))
	end

	local base_url = string.format("https://github.com/jackplus-xyz/player-one.nvim/releases/download/%s", ver)

	return {
		binary = string.format("%s/%s%s", base_url, triple, system.get_lib_extension()),
		checksum = string.format("%s/%s%s.sha256", base_url, triple, system.get_lib_extension()),
	}
end

---Clean up temporary files after a failed download
---@param temp_path string Path to temporary binary file
---@param checksum_path string Path to checksum file
local function cleanup_failed_download(temp_path, checksum_path)
	local cleanup_errors = {}

	-- Try to delete temporary binary file
	local ok1, err1 = pcall(files.delete_file, temp_path)
	if not ok1 then
		table.insert(cleanup_errors, string.format("Failed to delete temp file: %s", err1))
	end

	-- Try to delete checksum file
	local ok2, err2 = pcall(files.delete_file, checksum_path)
	if not ok2 then
		table.insert(cleanup_errors, string.format("Failed to delete checksum file: %s", err2))
	end

	-- Return cleanup errors if any occurred
	if #cleanup_errors > 0 then
		return false, table.concat(cleanup_errors, "\n")
	end
	return true
end

---Safely download and install binary
---@param ver string Version to download
function M.ensure_binary(ver)
	local config = require("player-one.config").options

	if not config.binary.auto_update then
		-- Skip version checks, only download if binary doesn't exist
		local binary_path = paths.get_binary_path()
		if vim.fn.filereadable(binary_path) == 1 then
			return true
		end
	end

	if not ver then
		error(errors.format_error("download_failed", "No version specified"))
	end

	-- Get all required paths
	local release_dir = paths.get_release_dir()
	local temp_path = paths.get_temp_path()
	local checksum_path = paths.get_checksum_path()
	local binary_path = paths.get_binary_path()

	-- Ensure release directory exists
	local ok, err = pcall(files.ensure_dir, release_dir)
	if not ok then
		error(errors.format_error("download_failed", string.format("Failed to create release directory: %s", err)))
	end

	-- Get download URLs
	local urls
	ok, err = pcall(M.get_download_urls, ver)
	if not ok then
		error(errors.format_error("download_failed", string.format("Failed to generate download URLs: %s", err)))
	end
	urls = err

	vim.notify(string.format("PlayerOne: Downloading v%s binary...\nFrom: %s", ver, urls.binary), vim.log.levels.INFO)

	-- Download and install with proper cleanup
	ok, err = pcall(function()
		-- Download files
		files.download_file(urls.binary, temp_path)
		vim.notify("Downloaded binary, fetching checksum...", vim.log.levels.DEBUG)

		files.download_file(urls.checksum, checksum_path)
		vim.notify("Verifying checksum...", vim.log.levels.DEBUG)

		-- Verify checksum
		files.verify_checksum(temp_path, checksum_path)
		vim.notify("Checksum verified, installing...", vim.log.levels.DEBUG)

		-- Atomic replace
		files.rename_file(temp_path, binary_path)
		vim.notify("Binary installed, updating version...", vim.log.levels.DEBUG)

		-- Update version file
		version.write_version(ver)
	end)

	-- Handle any errors during the process
	if not ok then
		-- Try to clean up
		local cleanup_ok, cleanup_err = cleanup_failed_download(temp_path, checksum_path)

		-- Combine errors if cleanup also failed
		if not cleanup_ok then
			err = string.format("%s\nAdditional cleanup errors:\n%s", err, cleanup_err)
		end

		error(errors.format_error("download_failed", err))
	end

	vim.notify(string.format("PlayerOne: Binary %s downloaded and installed successfully", ver), vim.log.levels.INFO)
end

---Clear downloaded binary cache
---@param force boolean? Force removal of current binary too (defaults to false)
---@return boolean success True if cache was cleared successfully
---@return string? error Error message if clearing failed
function M.clear_cache(force)
	local release_dir = paths.get_release_dir()
	local binary_path = paths.get_binary_path()
	local temp_path = paths.get_temp_path()
	local checksum_path = paths.get_checksum_path()
	local version_path = paths.get_version_path()

	local errors = {}

	-- Remove temporary files if they exist
	if vim.fn.filereadable(temp_path) == 1 then
		local ok, err = pcall(files.delete_file, temp_path)
		if not ok then
			table.insert(errors, string.format("Failed to delete temp file: %s", err))
		end
	end

	if vim.fn.filereadable(checksum_path) == 1 then
		local ok, err = pcall(files.delete_file, checksum_path)
		if not ok then
			table.insert(errors, string.format("Failed to delete checksum file: %s", err))
		end
	end

	-- If force is true, also remove current binary and version file
	if force then
		if vim.fn.filereadable(binary_path) == 1 then
			local ok, err = pcall(files.delete_file, binary_path)
			if not ok then
				table.insert(errors, string.format("Failed to delete binary file: %s", err))
			end
		end

		if vim.fn.filereadable(version_path) == 1 then
			local ok, err = pcall(files.delete_file, version_path)
			if not ok then
				table.insert(errors, string.format("Failed to delete version file: %s", err))
			end
		end
	end

	-- Return results
	if #errors > 0 then
		return false, table.concat(errors, "\n")
	end

	vim.notify("PlayerOne: Cache cleared successfully", vim.log.levels.INFO)
	return true
end

---Update binary to specified version with option to clear cache first
---@param ver string Version to download
---@param clear_cache boolean? Whether to clear cache before downloading (defaults to false)
function M.update_binary(ver, clear_cache)
	if clear_cache then
		local ok, err = M.clear_cache(true)
		if not ok then
			vim.notify("PlayerOne: Cache clearing had issues: " .. err, vim.log.levels.WARN)
		end
	end

	M.ensure_binary(ver)
end

return M
