" breakpoints.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-11-26.
" @Last Change: 2011-01-27.
" @Revision:    27


if exists('g:quickfixsigns#breakpoints#loaded')
    finish
endif
let g:quickfixsigns#breakpoints#loaded = 1


if index(g:quickfixsigns_classes, 'breakpoints') == -1
    finish
endif


if !exists('g:quickfixsigns#breakpoints#filetypes')
    " :read: let g:quickfixsigns#breakpoints#filetypes = {...}   "{{{2
    let g:quickfixsigns#breakpoints#filetypes = {
                \ 'vim': 'quickfixsigns#breakpoints#Vim'
                \ }
endif


if !exists('g:quickfixsigns_class_breakpoints')
    " :read: let g:quickfixsigns_class_breakpoints = {...}   "{{{2
    let g:quickfixsigns_class_breakpoints = {
                \ 'sign': 'QFS_BREAKPOINT',
                \ 'get': 'quickfixsigns#breakpoints#GetList(%s)',
                \ 'event': g:quickfixsigns_events,
                \ 'test': 'has_key(g:quickfixsigns#breakpoints#filetypes, &ft)',
                \ 'timeout': 5
                \ }
                " \ 'event': ['BufEnter,BufWritePost']
endif


if g:quickfixsigns_class_breakpoints.sign == 'QFS_BREAKPOINT'
    if exists('g:quickfixsigns_icons.breakpoint')
        exec 'sign define QFS_BREAKPOINT text=# texthl=Special icon='. escape(g:quickfixsigns_icons.breakpoint, ' \')
    else
        sign define QFS_BREAKPOINT text=# texthl=Special
    endif
endif


function! quickfixsigns#breakpoints#GetList(filename) "{{{3
    " TLogVAR &filetype
    if has_key(g:quickfixsigns#breakpoints#filetypes, &filetype)
        return call(g:quickfixsigns#breakpoints#filetypes[&filetype], [])
    else
        return []
    endif
endf


function! quickfixsigns#breakpoints#Vim() "{{{3
    redir => bps
    silent breaklist
    redir END
    let acc = []
    for line in split(bps, '\n')
        let ml = matchlist(line, '^\s*\(\d\+\)\s\+\w\+\s\+\(.\{-}\)\s\+\w\+\s\+\(\d\+\)$')
        " TLogVAR line, ml
        if !empty(ml)
            let bufnr = bufnr(ml[2])
            let item = {
                        \ 'bufnr': bufnr,
                        \ 'lnum': ml[3],
                        \ 'text': 'Breakpoint_'. ml[1]
                        \ }
            call add(acc, item)
        endif
    endfor
    return acc
endf

