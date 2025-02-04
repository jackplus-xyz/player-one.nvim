-- @https://github.com/Saghen/blink.cmp/blob/85d0ca07184d783f6646d19c1af2c4ba970d98b2/lua/blink/cmp/fuzzy/rust.lua#L4)
local function get_lib_extension()
	local os = jit.os:lower()
	if os == "mac" or os == "osx" then
		return ".dylib"
	end
	if os == "windows" then
		return ".dll"
	end
	return ".so"
end

-- search for the lib in the /target/release directory with and without the lib prefix
-- since MSVC doesn't include the prefix
package.cpath = package.cpath
	.. ";"
	.. debug.getinfo(1).source:match("@?(.*/)")
	.. "../../target/release/lib?"
	.. get_lib_extension()
	.. ";"
	.. debug.getinfo(1).source:match("@?(.*/)")
	.. "../../target/release/?"
	.. get_lib_extension()

return require("libplayerone")
