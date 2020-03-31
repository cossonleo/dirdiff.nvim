
local diff = require('dirdiff/diff')
local float_buf = require('dirdiff/float_buf')
local float_win = require('dirdiff/float_win')
local diff_win = require('dirdiff/diff_win')
local M = {}

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

M.diff_dir = function(is_rec, ...)
	local ret = M.parse_arg(...)
	if not ret.ret then
		print("dir err")
		return
	end
	float_buf:diff_dir(ret.mine, ret.others, is_rec)
end

M.show = function()
	float_buf:show()
end
M.close = function()
	diff_win:close_cur_tab()
end
M.close_all = function()
	diff_win:close_all_tab()
end
M.diff_cur = function()
	float_buf:diff_cur_line()
end
M.diff_next = function()
	float_buf:diff_next_line()
end
M.diff_pre = function()
	float_buf:diff_pre_line()
end
M.close_win = function()
	float_buf:close_win()
end

return M
