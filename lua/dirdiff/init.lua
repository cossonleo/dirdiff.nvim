
local diff = require('dirdiff/diff')
local float_buf = require('dirdiff/float_buf')
local M = {}
local L = {}

M.diff_dir = function(mine, others, is_rec)
	float_buf.update(diff.diff_dir(mine, others, is_rec))
	float_buf.show()
end

M.show = function()
	float_buf.show()
end
M.close = function()
	float_buf.close_diff()
end
M.close_all = function()
	float_buf.close_diff_all()
end
M.diff_cur = function()
	float_buf.diff_cur()
end
M.diff_next = function()
	float_buf.diff_next()
end
M.diff_pre = function()
	float_buf.diff_pre()
end
M.close_win = function()
	float_buf.close_win()
end

return M
