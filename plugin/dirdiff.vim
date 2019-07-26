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

func s:split_path(str) abort
	let strlen = len(a:str)
	let curlen = strlen
	while curlen > 0
		if a:str[curlen - 1] ==# '/'
			if curlen == len(a:str)
				return [a:str, ""]
			else
				let sstr = []
				call add(sstr, a:str[0: curlen - 1])
				call add(sstr, a:str[curlen: strlen-1])
				return sstr
			endif
		endif
		let curlen = curlen - 1
	endwhile

	return ["", a:str]
endfunc

func s:find_complete(strlist) abort
	if len(a:strlist) != 2
		return []
	endif

	let l:matchdir = trim(a:strlist[0])
	let l:matchstr = trim(a:strlist[1])
	let l:matchslen = len(l:matchstr)
	let l:lslists = split(system("ls -1 " . l:matchdir), "\n")
	let l:matchlist = []
	if l:matchslen > 0
		for lsl in l:lslists
			if len(lsl) < l:matchslen
				continue
			endif

			if lsl[0:l:matchslen - 1] ==# l:matchstr
				let l:complete_item = l:matchdir . lsl
				if isdirectory(l:complete_item)
					call add(l:matchlist, l:complete_item)
				endif
			endif
		endfor
	else
		for lsl in l:lslists
			let l:complete_item = l:matchdir . lsl
			if isdirectory(l:complete_item)
				call add(l:matchlist, l:complete_item)
			endif
		endfor
	endif

	return l:matchlist
endfunc

func s:complete_path(str) abort
	let l:complete_args = s:split_path(a:str)
	return s:find_complete(l:complete_args)
endfunc

func GetCurPwd(A,L,P)
	let l:cwd = getcwd()
	if len(a:A) == 0
		return [l:cwd]
	endif

	if l:cwd ==# trim(a:A)
		return
	endif

	let l:complete_list = s:complete_path(a:A)
	if len(l:complete_list) == 0
		return
	endif
	return l:complete_list
endfunc

command -nargs=+ -complete=customlist,GetCurPwd DDiff call dirdiff#run(v:false, <f-args>)
command -nargs=+ -complete=customlist,GetCurPwd DDiffRec call dirdiff#run(v:true, <f-args>)

command DReshow call dirdiff#reshow()

command DClose call dirdiff#close_cur()

command DCloseAll call dirdiff#close_all()

command DNext call dirdiff#diff_next()

command DPrev call dirdiff#diff_prev()
