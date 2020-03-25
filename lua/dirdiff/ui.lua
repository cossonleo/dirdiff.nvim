--------------------------------------------------
--    LICENSE: 
--     Author: 
--    Version: 
-- CreateTime: 2020-03-22 18:56:01
-- LastUpdate: 2020-03-22 18:56:01
--       Desc: 
--------------------------------------------------


-- hi DirDiffChange guifg=#E5C07B
-- hi DirDiffAdd guifg=#98C379
-- hi DirDiffRemove guifg=#E06C75
local api = vim.api

local path_sep = "/"

local private = {
	float_win_id = 0,
	float_buf_id = 0,
	select_offset = 0,
	tab_buf = {},
	showed_diff = {},
	diff_info = {},
}

function private:close_cur_tab()
	local cur_tab = api.nvim_get_current_tabpage()
	local bufs = self.tab_buf[cur_tab]
	if not bufs then
		return
	end

	for _, buf in ipairs(bufs) do
		api.nvim_command("bd " .. buf)
	end
end

function private:close_all_tab()
	for _, bufs in pairs(self.tab_buf) do
		for _, buf in ipairs(bufs) do
			api.nvim_command("bd " .. buf)
		end
	end
end

function private:create_diff_view(fname)
	local file1 = self.left_dir .. path_sep .. fname
	local file2 = self.right_dir .. path_sep .. fname

	api.nvim_command("tabnew")
	local cur_tab = api.nvim_get_current_tabpage()

	api.nvim_command("vs")

	api.nvim_command("wincmd h")
	api.nvim_command("e " . file1)
	api.nvim_command("diffthis")
	local buf1 = api.nvim_get_current_buf()
	local win1 = api.nvim_get_current_win()
	api.nvim_win_set_option(win1, "signcolumn", "no")

	api.nvim_command("wincmd l")
	api.nvim_command("e " . file2)
	api.nvim_command("diffthis")
	local buf2 = api.nvim_get_current_buf()
	local win2 = api.nvim_get_current_win()
	api.nvim_win_set_option(win2, "signcolumn", "no")
	self.tab_buf[vur_tab] = {buf1, buf2}
	-- call nvim_command("wincmd h")
end

function create_float_win()
	local self.float_win_id = api.nvim_open_win(self.float_buf_id, v:true, self:get_float_win_config())
    api.nvim_win_set_option(self.float_win_id, 'winhl', 'Normal:Pmenu,NormalNC:Pmenu')
    api.nvim_win_set_option(self.float_win_id, 'foldenable', v:false)
    api.nvim_win_set_option(self.float_win_id, 'wrap', v:true)
    api.nvim_win_set_option(self.float_win_id, 'statusline', '')
    api.nvim_win_set_option(self.float_win_id, 'number', v:true)
    api.nvim_win_set_option(self.float_win_id, 'relativenumber', v:false)
    api.nvim_win_set_option(self.float_win_id, 'cursorline', v:true)
    api.nvim_win_set_option(self.float_win_id, 'signcolumn', "no")
	if self.select_offset > 0 then
		api.nvim_feedkeys((self.select_offset + 1) . "G", "n", v:false)
	end
end

function private:close_float_win()
	if self.float_win_id == 0 then
		return
	end
	api.nvim_win_close(self.float_win_id, false)
	self.float_win_id = 0
end

function private:init_float_buf()
	if self.float_buf_id == 0 then
		self.float_buf_id = api.nvim_create_buf(false, true)
	else
		api.nvim_buf_clear_namespace(self.float_buf_id, self.ns_id, 0, -1)
		api.nvim_buf_set_lines(self.float_buf_id, 0, -1, false, [])
	end

	nnoremap <buffer><silent> <cr> :call <SID>cr_select_item()<cr>
	nnoremap <buffer><silent> q :call <SID>close_float_win()<cr>
	nnoremap <buffer><silent> <esc> :call <SID>close_float_win()<cr>
end

