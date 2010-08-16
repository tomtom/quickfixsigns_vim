" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-05-08.
" @Last Change: 2010-05-08.
" @Revision:    10

if index(g:quickfixsigns_classes, 'marks') == -1
    finish
endif


if !exists('g:quickfixsigns_class_marks')
    " The definition of signs for marks.
    " :read: let g:quickfixsigns_class_marks = {...} "{{{2
    let g:quickfixsigns_class_marks = {
                \ 'sign': '*quickfixsigns#marks#GetSign',
                \ 'get': 'quickfixsigns#marks#GetList()',
                \ 'id': 'quickfixsigns#marks#GetID',
                \ 'event': g:quickfixsigns_events1,
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


if !exists('g:quickfixsigns#marks#marks')
    " A list of marks that should be displayed as signs. If empty, 
    " disable the display of marks.
    let g:quickfixsigns#marks#marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>''^.', '\zs') "{{{2
endif


for s:i in g:quickfixsigns#marks#marks
	if index(g:quickfixsigns_signs, 'QFS_Mark_'. s:i) == -1
		exec 'sign define QFS_Mark_'. s:i .' text='. s:i .' texthl=Identifier'
	endif
endfor
unlet s:i

function! quickfixsigns#marks#GetList() "{{{3
    let acc = []
    let bn  = bufnr('%')
    let ignore = exists('b:quickfixsigns_ignore_marks') ? b:quickfixsigns_ignore_marks : []
    for mark in g:quickfixsigns#marks#marks
        let pos = getpos("'". mark)
        if pos[1] != 0 && index(ignore, mark) == -1 && (mark =~# '[a-z]' || pos[0] == bn)
            call add(acc, {'bufnr': bn, 'lnum': pos[1], 'col': pos[2], 'text': 'Mark_'. mark})
        endif
    endfor
    return acc
endf


function! quickfixsigns#marks#GetSign(item) "{{{3
    return 'QFS_'. a:item.text
endf


function! quickfixsigns#marks#GetID(item) "{{{3
    let bn = bufnr('%')
    let item = filter(values(g:quickfixsigns_register), 'v:val.bn == bn && get(v:val.item, "text", "") ==# get(a:item, "text", "")')
    if empty(item)
        return g:quickfixsigns_base + a:item.bufnr * 67 + char2nr(get(a:item, "text", "")[-1 : -1]) - 65
    else
        " TLogVAR item
        return item[0].idx
    endif
endf


