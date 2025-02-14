local M = {}

function M.get_os()
	local os = jit.os:lower()
	if os == "osx" or os == "mac" then
		return "macos"
	end
	return os
end

function M.get_arch()
	local arch = jit.arch:lower()
	if arch == "x64" then
		return "x86_64"
	elseif arch == "arm64" then
		return "aarch64"
	end
	return arch
end

function M.get_lib_extension()
	local os = M.get_os()
	if os == "macos" then
		return ".dylib"
	elseif os == "windows" then
		return ".dll"
	end
	return ".so"
end

function M.get_lib_prefix()
	return M.get_os() == "windows" and "" or "lib"
end

function M.get_target_triple()
	local os = M.get_os()
	local arch = M.get_arch()

	if os == "macos" then
		return arch .. "-apple-darwin"
	elseif os == "windows" then
		return arch .. "-pc-windows-msvc"
	else
		return arch .. "-unknown-linux-gnu"
	end
end

return M
