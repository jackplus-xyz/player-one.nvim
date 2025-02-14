local system = require("player-one.binary.system")
local download = require("player-one.binary.download")

local M = {}

function M.load_binary()
	local ext = system.get_lib_extension()
	local prefix = system.get_lib_prefix()

	-- Try loading from development build
	package.cpath = package.cpath
		.. ";"
		.. debug.getinfo(1).source:match("@?(.*/)")
		.. "../../../target/release/"
		.. prefix
		.. "playerone"
		.. ext

	local ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	-- Try loading from installed location
	local bin_dir = download.get_binary_dir()
	package.cpath = package.cpath .. ";" .. bin_dir .. "/" .. prefix .. "playerone" .. ext

	ok, lib = pcall(require, "libplayerone")
	if ok then
		return lib
	end

	-- Download and try again
	download.ensure_binary()

	return require("libplayerone")
end

return M.load_binary()
