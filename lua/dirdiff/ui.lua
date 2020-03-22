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

local M = {
	float_win_id = 0
	float_buf_id = 0
	ns_id = 2
	select_offset = 0
	fname_max_width = 20
	tab_buf = {}
	display_files = {}
	left_dir = ""
	right_dir = ""
}

M.show = function(left_dir, right_dir, content)
	M.left_dir = left_dir
	M.right_dir = right_dir
	M.display_files = content
	m.select_offset = 0
	M.set_buf()
	M.create_float_win()
end

M.reshow = function()
	M.create_float_win()
end

M.close_cur_tab = function()
	let l:cur_tab = nvim_get_current_tabpage()

	call s:close_tabpage(cur_tab)
end

M.close_all_tab = function()
	local tabs = keys(M.tab_buf)
	for tab_id in l:tabs
		call s:close_tabpage(str2nr(tab_id))
	endfor
end

func dirdiff#ui#select_next() abort
	if len(s:display_files) == 0
		return
	endif

	let s:select_offset = s:select_offset + 1
	if s:select_offset == len(s:display_files) 
		let s:select_offset = 0
	endif

	call s:select_item()
endfunc

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

func s:init_buf() abort 
	if s:float_buf_id == 0
		let s:float_buf_id = nvim_create_buf(v:false, v:true)
	else
		call nvim_buf_clear_namespace(s:float_buf_id, s:ns_id, 0, -1)
		call nvim_buf_set_lines(s:float_buf_id, 0, -1, v:false, [])
	endif
endfunc

func s:set_buf() abort
	call s:init_buf()

	let l:buf_lines = []
	let l:buf_his = []
	for l:file in s:display_files
		let l:tmp = ""
		let l:hi = ""
		if l:file.flag == 1
			let l:tmp = "  -\t" . l:file.fname
			let l:hi = "DirDiffRemove"
		elseif l:file.flag == 2
			let l:tmp = "  +\t" . l:file.fname
			let l:hi = "DirDiffAdd"
		elseif l:file.flag == 3
			let l:tmp = "  ~\t" . l:file.fname
			let l:hi = "DirDiffChange"
		else
			continue
		endif
		if strwidth(l:tmp) > s:fname_max_width
			let s:fname_max_width = strwidth(l:tmp)
		endif
		call add(l:buf_lines, l:tmp)
		call add(l:buf_his, l:hi)
	endfor

	call nvim_buf_set_lines(s:float_buf_id, 0, -1, v:false, l:buf_lines)
	call s:buf_set_hls(l:buf_his)
endfunc

func s:buf_set_hls(hls) abort
	let l:cur_line = 0
	for l:buf_hi in a:hls
		call nvim_buf_add_highlight(s:float_buf_id, s:ns_id, l:buf_hi, l:cur_line, 0, -1)
		let l:cur_line = l:cur_line + 1
	endfor
endfunc

-- [start_line, endline)
func s:hi_lines(hl, start_line, end_line) abort
	let l:cur_line = a:start_line
	while l:cur_line < a:end_line
		call nvim_buf_add_highlight(s:float_buf_id, s:ns_id, a:hl, l:cur_line, 0, -1)
		let l:cur_line = l:cur_line + 1
	endwhile
endfunc

func s:create_float_win() abort
	let s:float_win_id = nvim_open_win(s:float_buf_id, v:true, s:get_float_win_config())
    call nvim_win_set_option(s:float_win_id, 'winhl', 'Normal:Pmenu,NormalNC:Pmenu')
    call nvim_win_set_option(s:float_win_id, 'foldenable', v:false)
    call nvim_win_set_option(s:float_win_id, 'wrap', v:true)
    call nvim_win_set_option(s:float_win_id, 'statusline', '')
    call nvim_win_set_option(s:float_win_id, 'number', v:true)
    call nvim_win_set_option(s:float_win_id, 'relativenumber', v:false)
    call nvim_win_set_option(s:float_win_id, 'cursorline', v:true)
    call nvim_win_set_option(s:float_win_id, 'signcolumn', "no")
	if s:select_offset > 0
		call nvim_feedkeys((s:select_offset + 1) . "G", "n", v:false)
	endif

	nnoremap <buffer><silent> <cr> :call <SID>cr_select_item()<cr>
	nnoremap <buffer><silent> q :call <SID>close_float_win()<cr>
	nnoremap <buffer><silent> <esc> :call <SID>close_float_win()<cr>
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

func s:close_float_win() abort
	if s:float_win_id == 0
		return
	endif
	call nvim_win_close(s:float_win_id, v:false)
	let s:float_win_id = 0
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


M.create_diff_view = function(fname)
	local file1 = M.left_dir .. path_sep .. fname
	local file2 = M.right_dir .. path_sep .. fname

	api.nvim_command("tabnew")
	local cur_tab = api.nvim_get_current_tabpage()
	M.set_tabpage_diff_var(cur_tab)

	api.nvim_command("vs")

	api.nvim_command("wincmd h")
	api.nvim_command("e " . l:file1)
	api.nvim_command("diffthis")
	local buf1 = api.nvim_get_current_buf()
	local win1 = api.nvim_get_current_win()
	M.set_diff_buf(buf1, win1)

	api.nvim_command("wincmd l")
	api.nvim_command("e " . l:file2)
	api.nvim_command("diffthis")
	local buf2 = api.nvim_get_current_buf()
	local win2 = api.nvim_get_current_win()
	M.set_diff_buf(buf2, win2)

	-- call nvim_command("wincmd h")

	local tb = M.tab_buf[cur_tab]
	if tb then
		M.close_buffs(tb)
	end
	M.add_dd_list(l:cur_tab, [l:buf1, l:buf2])
end

func s:add_dd_list(tab_id, buf_list) abort
	let s:tab_buf[a:tab_id] = a:buf_list
endfunc

M.close_tabpage = function(tab_id)
	if !s:is_diff_tabpage(a:tab_id)
		return
	endif

	--if nvim_tabpage_is_valid(a:tab_id)
	--	execute "tabc! " . a:tab_id
	--endif

	let l:buf_list = []
	try
		let l:buf_list = remove(s:tab_buf, a:tab_id)	
	catch
		return
	endtry

	call s:close_buffs(l:buf_list)

end

func s:close_buffs(buf_list) abort
	for l:buf in a:buf_list
		if nvim_buf_is_valid(l:buf) && s:is_diff_buf(l:buf)
			execute "bd! " . l:buf
		end
	endfor
endfunc

func s:set_tabpage_diff_var(tab_id) abort
	call nvim_tabpage_set_var(a:tab_id, "is_dd_tab", v:true)
endfunc

func s:is_diff_tabpage(tab_id) abort
	try 
		return nvim_tabpage_get_var(a:tab_id, "is_dd_tab")
	catch
		return v:false
	endtry
endfunc

M.is_diff_buf = function(buf_id)
	try
		return api.nvim_buf_get_var(a:buf_id, "is_dd_buf")
	catch
		return v:false
	endtry
end

M.set_diff_buf = function(buf_id, win_id)
	api.nvim_buf_set_var(buf_id, "is_dd_buf", v:true)
	api.nvim_win_set_option(win_id, "signcolumn", "no")
end

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
