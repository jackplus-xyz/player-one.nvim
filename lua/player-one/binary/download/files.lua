local system = require("player-one.binary.system")
local errors = require("player-one.binary.errors")
local paths = require("player-one.binary.paths")

local M = {}

function M.ensure_dir(path)
	if vim.fn.isdirectory(path) == 0 then
		local ok, err = pcall(vim.fn.mkdir, path, "p")
		if not ok then
			error(errors.format_error("dir_create_failed", err))
		end
	end
end

function M.download_file(url, output_path)
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
	if not ok or vim.v.shell_error ~= 0 then
		error(errors.format_error("download_failed", string.format("Failed to download %s: %s", url, result)))
	end
end

function M.verify_checksum(file_path, checksum_path)
	local cmd
	if system.get_os() == "macos" then
		cmd = { "shasum", "-a", "256", file_path }
	else
		cmd = { "sha256sum", file_path }
	end

	local ok, output = pcall(vim.fn.system, cmd)
	if not ok or vim.v.shell_error ~= 0 then
		error(errors.format_error("checksum_failed", "Failed to compute checksum"))
	end

	if vim.fn.filereadable(checksum_path) == 0 then
		error(errors.format_error("checksum_failed", "Checksum file not found"))
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

function M.rename_file(old_path, new_path)
	local ok, err = pcall(os.rename, old_path, new_path)
	if not ok then
		error(errors.format_error("file_rename_failed", err))
	end
end

function M.delete_file(path)
	if vim.fn.filereadable(path) == 1 then
		local ok, err = pcall(vim.fn.delete, path)
		if not ok then
			error(errors.format_error("file_delete_failed", err))
		end
	end
end

return M
