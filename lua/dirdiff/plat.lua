
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

M.parse_arg = function(...)
	local others = select(1, ...)
	if not others then
		return {ret = false}
	end
	local mine = select(2, ...)
	if not mine then
		mine = "."
	end
	others = vim.fn.glob(others)
	mine = vim.fn.glob(mine)
	return {ret = true, mine = mine, others = others}
end

M.cmdcomplete = function(A, L, P)
	local cwd = vim.fn.getcwd()
	if #A == 0 then
		return {cwd}
	end
	if cwd == A then
		return
	end
	local paths = vim.fn.glob(A .. "*")
	if not paths or #paths == 0 then
		return
	end
	paths = vim.split(paths, "\n")
	ret = {}
	for _, path in ipairs(paths) do
		if vim.fn. getftype(path) == "dir" then
			table.insert(ret, path)
		end
	end
	return ret
end

return M
