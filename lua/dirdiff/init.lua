
local M = {}
local l = {}

local log = require('dirdiff/log')

log.set_level(0)

M.get_files = function(dir)
	local files = vim.fn.glob(dir .. "/*")
	log.debug("dir/* =", vim.split(files, "\n"))
	return files
end

M.diff_file = function(mine_file, other_file)
end

M.diff_dir = function(mine, others)
	local mine_files = M.get_files(mine)
	local others_files = M.get_files(others)
end

local u8_txt = vim.fn.readfile("/home/lks/桌面/u8.txt")
local gb_txt = vim.fn.readfile("/home/lks/桌面/gb.txt")

log.debug("u8", u8_txt)
log.debug("gb", vim.fn.iconv(gb_txt[1], "", "utf-8"))

return M
