
local log = require('dirdiff/log')

local path_sep = "/"

if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
	path_sep = "\\"
end

local M = {}

function M.path_concat(left, right)
	local l = left
	local r = right
	if left[#left] == path_sep then
		l = left:sub(1, #left - 1)
	end
	if right[#right] == path_sep then
		r = right:sub(2)
	end
	
	log.debug("path concat ", l .. path_sep .. r)
	return l .. path_sep .. r
end

function M.path_parent(path)
	if not path or #path == "" then
		return
	end

	local temp = vim.split(path, path_sep, true)
	if #temp == 1 then
		return ""
	end
	local parent = table.concat(temp, path_sep, 1, #temp - 1)
	return parent
end

function M.get_sub(dir)
end

return M
