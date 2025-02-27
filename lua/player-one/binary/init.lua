-- Binary compilation and loading functionality adapted from:
-- https://github.com/Saghen/blink.cmp/tree/main/lua/blink/cmp/fuzzy

local Download = require("player-one.binary.download")
local Errors = require("player-one.binary.errors")
local State = require("player-one.state")
local System = require("player-one.binary.system")
local Version = require("player-one.binary.version")

local M = {}

-- Helper: try to load a library from an absolute path
local function load_lib(path, symbol)
	local loader, err = package.loadlib(path, symbol)
	if not loader then
		return nil, err
	end
	return loader(), nil
end

---Get version info with caching
---@return PlayerOne.VersionInfo
---@throws string When version info cannot be retrieved
local function get_cached_version_info()
	if not is_cache_valid() then
		local ok, info_or_err = pcall(Version.get_info)
		if not ok then
			error(Errors.format_error("version_check_failed", info_or_err))
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
	local triple = System.get_target_triple()
	if not triple then
		error(
			Errors.format_error(
				"unsupported_system",
				"System architecture not supported: " .. vim.inspect(System.get_info())
			)
		)
	end

	-- Get cached version info (will throw on error)
	local info = get_cached_version_info()

	-- Log initialization state
	if State.debug then
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
	end

	return true
end

---Load the appropriate binary
---@return table library The loaded library
---@throws string When binary cannot be loaded
function M.load_binary()
	local ext = system.get_lib_extension()
	local prefix = system.get_lib_prefix()

	-- Build the fully qualified path to the development binary
	local plugin_root = debug.getinfo(1).source:match("@?(.*/)")
	local dev_binary = plugin_root .. "../../../target/release/" .. prefix .. "player_one" .. ext

	-- Try loading development binary if it exists.
	if vim.fn.filereadable(dev_binary) == 1 then
		local lib, err = load_lib(dev_binary, "luaopen_libplayer_one")
		if lib then
			return lib
		else
			vim.notify("Failed to load dev binary: " .. err, vim.log.levels.WARN)
		end
	end

	-- Fallback: try installed binary from download location.
	local bin_dir = download.get_binary_dir()
	local install_binary = bin_dir .. "/" .. prefix .. "player_one" .. ext

	if vim.fn.filereadable(install_binary) == 1 then
		local lib, err = load_lib(install_binary, "luaopen_libplayerone")
		if lib then
			return lib
		else
			vim.notify("Failed to load installed binary: " .. err, vim.log.levels.WARN)
		end
	end

	error("Failed to load player-one binary")
end

return M.load_binary()
