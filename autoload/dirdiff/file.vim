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

	let l:left_dir = trim(a:arg_list[0])
	if len(a:arg_list) == 1
		let l:right_dir = "."
	else
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

func dirdiff#file#find(is_rec, paths) abort
	call s:reset()
	if ! s:parse_args(a:paths)
		return
	endif

	let s:dirdiff_rec = a:is_rec

	"let l:diff_files = v:lua.dirdiff.diff_dir2old(s:right_dir,s:left_dir)
	call v:lua.dirdiff.diff_dir(s:right_dir,s:left_dir, a:is_rec)
	"call dirdiff#ui#show(s:left_dir, s:right_dir, l:diff_files)
	"echo len(l:diff_files) . " different files"
endfunc
