" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-05-08.
" @Last Change: 2011-12-25.
" @Revision:    43

if index(g:quickfixsigns_classes, 'marks') == -1
    finish
endif


if !exists('g:quickfixsigns_class_marks')
    " The definition of signs for marks.
    " :read: let g:quickfixsigns_class_marks = {...} "{{{2
    let g:quickfixsigns_class_marks = {
                \ 'sign': '*quickfixsigns#marks#GetSign',
                \ 'get': 'quickfixsigns#marks#GetList(%s)',
                \ 'event': g:quickfixsigns_events,
                \ 'level': 4,
                \ 'timeout': 2
                \ }
endif
if !&lazyredraw && !empty(g:quickfixsigns_class_marks)
    let s:cmn = index(g:quickfixsigns_class_marks.event, 'CursorMoved')
    let s:cmi = index(g:quickfixsigns_class_marks.event, 'CursorMovedI')
    if s:cmn >= 0 || s:cmi >= 0
        echohl Error
        echom "quickfixsigns: Support for CursorMoved(I) events requires 'lazyredraw' to be set"
        echohl NONE
        if s:cmn >= 0
            call remove(g:quickfixsigns_class_marks.event, s:cmn)
        endif
        if s:cmi >= 0
            call remove(g:quickfixsigns_class_marks.event, s:cmi)
        endif
    endif
    unlet s:cmn s:cmi
endif


if !exists('g:quickfixsigns#marks#buffer')
    " A list of buffer-local marks that should be displayed as signs. If 
    " empty, disable the display of marks.
    let g:quickfixsigns#marks#buffer = split('abcdefghijklmnopqrstuvwxyz''.', '\zs') "{{{2
endif


if !exists('g:quickfixsigns#marks#global')
    " A list of global marks that should be displayed as signs. If 
    " empty, disable the display of marks.
    let g:quickfixsigns#marks#global = split('ABCDEFGHIJKLMNOPQRSTUVWXYZ<>^', '\zs') "{{{2
endif


if !exists('g:quickfixsigns#marks#texthl')
    " Highlight group for mark signs.
    let g:quickfixsigns#marks#texthl = 'Identifier'   "{{{2
endif


for s:i in (g:quickfixsigns#marks#buffer + g:quickfixsigns#marks#global)
	if index(g:quickfixsigns_signs, 'QFS_Mark_'. s:i) == -1
		exec 'sign define QFS_Mark_'. s:i .' text='. s:i .' texthl='. g:quickfixsigns#marks#texthl
	endif
endfor
unlet s:i

function! quickfixsigns#marks#GetList(filename) "{{{3
    let acc = []
    let bufnr  = bufnr(a:filename)
    let ignore = exists('b:quickfixsigns_ignore_marks') ? b:quickfixsigns_ignore_marks : []
    " TLogVAR a:filename, bufnr, ignore
    for mark in g:quickfixsigns#marks#buffer
        let acc = s:CheckMark(acc, bufnr, ignore, mark, "buffer")
    endfor
    for mark in g:quickfixsigns#marks#global
        let acc = s:CheckMark(acc, bufnr, ignore, mark, "vim")
    endfor
    return acc
endf


function! s:CheckMark(acc, bufnr, ignore, mark, scope) "{{{3
    let pos = getpos("'". a:mark)
    if pos[1] != 0 && index(a:ignore, a:mark) == -1 && (pos[0] == (a:scope == 'vim' ? a:bufnr : 0))
        let item = {
                    \ 'bufnr': pos[0] == 0 ? a:bufnr : pos[0],
                    \ 'lnum': pos[1],
                    \ 'col': pos[2],
                    \ 'text': 'Mark_'. a:mark,
                    \ 'scope': a:scope
                    \ }
        " TLogVAR a:mark, item.scope
        call add(a:acc, item)
    endif
    return a:acc
endf


function! quickfixsigns#marks#GetSign(item) "{{{3
    return 'QFS_'. a:item.text
endf


