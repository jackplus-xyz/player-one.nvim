-- Binary compilation and loading functionality adapted from:
-- https://github.com/Saghen/blink.cmp/tree/main/lua/blink/cmp/fuzzy

local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local download = require("player-one.binary.download")
local paths = require("player-one.binary.paths")
local errors = require("player-one.binary.errors")

local M = {}

-- Cache for loaded library
local loaded_lib = nil

-- Cache for version info to prevent frequent checks
local version_info_cache = {
	info = nil,
	timestamp = 0,
}

---Check if version info cache is valid
---@return boolean
local function is_cache_valid()
	return version_info_cache.info and (os.time() - version_info_cache.timestamp) < 3600 -- 1 hour cache
end

---Get version info with caching
---@return PlayerOne.VersionInfo
local function get_cached_version_info()
	if not is_cache_valid() then
		version_info_cache.info = version.get_info()
		version_info_cache.timestamp = os.time()
	end
	return version_info_cache.info
end

---Attempt to load library from path
---@param path string Full path to library file
---@return table|nil lib Loaded library or nil if failed
---@return string|nil error Error message if failed
local function try_load_library(path)
	-- Check if file exists and is readable
	if vim.fn.filereadable(path) ~= 1 then
		return nil, "File not readable: " .. path
	end

	local symbol = "luaopen_libplayerone"

	-- Attempt to load the library
	local ok, result = pcall(function()
		local loader = package.loadlib(path, symbol)
		if not loader then
			error("Failed to load library: " .. path)
		end
		return loader()
	end)

	if not ok then
		return nil, tostring(result)
	end

	return result
end

---Initialize the binary system
---@return boolean success Whether initialization succeeded
function M.initialize()
	-- Check system compatibility
	if not system.get_target_triple() then
		error(errors.format_error("unsupported_system"))
	end

	-- Get cached version info
	local info = get_cached_version_info()

	-- Log initialization state
	vim.notify(
		string.format(
			"PlayerOne: Initializing binary system\n"
				.. "  - Development build: %s\n"
				.. "  - Current version: %s\n"
				.. "  - Latest version: %s",
			info.dev and "Yes" or "No",
			info.current or "Not installed",
			info.latest or "Unknown"
		),
		vim.log.levels.DEBUG
	)

	-- Always return true since errors will be thrown
	return true
end

---Load the appropriate binary
---@return table library The loaded library
function M.load_binary()
	-- Return cached library if available
	if loaded_lib then
		return loaded_lib
	end

	-- Initialize binary system
	M.initialize()

	-- Get version information
	local info = get_cached_version_info()

	-- Try loading development binary first
	if info.dev then
		local dev_path = version.get_development_path()
		local lib, err = try_load_library(dev_path)

		if lib then
			vim.notify("PlayerOne: Using development build", vim.log.levels.INFO)
			loaded_lib = lib
			return lib
		else
			vim.notify("PlayerOne: Failed to load development build: " .. err, vim.log.levels.WARN)
		end
	end

	-- Check if we need to download/update binary
	if version.needs_update(info) then
		local ok, err = pcall(download.ensure_binary, info.latest)
		if not ok then
			error(errors.format_error("binary_load_failed", err))
		end
		-- Invalidate version cache after download
		version_info_cache.info = nil
	end

	-- Try loading installed binary
	local install_path = version.get_install_path()
	local lib, err = try_load_library(install_path)

	if not lib then
		error(errors.format_error("binary_load_failed", err))
	end

	loaded_lib = lib
	return lib
end

---Clear the library cache
---@return boolean success Whether cache was cleared
function M.clear_cache()
	loaded_lib = nil
	version_info_cache = {
		info = nil,
		timestamp = 0,
	}
	return true
end

-- Export the loaded library directly
return M.load_binary()
