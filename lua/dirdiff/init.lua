
local float_buf = nil
local diff_win = nil
local plat = nil
local M = {}

M.diff_dir = function(is_rec, ...)
	plat = plat or require('dirdiff/plat')
	float_buf = float_buf or require('dirdiff/float_buf')

	local ret = plat.parse_arg(...)
	if not ret.ret then
		print("dir err")
		return
	end
	float_buf:diff_dir(ret.mine, ret.others, is_rec)
end

M.show = function()
	if not float_buf then return end
	float_buf:show()
end
M.close = function()
	diff_win = diff_win or require('dirdiff/diff_win')
	diff_win:close_cur_tab()
end
M.close_all = function()
	diff_win = diff_win or require('dirdiff/diff_win')
	diff_win:close_all_tab()
end
M.diff_cur = function()
	if not float_buf then return end
	float_buf:diff_cur_line()
end
M.diff_next = function()
	if not float_buf then return end
	float_buf:diff_next_line()
end
M.diff_pre = function()
	if not float_buf then return end
	float_buf:diff_pre_line()
end
M.close_win = function()
	if not float_buf then return end
	float_buf:close_win()
end

M.cmdcomplete = function(A, L, P)
	plat = plat or require('dirdiff/plat')
	return plat.cmdcomplete(A,L,P)
end

return M
