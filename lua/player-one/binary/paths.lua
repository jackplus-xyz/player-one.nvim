local M = {}

function M.get_plugin_root()
	local str = debug.getinfo(1).source
	return str:sub(2):gsub("/lua/player%-one/binary/paths.lua$", "")
end

function M.get_release_dir()
	return M.get_plugin_root() .. "/target/release"
end

function M.get_binary_name()
	local prefix = require("player-one.binary.system").get_lib_prefix()
	local ext = require("player-one.binary.system").get_lib_extension()
	return prefix .. "player_one" .. ext
end

function M.get_binary_path()
	return M.get_release_dir() .. "/" .. M.get_binary_name()
end

function M.get_version_path()
	return M.get_release_dir() .. "/version"
end

function M.get_checksum_path()
	return M.get_binary_path() .. ".sha256"
end

function M.get_temp_path()
	return M.get_binary_path() .. ".tmp"
end

return M
