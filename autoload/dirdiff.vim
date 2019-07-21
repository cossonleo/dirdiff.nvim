""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2019-07-20 16:07:17
" LastUpdate: 2019-07-20 16:07:17
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists("s:is_load")
	finish
endif
let s:is_load = 1

let s:left_dir = ""
let s:right_dir = ""
let s:diff_files = {}
let s:cur_diff = 0

let s:float_win = 0
let s:float_buf = 0

let s:tab_buf = {}

let s:path_sep = "/"

func dirdiff#run(...) abort
	if a:0 == 0
		echo "dir not select"
	endif

	call s:reset()

	if a:0 == 1
		let s:left_dir = s:trim_tail(trim(getcwd()))
		let s:right_dir = s:trim_tail(trim(a:1))
	else
		let s:left_dir = s:trim_tail(trim(a:1))
		let s:right_dir = s:trim_tail(trim(a:2))
	endif

	if s:left_dir == ""
		echo "left dir is illege"
		call s:reset()
		return
	endif

	if s:right_dir == ""
		echo "right dir is illege"
		call s:reset()
		return
	endif

	let left_files = s:get_all_files(s:left_dir)
	let right_files = s:get_all_files(s:left_dir)
	let total_files = s:union_files(left_files, right_files)
	let s:diff_files = s:select_diff_files(total_files)
	if len(s:diff_files) == 0 
		echo "no files diff"
		return
	endif

	call dirdiff#show()
endfunc

func dirdiff#show() abort
	if s:left_dir == ""
		echo "left dir is not set"
		return
	endif

	if s:right_dir == ""
		echo "right dir is not set"
		return
	endif

	if len(s:diff_files) == 0
		echo "no files diff"
		return
	endif

	call s:create_float_window()
endfunc

func s:reset() abort
	let s:left_dir = ""
	let s:right_dir = ""
	let s:diff_files = {}
	let s:cur_diff = 0
endfunc

" 筛选出不同的文件 "
func s:select_diff_files(all_files) abort
	let diff_files = {}
	for [fname, flag] in items(a:all_files)
		if flag == 3
			if s:is_same(fname)
				continue
			endif
		endif
		
		let diff_files[fname] = flag
	endfor
	return diff_files
endfunc

" key: files
" value: flag: 1: 左边目录拥有， 2： 右边目录拥有， 3： 都拥有  
func s:union_files(left_files, right_files) abort
	let files_dict = {}
	for fname in a:left_files
		let files_dict[fname] = 1
	endfor

	for fname in a:right_files
		if get(files_dict, fname) == 0
			let files_dict[fname] = 2
		else
			let files_dict[fname] = 3
		endif
	endfor
	return files_dict
endfunc

func s:trim_tail(str) abort
	if len(a:str) < 2
		return a:str
	endif

	let last_char = a:str[-1:-1]
	if last_char ==# s:path_sep
		return a:str[0:-2]
	end
	return a:str
endfunc

func s:get_all_files(dir) abort
	let paths = s:get_all_path(a:dir)
	let prefix_len = len(dir) + len(s:path_sep)
	let all_files = []
	for path in paths
		call add(all_files, path[prefix_len:-1])
	endfor
	return all_files
endfunc

" 获取目录下所有的文件
func s:get_all_path(dir) abort
	let ls_cmd = "\ls"
	let split_char = "\n"
	let files = split(system(ls_cmd), split_char)
	let select_files = []
	for fname in files 
		let full_path = a:dir . s:path_sep . fname
		if filereadable(full_path)
			call add(select_files, full_path)
		else
			let sub_files = s:get_all_path(full_path)
			call extend(select_files, sub_files)
		endif
	endfor
	return select_files
endfunc

" 比较两个e文件是否相同
func s:is_same(fn) abort
	let file1 = s:left_dir .s:path_sep .fn
	if filereadable(file1) == 0
		return false
	endif

	let file2 = s:right_dir .s:path_sep .fn
	if filereadable(file2) == 0
		return false
	endif

	let hash_cmd1 = "md5sum " . file1
	let hash_cmd2 = "md5sum " . file2

	let hash1 = split(system(hash_cmd1), " ")[0]
	let hash2 = split(system(hash_cmd2), " ")[0]

	return hash1 ==# hash2
endfunc

" 创建浮动窗口
func s:create_float_window() abort
endfunc

" 关闭浮动窗口
func s:close_float_window() abort
endfunc

func s:create_diff_view(fname) abort 
	let file1 = s:left_dir . s:path_sep . fname
	let file2 = s:right_dir . s:path_sep . fname

	execute "tabnew"
	let new_tab = nvim_get_current_tabpage()
	let old_tab = get(s:tab_buf, new_tab, v:false)
	if old_tab
		for ot in old_tab
			execute "bd " . ot
		endfor
		call remove(s:tab_buf, new_tab)
	endif

	execute "e " . file2
	execute "diffthis"
	let buf1 = nvim_get_current_buf()
	execute "vs " . file1
	execute "diffthis"
	let buf2 = nvim_get_current_buf()

	let buflist = [buf1, buf2] 
	let s:tab_buf[new_tab] = buflist
endfunc

func s:close_cur_tab() abort 
	let cur_tab = nvim_get_current_tabpage()
endfunc

let s:test_buf1 = 0
let s:test_buf2 = 0
func dirdiff#test() abort
	execute "tabnew"
	execute  "e README.md"
	execute "diffthis"
	let s:test_buf1 = nvim_get_current_buf()

	execute "vs LICENSE"
	execute "diffthis"
	execute "diffthis"
	let s:test_buf2 = nvim_get_current_buf()
endfunc

func dirdiff#test_close() abort
	execute "bd " . s:test_buf1
	execute "bd " . s:test_buf2
endfunc
