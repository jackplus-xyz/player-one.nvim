local system = require("player-one.binary.system")
local download = require("player-one.binary.download")

local M = {}

function M.load_binary()
	local ext = system.get_lib_extension()
	local prefix = system.get_lib_prefix()
	local plugin_root = debug.getinfo(1).source:match("@?(.*/)")
	local dev_path = plugin_root .. "../../../target/release/playerone/" .. prefix .. "playerone" .. ext

	-- Try loading from development build first
	package.cpath = package.cpath .. ";" .. dev_path

	local ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	-- Try loading from installed location
	local bin_dir = download.get_binary_dir()
	local install_path = bin_dir .. "/playerone/" .. prefix .. "playerone" .. ext
	package.cpath = package.cpath .. ";" .. install_path

	ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	-- Download and try again
	download.ensure_binary()

	-- Final attempt to load after download
	ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	error("Failed to load playerone binary")
end

-- Return the loaded binary or throw an error
return M.load_binary()
