-- Binary compilation and loading functionality adapted from:
-- https://github.com/Saghen/blink.cmp/tree/main/lua/blink/cmp/fuzzy

local system = require("player-one.binary.system")
local download = require("player-one.binary.download")

local M = {}

-- Helper: try to load a library from an absolute path
local function load_lib(path, symbol)
	vim.notify("Attempting to load: " .. path .. " with symbol: " .. symbol, vim.log.levels.DEBUG)

	if vim.fn.filereadable(path) ~= 1 then
		return nil, "File not readable: " .. path
	end

	local loader, err = package.loadlib(path, symbol)
	if not loader then
		return nil, err
	end
	return loader(), nil
end

function M.load_binary()
	local ext = system.get_lib_extension()
	local prefix = system.get_lib_prefix()

	-- Build the fully qualified path to the development binary
	local plugin_root = debug.getinfo(1).source:match("@?(.*/)")
	local dev_binary = plugin_root .. "../../../target/release/" .. prefix .. "player_one" .. ext

	vim.notify("Checking dev binary at: " .. dev_binary, vim.log.levels.DEBUG)

	-- Try loading development binary if it exists
	if vim.fn.filereadable(dev_binary) == 1 then
		local lib, err = load_lib(dev_binary, "luaopen_libplayer_one")
		if lib then
			vim.notify("Successfully loaded dev binary", vim.log.levels.DEBUG)
			return lib
		else
			vim.notify("Failed to load dev binary: " .. err, vim.log.levels.WARN)
		end
	end

	-- Fallback: try installed binary from download location
	local bin_dir = download.get_binary_dir()
	local install_binary = bin_dir .. "/" .. prefix .. "player_one" .. ext

	vim.notify("Checking installed binary at: " .. install_binary, vim.log.levels.DEBUG)

	-- Ensure binary is downloaded
	download.ensure_binary()

	if vim.fn.filereadable(install_binary) == 1 then
		local lib, err = load_lib(install_binary, "luaopen_libplayer_one") -- Using consistent symbol name
		if lib then
			vim.notify("Successfully loaded installed binary", vim.log.levels.DEBUG)
			return lib
		else
			vim.notify("Failed to load installed binary: " .. err, vim.log.levels.WARN)
		end
	else
		vim.notify("Installed binary not found at: " .. install_binary, vim.log.levels.WARN)
	end

	error("Failed to load player-one binary")
end

return M.load_binary()
