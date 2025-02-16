local system = require("player-one.binary.system")
local errors = require("player-one.binary.errors")

local M = {}

function M.ensure_dir(path)
	if not path then
		error(errors.format_error("dir_create_failed", "No path provided"))
	end

	if vim.fn.isdirectory(path) == 0 then
		local ok, err = pcall(vim.fn.mkdir, path, "p")
		if not ok then
			error(
				errors.format_error("dir_create_failed", string.format("Failed to create directory %s: %s", path, err))
			)
		end
	end
end

-- Better error handling for downloads
function M.download_file(url, output_path)
	if not url or not output_path then
		error(errors.format_error("download_failed", "Missing URL or output path"))
	end

	local cmd = {
		"curl",
		"--fail",
		"--location",
		"--silent",
		"--show-error",
		url,
		"--output",
		output_path,
	}

	local ok, result = pcall(vim.fn.system, cmd)
	if not ok then
		error(errors.format_error("download_failed", string.format("System error downloading %s: %s", url, result)))
	end

	if vim.v.shell_error ~= 0 then
		error(errors.format_error("download_failed", string.format("Curl failed for %s: %s", url, result)))
	end
end

-- Improved checksum verification
function M.verify_checksum(file_path, checksum_path)
	if not file_path or not checksum_path then
		error(errors.format_error("checksum_failed", "Missing file or checksum path"))
	end

	if vim.fn.filereadable(file_path) == 0 then
		error(errors.format_error("checksum_failed", string.format("Binary file not readable: %s", file_path)))
	end

	if vim.fn.filereadable(checksum_path) == 0 then
		error(errors.format_error("checksum_failed", string.format("Checksum file not readable: %s", checksum_path)))
	end

	local cmd = system.get_os() == "macos" and { "shasum", "-a", "256", file_path } or { "sha256sum", file_path }

	local ok, output = pcall(vim.fn.system, cmd)
	if not ok then
		error(errors.format_error("checksum_failed", string.format("Failed to compute checksum: %s", output)))
	end

	if vim.v.shell_error ~= 0 then
		error(errors.format_error("checksum_failed", string.format("Checksum command failed: %s", output)))
	end

	local actual = vim.split(output, "%s+")[1]
	local expected = vim.split(vim.fn.readfile(checksum_path)[1], "%s+")[1]

	if actual ~= expected then
		error(
			errors.format_error(
				"checksum_failed",
				string.format("Checksum mismatch\nExpected: %s\nActual: %s", expected, actual)
			)
		)
	end

	return true
end

-- Better file renaming
function M.rename_file(old_path, new_path)
	if not old_path or not new_path then
		error(errors.format_error("file_rename_failed", "Missing source or destination path"))
	end

	if vim.fn.filereadable(old_path) == 0 then
		error(errors.format_error("file_rename_failed", string.format("Source file not readable: %s", old_path)))
	end

	local ok, err = pcall(os.rename, old_path, new_path)
	if not ok then
		error(
			errors.format_error(
				"file_rename_failed",
				string.format("Failed to rename %s to %s: %s", old_path, new_path, err)
			)
		)
	end
end

-- Improved file deletion
function M.delete_file(path)
	if not path then
		error(errors.format_error("file_delete_failed", "No path provided"))
	end

	if vim.fn.filereadable(path) == 1 then
		local ok, err = pcall(vim.fn.delete, path)
		if not ok then
			error(errors.format_error("file_delete_failed", string.format("Failed to delete %s: %s", path, err)))
		end
	end
end

return M
