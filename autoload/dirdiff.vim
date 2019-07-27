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

func dirdiff#cmdcomplete(A,L,P) abort
	return dirdiff#cmdcomplete#get_complete_list(a:A, a:L, a:P)
endfunc

func dirdiff#run(is_rec, ...) abort
	if a:is_rec
		echomsg "Recursive is not implement"
		return
	endif
	call dirdiff#file#find(a:is_rec, a:000)
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

func dirdiff#close_all() abort
	call dirdiff#ui#close_all_tab()
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
	echo len(show_list) . " different files"
endfunc
