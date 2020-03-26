
local M = {}
local L = {}

local log = require('dirdiff/log')

log.set_level(0)

L.getFileName = function(path)
	path:match("/*$")
end

M.get_files = function(dir, is_rec)
	if not dir or #dir == 0 then
		return {}
	end

	local rec = is_rec or false

	local paths = vim.fn.glob(dir .. "/*")
	if not paths or #paths == 0 then
		return {}
	end

	paths = vim.split(paths, "\n")
	local start = #dir + 2
	local files = {}
	for _, path in pairs(paths) do
		local file = path:sub(start)
		local ft = vim.fn.getftype(path)
		if #file > 0 then
			if ft == "file" then
				files[file] = ft
			elseif rec and ft == "dir" then
				files[file] = ft
			end
		end
	end
	log.debug(dir, files)
	return files
end

M.is_equal_file = function(mine_file, other_file)
	local mine_len = vim.fn.getfsize(mine_file)
	-- 只判断文件类型
	if mine_len <= 0 then
		return false
	end
	if mine_len ~= vim.fn.getfsize(other_file) then
		return false
	end

	mine_lines = vim.fn.readfile(mine_file)
	other_lines = vim.fn.readfile(other_file)
	if #mine_lines ~= #other_lines then
		return false
	end

	for index, line in ipairs(mine_lines) do
		local other_line = other_lines[index]
		if #line ~= #other_line then
			return false
		end

		if line ~= other_line then
			return false
		end
	end

	return true
end

M.try_convert_encoding_utf8 = function(file)

end

return M
