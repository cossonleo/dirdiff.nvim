""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2019-07-20 16:07:25
" LastUpdate: 2019-07-20 16:07:25
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists("s:is_load")
	finish
endif
let s:is_load = 1

let g:path_sep = "/"

command -nargs=+ -complete=dir DDiff call dirdiff#run(v:false, <f-args>)
command -nargs=+ -complete=dir DDiffRec call dirdiff#run(v:true, <f-args>)

command DReshow call dirdiff#reshow()

command DClose call dirdiff#close_cur()

command DNext call dirdiff#diff_next()

command DPrev call dirdiff#diff_prev()
