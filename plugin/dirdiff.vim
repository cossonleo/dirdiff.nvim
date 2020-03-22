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

lua dirdiff = require("dirdiff")

let g:path_sep = "/"
let g:ls_split = "\n"

command -nargs=+ -complete=customlist,dirdiff#cmdcomplete Ddiff call dirdiff#run(v:false, <f-args>)
command -nargs=+ -complete=customlist,dirdiff#cmdcomplete DdiffRec call dirdiff#run(v:true, <f-args>)

command Dresume call dirdiff#reshow()

command Dclose call dirdiff#close_cur()

command DcloseAll call dirdiff#close_all()

command Dnext call dirdiff#diff_next()

command Dprev call dirdiff#diff_prev()
