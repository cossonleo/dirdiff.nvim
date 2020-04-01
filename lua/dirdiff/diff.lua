
local M = {}
local L = {}

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

M.is_equal_dir = function(mine_dir, other_dir)
	local mine_files = M.get_files(mine_dir, true)
	local other_files = M.get_files(other_dir, true)
	if #mine_files ~= #other_files then
		return false
	end
	for file, ft in pairs(mine_files) do
		local other_ft = other_files[file]
		if not other_ft then
			return false
		elseif ft ~= other_ft then
			return false
		elseif ft == "dir" then
			if not M.is_equal_dir(mine_dir .. "/" .. file, other_dir .. "/" .. file) then
				return false
			end
		elseif not M.is_equal_file(mine_dir .. "/" .. file, other_dir .. "/" .. file) then
			return false
		end
	end
	return true
end

-- TODO
M.try_convert_encoding_utf8 = function(file)

end

M.diff_dir = function(mine, others, is_rec)
	local mine_files = M.get_files(mine, is_rec)
	local other_files = M.get_files(others, is_rec)
	local diff = {}
	diff_add = {}
	diff_change = {}
	diff_delete = {}
	for file, ft in pairs(mine_files) do
		local other_ft = other_files[file]
		if not other_ft then
			table.insert(diff_add, file)
		elseif ft ~= other_ft then
			table.insert(diff_change, file)
		elseif ft == "dir" then
			if not M.is_equal_dir(mine .. "/" .. file, others .. "/" .. file) then
				table.insert(diff_change, file)
			end
		elseif not M.is_equal_file(mine .. "/" .. file, others .. "/" .. file) then
			table.insert(diff_change, file)
		end
	end
	for file, ft in pairs(other_files) do
		if not mine_files[file] then
			table.insert(diff_delete, file)
		end
	end
	table.sort(diff_add)
	table.sort(diff_change)
	table.sort(diff_delete)
	return {mine_root = mine, others_root = others, diff = {add = diff_add, change = diff_change, delete = diff_delete}}
end

-- local u8_txt = vim.fn.readfile("/home/lks/桌面/u8.txt")
-- local gb_txt = vim.fn.readfile("/home/lks/桌面/gb.txt")
-- 
-- log.debug("u8", u8_txt)
-- log.debug("gb", vim.fn.iconv(gb_txt[1], "gb2312", "utf-8"))
-- log.debug(M.diff_dir("./", "../"))


return M