function private:set_float_buf()
	self:init_float_buf()

	local buf_lines = {}
	local buf_his = {}
	-- for l:file in s:display_files
	-- 	let l:tmp = ""
	-- 	let l:hi = ""
	-- 	if l:file.flag == 1
	-- 		let l:tmp = "  -\t" . l:file.fname
	-- 		let l:hi = "DirDiffRemove"
	-- 	elseif l:file.flag == 2
	-- 		let l:tmp = "  +\t" . l:file.fname
	-- 		let l:hi = "DirDiffAdd"
	-- 	elseif l:file.flag == 3
	-- 		let l:tmp = "  ~\t" . l:file.fname
	-- 		let l:hi = "DirDiffChange"
	-- 	else
	-- 		continue
	-- 	endif
	-- 	if strwidth(l:tmp) > s:fname_max_width
	-- 		let s:fname_max_width = strwidth(l:tmp)
	-- 	endif
	-- 	call add(l:buf_lines, l:tmp)
	-- 	call add(l:buf_his, l:hi)
	-- endfor

	api.nvim_buf_set_lines(self.float_buf_id, 0, -1, false, buf_lines)
	self:buf_set_hls(buf_his)
end

function private:buf_set_hls(hls)
	local cur_line = 0
	for _, buf_hi in ipair(hls) do
		api.nvim_buf_add_highlight(self.float_buf_id, self.ns_id, buf_hi, cur_line, 0, -1)
		cur_line = cur_line + 1
	end
end

-- [start_line, endline)
function private:hi_lines(hl, start_line, end_line)
	local cur_line = start_line
	while cur_line < end_line do
		api.nvim_buf_add_highlight(self.float_buf_id, self.ns_id, hl, cur_line, 0, -1)
		cur_line = cur_line + 1
	end
end


-- param {mine_root = "", others_root = "", diff = {}, sub = { f1 = {}, f2 = {}, f1/f3 = {} }}
M.show = function(diff_info)
	private.left_dir = left_dir
	private.right_dir = right_dir
	private.display_files = content
	private.select_offset = 0
	private.set_float_buf()
	private.create_float_win()
end

M.reshow = function()
	M.create_float_win()
end

M.select_next = function()
	if len(s:display_files) == 0
		return
	endif

	let s:select_offset = s:select_offset + 1
	if s:select_offset == len(s:display_files) 
		let s:select_offset = 0
	endif

	call s:select_item()
end

M.select_prev = function()
end

func dirdiff#ui#select_prev() abort
	if len(s:display_files) == 0
		return
	endif

	if s:select_offset == 0
		let s:select_offset = len(s:display_files) - 1
	else
		let s:select_offset = s:select_offset - 1
	endif

	call s:select_item()
endfunc

func s:cr_select_item() abort
	let s:select_offset = getcurpos()[1] - 1
	call s:close_float_win()
	call s:select_item()
endfunc

func s:select_item() abort
	let item = s:display_files[s:select_offset]
	call s:create_diff_view(item.fname)
	echo "current diff: " . (s:select_offset + 1) . "/" . len(s:display_files)
endfunc


M.get_float_win_config = function()
	local columns = api.nvim_get_option('columns')
	local width = columns
	if M.fname_max_width + 10 < columns then
		width = M.fname_max_width + 10
	end
	local col = (columns - width) / 2
	let height = max([len(s:display_files), 10])
	if &lines > 20
		let height = min([height, &lines - 10])
	else
		let height = min([height, &lines])
	endif

	let row = (&lines - height) / 2
	if row > 2
		let row = row - 2
	endif

	let float_win_config = {}
	let float_win_config.relative = "editor"
	let float_win_config.height = height
	let float_win_config.width = width
	let float_win_config.row = row
	let float_win_config.col = col
	return float_win_config
end

func s:add_dd_list(tab_id, buf_list) abort
	let s:tab_buf[a:tab_id] = a:buf_list
endfunc

-- func dirdiff#ui#test_create_float_win() abort
-- 	let s:display_files = []
-- 	let files_str = system("ls -1")
-- 	let l:files = split(files_str, "\n")
-- 
-- 	for fname in files
-- 		if filereadable(fname)
-- 			let fd = {"fname": fname, "flag": 1}
-- 			call add(s:display_files, fd)
-- 		endif
-- 	endfor
-- 
-- 	call s:set_buf()
-- 
-- 	call s:create_float_win()
-- endfunc

-- func dirdiff#ui#test_reshow() abort
-- 	call s:reshow()
-- endfunc

-- func dirdiff#ui#test_get_var()
-- 	try
-- 		call nvim_buf_get_var(1, "is_dirdiff")
-- 	catch
-- 		echo "error"
-- 	finally
-- 		echo "finally"
-- 	endtry
-- endfunc

return M
