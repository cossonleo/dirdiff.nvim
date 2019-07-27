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
let g:ls_split = "\n"

command -nargs=+ -complete=customlist,dirdiff#cmdcomplete DDiff call dirdiff#run(v:false, <f-args>)
command -nargs=+ -complete=customlist,dirdiff#cmdcomplete DDiffRec call dirdiff#run(v:true, <f-args>)

command DReshow call dirdiff#reshow()

command DClose call dirdiff#close_cur()

command DCloseAll call dirdiff#close_all()

command DNext call dirdiff#diff_next()

command DPrev call dirdiff#diff_prev()
