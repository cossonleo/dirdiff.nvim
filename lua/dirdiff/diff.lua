local plat = require('dirdiff/plat')

local function get_files(dir, is_rec)
	if not dir or #dir == 0 then
		return {}
	end

	local rec = is_rec or false

	local files = vim.fn.readdir(dir)
	if not files or #files == 0 then
		return {}
	end
	local result = {}
	for _, file in pairs(files) do
		local ft = vim.fn.getftype(plat.path_concat(dir, file))
		if ft == "file" then
			result[file] = ft
		elseif rec and ft == "dir" then
			result[file] = ft
		end
	end
	return result
end

local function is_equal_file(mine_file, other_file)
	local mine_len = vim.fn.getfsize(mine_file)
	-- 只判断文件类型
	if mine_len <= 0 then
		return false
	end
	if mine_len ~= vim.fn.getfsize(other_file) then
		return false
	end

	local mine_lines = vim.fn.readfile(mine_file)
	local other_lines = vim.fn.readfile(other_file)
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

local function is_equal_dir(mine_dir, other_dir)
	local mine_files = get_files(mine_dir, true)
	local other_files = get_files(other_dir, true)
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
			if not is_equal_dir(plat.path_concat(mine_dir, file), plat.path_concat(other_dir, file)) then
				return false
			end
		elseif not is_equal_file(plat.path_concat(mine_dir, file), plat.path_concat(other_dir, file)) then
			return false
		end
	end
	return true
end

local M = {}
M.diff_dir = function(mine, others, is_rec)
	local mine_files = get_files(mine, is_rec)
	local other_files = get_files(others, is_rec)
	local diff_add = {}
	local diff_change = {}
	local diff_delete = {}
	for file, ft in pairs(mine_files) do
		local other_ft = other_files[file]
		if not other_ft then
			table.insert(diff_add, file)
		elseif ft ~= other_ft then
			table.insert(diff_change, file)
		elseif ft == "dir" then
			if not is_equal_dir(plat.path_concat(mine, file), plat.path_concat(others, file)) then
				table.insert(diff_change, file)
			end
		elseif not is_equal_file(plat.path_concat(mine, file), plat.path_concat(others, file)) then
			table.insert(diff_change, file)
		end
	end
	for file, _ in pairs(other_files) do
		if not mine_files[file] then
			table.insert(diff_delete, file)
		end
	end
	table.sort(diff_add)
	table.sort(diff_change)
	table.sort(diff_delete)
	return {mine_root = mine, others_root = others, diff = {add = diff_add, change = diff_change, delete = diff_delete}}
end

return M
