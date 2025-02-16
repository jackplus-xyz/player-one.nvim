local M = {}

local ERROR_MESSAGES = {
	binary_load_failed = "Failed to load player-one binary",
	version_check_failed = "Failed to check version information",
	version_write_failed = "Failed to write version information",
	download_failed = "Failed to download binary",
	checksum_failed = "Binary checksum verification failed",
	unsupported_system = "Unsupported system architecture",
	git_check_failed = "Failed to check git information",
	dir_create_failed = "Failed to create directory",
	file_read_failed = "Failed to read file",
	file_write_failed = "Failed to write file",
	file_delete_failed = "Failed to delete file",
	file_rename_failed = "Failed to rename file",
}

function M.format_error(code, details)
	local msg = ERROR_MESSAGES[code] or "Unknown error"
	if details then
		msg = msg .. ": " .. details
	end
	return msg
end

return M
