local system = require("player-one.binary.system")
local errors = require("player-one.binary.errors")

local M = {}

function M.get_paths()
	local source_path = debug.getinfo(1).source:match("@?(.*/)")
	local root_dir = vim.fn.fnamemodify(source_path .. "../../../../", ":p")
	local bin_dir = root_dir .. "bin"
	local prefix = system.get_lib_prefix()
	local ext = system.get_lib_extension()

	return {
		root = root_dir,
		bin = bin_dir,
		lib = bin_dir .. "/" .. prefix .. "player_one" .. ext,
		temp = bin_dir .. "/" .. prefix .. "player_one" .. ext .. ".tmp",
		checksum = bin_dir .. "/" .. prefix .. "player_one" .. ext .. ".sha256",
		version = bin_dir .. "/version",
	}
end

-- File operations with better error handling
function M.ensure_dir(path)
	if vim.fn.isdirectory(path) == 0 then
		local ok, err = pcall(vim.fn.mkdir, path, "p")
		if not ok then
			error(errors.format_error("dir_create_failed", err))
		end
	end
end

function M.read_file(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end

	local ok, content = pcall(vim.fn.readfile, path)
	if not ok then
		error(errors.format_error("file_read_failed", path))
	end

	return content
end

function M.write_file(path, content)
	local ok, err = pcall(vim.fn.writefile, content, path)
	if not ok then
		error(errors.format_error("file_write_failed", err))
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

function M.rename_file(old_path, new_path)
	local ok, err = pcall(os.rename, old_path, new_path)
	if not ok then
		error(errors.format_error("file_rename_failed", err))
	end
end

-- Checksum verification
function M.get_checksum(file_path)
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

	return vim.split(output, "%s+")[1]
end

function M.verify_checksum(file_path, checksum_path)
	local checksum_content = M.read_file(checksum_path)
	if not checksum_content or not checksum_content[1] then
		error(errors.format_error("checksum_failed", "Invalid checksum file"))
	end

	local expected = vim.split(checksum_content[1], "%s+")[1]
	local actual = M.get_checksum(file_path)

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

return M
