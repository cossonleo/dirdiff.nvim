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

let s:tab_buf = {}

let s:path_sep = "/"

func dirdiff#run(is_rec, ...) abort
	if a:0 == 0
		echo "dir not select"
	endif

	call s:parse_args(a:000)
	let g:dirdiff_rec = a:is_rec

	let left_files = s:get_all_files(s:left_dir)
	let right_files = s:get_all_files(s:right_dir)
	let total_files = s:union_files(left_files, right_files)
	let s:diff_files = s:select_diff_files(total_files)
	if len(s:diff_files) == 0 
		echo "no files diff"
		return
	endif

	call dirdiff#show()
endfunc

func dirdiff#diff_next()
	call dirdiff#ui#select_next()
endfunc

func dirdiff#diff_prev()
	call dirdiff#ui#select_prev()
endfunc

func dirdiff#close_cur() abort
	call dirdiff#ui#close_cur_tab()
endfunc

func s:parse_args(arg_list) abort
	if len(a:arg_list) == 0
		echo "dir not select"
	endif

	call s:reset()

	let l:left_dir = ""
	let l:right_dir = ""

	if len(a:arg_list) == 1
		"let s:left_dir = s:trim_tail(trim(getcwd()))
		let l:left_dir = "."
		let l:right_dir = trim(a:arg_list[0])
	else
		let l:left_dir = trim(a:arg_list[0])
		let l:right_dir = trim(a:arg_list[1])
	endif

	let l:left_dir = s:trim_tail(l:left_dir)
	let l:right_dir = s:trim_tail(l:right_dir)

	let l:left_dir = glob(l:left_dir)
	let l:right_dir = glob(l:right_dir)

	if l:left_dir == ""
		echo "left dir is illege"
		return
	endif

	if l:right_dir == ""
		echo "right dir is illege"
		return
	endif

	let s:left_dir = l:left_dir
	let s:right_dir = l:right_dir
endfunc


func dirdiff#reshow()
	call dirdiff#ui#reshow()
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

	let show_list = []
	for key in sort(keys(s:diff_files))
		let item = {}
		let item.fname = key
		let item.flag = s:diff_files[key]
		call add(show_list, item)
	endfor
	call dirdiff#ui#show(s:left_dir, s:right_dir, show_list)
endfunc

func s:reset() abort
	let s:left_dir = ""
	let s:right_dir = ""
	let s:diff_files = {}
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
		if has_key(files_dict, fname) == 0
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
	let prefix_len = len(a:dir) + len(s:path_sep)
	let all_files = []
	for path in paths
		call add(all_files, path[prefix_len:-1])
	endfor
	return all_files
endfunc

" 获取目录下所有的文件
func s:get_all_path(dir) abort
	let ls_cmd = "\ls -1 " . a:dir
	let split_char = "\n"
	let files = split(system(ls_cmd), split_char)
	let select_files = []
	for fname in files 
		let full_path = a:dir . s:path_sep . fname
		if filereadable(full_path)
			call add(select_files, full_path)
		elseif g:dirdiff_rec && isdirectory(full_path)
			let sub_files = s:get_all_path(full_path)
			call extend(select_files, sub_files)
		endif
	endfor
	return select_files
endfunc

" 比较两个e文件是否相同
func s:is_same(fn) abort
	let file1 = s:left_dir .s:path_sep .a:fn
	if filereadable(file1) == 0
		return v:false
	endif

	let file2 = s:right_dir .s:path_sep .a:fn
	if filereadable(file2) == 0
		return v:false
	endif

	let hash_cmd1 = "md5sum " . file1
	let hash_cmd2 = "md5sum " . file2

	let hash1 = split(system(hash_cmd1), " ")[0]
	let hash2 = split(system(hash_cmd2), " ")[0]

	return hash1 ==# hash2
endfunc
