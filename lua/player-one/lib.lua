local M = {}

local function get_lib_extension()
	local system = jit.os
	if system == "Windows" then
		return "dll"
	elseif system == "OSX" then
		return "dylib"
	else -- Linux and other Unix-like systems
		return "so"
	end
end

local function get_abs_path()
	local debug_info = debug.getinfo(1, "S")
	local source = debug_info.source
	local plugin_root = source:sub(2):match("(.*)/lua/.*$") -- Remove '@' and get plugin root
	local lib_ext = get_lib_extension()
	return plugin_root .. "/target/debug/?." .. lib_ext
end

package.cpath = package.cpath .. ";" .. get_abs_path()

M = require("libplayerone")

return M
