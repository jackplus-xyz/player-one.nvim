-- Binary compilation and loading functionality adapted from:
-- https://github.com/Saghen/blink.cmp/tree/main/lua/blink/cmp/fuzzy

local system = require("player-one.binary.system")
local download = require("player-one.binary.download")

local M = {}

function M.load_binary()
	local ext = system.get_lib_extension()
	local prefix = system.get_lib_prefix()
	local plugin_root = debug.getinfo(1).source:match("@?(.*/)")
	local dev_path = plugin_root .. "../../../target/release/" .. prefix .. "player_one" .. ext

	-- Try loading from development build first
	local original_cpath = package.cpath
	package.cpath = dev_path .. ";" .. original_cpath

	local ok, lib = pcall(require, "libplayer_one")
	package.cpath = original_cpath -- restore immediately after loading

	if ok then
		return lib
	end

	-- Try loading from installed location
	local bin_dir = download.get_binary_dir()
	local install_path = bin_dir .. "/" .. prefix .. "player_one" .. ext
	package.cpath = package.cpath .. ";" .. install_path

	ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	-- Download and try again
	download.ensure_binary()

	ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	error("Failed to load playerone binary")
end

-- Return the loaded binary or throw an error
return M.load_binary()
