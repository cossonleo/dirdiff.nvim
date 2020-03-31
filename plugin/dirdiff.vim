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

hi DirDiffBack guifg=#61afef
hi DirDiffChange guifg=#E5C07B
hi DirDiffAdd guifg=#98C379
hi DirDiffRemove guifg=#E06C75

"he command-completion-customlist
command -nargs=+ -complete=customlist,v:lua.dirdiff.cmdcomplete DDiff call v:lua.dirdiff.diff_dir(v:false, <f-args>)
command -nargs=+ -complete=customlist,v:lua.dirdiff.cmdcomplete DDiffRec call v:lua.dirdiff.diff_dir(v:true, <f-args>)

command DResume call v:lua.dirdiff.show()

command DClose call v:lua.dirdiff.close()

command DCloseAll call v:lua.dirdiff.close_all()

command DNext call v:lua.dirdiff.diff_next()

command DPre call v:lua.dirdiff.diff_pre()
