-- Binary compilation and loading functionality adapted from:
-- https://github.com/Saghen/blink.cmp/tree/main/lua/blink/cmp/fuzzy

local system = require("player-one.binary.system")
local version = require("player-one.binary.version")
local download = require("player-one.binary.download")
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
	if not version_info_cache.info or not version_info_cache.timestamp then
		return false
	end
	return (os.time() - version_info_cache.timestamp) < 3600 -- 1 hour cache
end

---Get version info with caching
---@return PlayerOne.VersionInfo
---@throws string When version info cannot be retrieved
local function get_cached_version_info()
	if not is_cache_valid() then
		local ok, info_or_err = pcall(version.get_info)
		if not ok then
			error(errors.format_error("version_check_failed", info_or_err))
		end
		version_info_cache.info = info_or_err
		version_info_cache.timestamp = os.time()
	end
	return version_info_cache.info
end

---Attempt to load library from path
---@param path string Full path to library file
---@return table|nil lib Loaded library or nil if failed
---@return string|nil error Error message if failed
local function try_load_library(path)
	if not path then
		return nil, "No path provided"
	end

	-- Check if file exists and is readable
	if vim.fn.filereadable(path) ~= 1 then
		return nil, string.format("File not readable: %s", path)
	end

	local symbol = "luaopen_libplayerone"

	-- Attempt to load the library
	local ok, result = pcall(function()
		local loader = package.loadlib(path, symbol)
		if not loader then
			error(string.format("Failed to load library: %s", path))
		end
		return loader()
	end)

	if not ok then
		return nil, tostring(result)
	end

	return result
end

---Initialize the binary system
---@return boolean success Always returns true or throws an error
---@throws string When system is not supported or initialization fails
function M.init()
	-- Check system compatibility
	local triple = system.get_target_triple()
	if not triple then
		error(
			errors.format_error(
				"unsupported_system",
				"System architecture not supported: " .. vim.inspect(system.get_info())
			)
		)
	end

	-- Get cached version info (will throw on error)
	local info = get_cached_version_info()

	-- Log initialization state
	vim.notify(
		string.format(
			"PlayerOne: Initializing binary system\n"
				.. "  - Development build: %s\n"
				.. "  - Current version: %s\n"
				.. "  - Latest version: %s\n"
				.. "  - System: %s",
			info.dev and "Yes" or "No",
			info.current or "Not installed",
			info.latest or "Unknown",
			triple
		),
		vim.log.levels.DEBUG
	)

	return true
end

---Load the appropriate binary
---@return table library The loaded library
---@throws string When binary cannot be loaded
function M.load_binary()
	if loaded_lib then
		return loaded_lib
	end

	M.init()

	local info = get_cached_version_info()

	if not info.current and info.latest then
		vim.notify("PlayerOne: No binary installed. Attempting to download...", vim.log.levels.INFO)
		local ok, err = pcall(download.ensure_binary, info.latest)
		if not ok then
			error(errors.format_error("binary_load_failed", "No binary installed and download failed: " .. err))
		end
		-- Reload version info after download
		version_info_cache.info = nil
		info = get_cached_version_info()
	end

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

	-- Try loading installed binary
	local install_path = version.get_install_path()
	local lib, err = try_load_library(install_path)

	if not lib then
		error(errors.format_error("binary_load_failed", "Failed to load binary at " .. install_path .. ": " .. err))
	end

	loaded_lib = lib
	return lib
end

---Clear the library cache
---@return boolean success Always returns true
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
