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
	"if a:is_rec
	"	echomsg "Recursive is not implement"
	"	return
	"endif
	call dirdiff#file#find(a:is_rec, a:000)
endfunc

