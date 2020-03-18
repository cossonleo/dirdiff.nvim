
local M = {}
local L = {}

local log = require('dirdiff/log')

log.set_level(0)

L.getFileName = function(path)
	path:match("/*$")
end

M.get_files = function(dir)
	if not dir or #dir == 0 then
		return {}
	end

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
		if #file > 0 and (ft == "dir" or ft == "file") then
			files[file] = ft
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

M.diff_dir = function(mine, others)
	local mine_files = M.get_files(mine)
	local other_files = M.get_files(others)
	local diff = {}
	diff["add"] = {}
	diff["change"] = {}
	diff["delete"] = {}
	for file, ft in pairs(mine_files) do
		local other_ft = other_files[file]
		if not other_ft then
			table.insert(diff["add"], file)
		end
		if ft ~= other_ft then
			table.insert(diff["change"], file)
		end

		if ft == "dir" then
		elseif not M.is_equal_file(mine .. "/" .. file, others .. "/" .. file) then
				table.insert(diff["change"], file)
			end
		end
	end
	for file, ft in pairs(other_files) do
		if not mine_files[file] then
			table.insert(diff["delete"], file)
		end
	end
	return diff
end

local u8_txt = vim.fn.readfile("/home/lks/桌面/u8.txt")
local gb_txt = vim.fn.readfile("/home/lks/桌面/gb.txt")

log.debug("u8", u8_txt)
log.debug("gb", vim.fn.iconv(gb_txt[1], "", "utf-8"))

return M
