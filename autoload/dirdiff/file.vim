""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2019-07-27 11:09:20
" LastUpdate: 2019-07-27 11:09:20
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists("s:is_load")
	finish
endif
let s:is_load = 1

let s:left_dir = ""
let s:right_dir = ""
let s:dirdiff_rec = v:false

func s:reset() abort
	let s:left_dir = ""
	let s:right_dir = ""
	let s:dirdiff_rec = v:false
endfunc

func s:parse_args(arg_list) abort
	if len(a:arg_list) == 0
		echo "no dirs compare"
		return v:false
	endif

	if len(a:arg_list) == 1
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
		return v:false
	endif

	if l:right_dir == ""
		echo "right dir is illege"
		return v:false
	endif

	let s:left_dir = l:left_dir
	let s:right_dir = l:right_dir
	return v:true
endfunc

" 筛选出不同的文件 "
func s:select_and_sort(all_files) abort
	let l:diff_files = []
	let l:add_files = []
	let l:delete_files = []
	let l:change_files = []
	for l:fname in sort(keys(a:all_files))
		let l:flag = a:all_files[l:fname]
		let l:item = {"fname": l:fname, "flag": l:flag}

		if l:flag == 1
			call add(l:add_files, l:item)
		elseif l:flag == 2
			call add(l:delete_files, l:item)
		elseif l:flag == 3
			if s:is_same(l:fname)
				continue
			endif
			call add(l:change_files, l:item)
		endif
	endfor
	call extend(l:diff_files, l:add_files)
	call extend(l:diff_files, l:delete_files)
	call extend(l:diff_files, l:change_files)
	return l:diff_files
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
	if last_char ==# g:path_sep
		return a:str[0:-2]
	end
	return a:str
endfunc

func s:get_all_files(dir) abort
	let l:ls_cmd = "\ls -1 " . a:dir
	let l:files = split(system(l:ls_cmd), g:ls_split)
	let l:select_files = []
	let l:select_dirs = []
	for l:fname in l:files 
		let l:full_path = a:dir . g:path_sep . l:fname
		if filereadable(l:full_path)
			call add(l:select_files, l:fname)
		elseif isdirectory(l:full_path)
			call add(l:select_dirs, l:fname)
		endif
	endfor
	return [l:select_files, l:select_dirs]
endfunc

"func s:get_all_files(dir) abort
"	let l:paths = s:get_all_path(a:dir)
"	let prefix_len = len(a:dir) + len(g:path_sep)
"	let all_files = []
"	for l:path in l:paths[0]
"		call add(all_files, l:path[prefix_len:-1])
"	endfor
"	for l:path in l:paths[1]
"		call add(all_files, l:path[prefix_len:-1])
"	endfor
"	return all_files
"endfunc
"
"" 获取目录下所有的文件
"func s:get_all_path(dir) abort
"	let l:ls_cmd = "\ls -1 " . a:dir
"	let files = split(system(l:ls_cmd), g:ls_split)
"	let l:select_files = []
"	let l:select_dirs = []
"	for fname in files 
"		let full_path = a:dir . g:path_sep . fname
"		if filereadable(full_path)
"			call add(l:select_files, full_path)
"		elseif isdirectory(full_path)
"			"let sub_files = s:get_all_path(full_path)
"			"call extend(l:select_files, sub_files)
"			call add(l:select_dirs, fname)
"		endif
"	endfor
"	return [l:select_files, l:select_dirs]
"endfunc

" 比较两个e文件是否相同
func s:is_same(fn) abort
	let file1 = s:left_dir .g:path_sep .a:fn
	if filereadable(file1) == 0
		return v:false
	endif

	let file2 = s:right_dir .g:path_sep .a:fn
	if filereadable(file2) == 0
		return v:false
	endif

	let hash_cmd1 = "md5sum " . file1
	let hash_cmd2 = "md5sum " . file2

	let hash1 = split(system(hash_cmd1), " ")[0]
	let hash2 = split(system(hash_cmd2), " ")[0]

	return hash1 ==# hash2
endfunc

func dirdiff#file#find(is_rec, paths) abort
	call s:reset()
	if ! s:parse_args(a:paths)
		return
	endif

	let s:dirdiff_rec = a:is_rec

	let [l:left_sub_files,l:left_sub_dirs] = s:get_all_files(s:left_dir)
	let [l:right_sub_files, l:right_sub_dirs] = s:get_all_files(s:right_dir)
	let l:total_files = s:union_files(l:left_sub_files, l:right_sub_files)
	let l:diff_files = s:select_and_sort(l:total_files)
	if len(l:diff_files) == 0 
		echo "no file different"
		return []
	endif
	call dirdiff#ui#show(s:left_dir, s:right_dir, l:diff_files)
	echo len(l:diff_files) . " different files"
endfunc
