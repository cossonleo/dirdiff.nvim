# dirdiff.nvim
Diff two dirs for neovim

## command
:DDiff dir1 {dir2}
> only diff file type's file for two dir
> if dir2 omitted, dir2 setted current workdir(cwd) by default

:DDiffRec dir1 {dir2}
> diff file and sub dir for two dir
> if dir2 omitted, dir2 setted current workdir(cwd) by default

:DResume
> resume diff result float window

:DClose
> close diff mode window of current tab page created by dirdiff

:DCloseAll
> close all diff mode window created by dirdiff

:DNext
> diff next different files

:DPre
> diff pre different files

