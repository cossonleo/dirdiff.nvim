
local diff = require('dirdiff/diff')
local M = {}
local L = {}

M.diff_dir = function(mine, others, is_rec)
	local mine_files = diff.get_files(mine, is_rec)
	local other_files = diff.get_files(others, is_rec)
	local diff = {}
	diff["add"] = {}
	diff["change"] = {}
	diff["delete"] = {}
	for file, ft in pairs(mine_files) do
		local other_ft = other_files[file]
		if not other_ft then
			table.insert(diff["add"], file)
		elseif ft ~= other_ft then
			table.insert(diff["change"], file)
		elseif ft == "dir" then
		elseif not diff.is_equal_file(mine .. "/" .. file, others .. "/" .. file) then
			table.insert(diff["change"], file)
		end
	end
	for file, ft in pairs(other_files) do
		if not mine_files[file] then
			table.insert(diff["delete"], file)
		end
	end
	return diff
end

M.diff_dir2old = function(mine, others, is_rec)
	local diffs = M.diff_dir(mine, others, is_rec)
	local old_diffs = {}
	for _, f in ipairs(diffs["delete"]) do
		table.insert(old_diffs, {fname = f, flag = 1})
	end
	for _, f in ipairs(diffs["add"]) do
		table.insert(old_diffs, {fname = f, flag = 2})
	end
	for _, f in ipairs(diffs["change"]) do
		table.insert(old_diffs, {fname = f, flag = 3})
	end
	return old_diffs
end

-- local u8_txt = vim.fn.readfile("/home/lks/桌面/u8.txt")
-- local gb_txt = vim.fn.readfile("/home/lks/桌面/gb.txt")
-- 
-- log.debug("u8", u8_txt)
-- log.debug("gb", vim.fn.iconv(gb_txt[1], "gb2312", "utf-8"))
-- log.debug(M.diff_dir("./", "../"))

return M
