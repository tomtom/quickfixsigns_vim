" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @git:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2012-10-02.
" @Revision:    516

if exists('g:quickfixsigns#longlines#loaded')
    finish
endif
let g:quickfixsigns#longlines#loaded = 1
scriptencoding utf-8


if index(g:quickfixsigns_classes, 'longlines') == -1
    finish
endif


if !exists('g:quickfixsigns_class_longlines')
    " Mark long lines (see |g:quickfixsigns#longlines#width_expr|) with 
    " a sign.
    "
    " Users have to enable this sign class by adding 'longlines' to 
    " |g:quickfixsigns_classes|.
    let g:quickfixsigns_class_longlines = {'sign': 'QFS_LONGLINES', 'get': 'quickfixsigns#longlines#GetList(%s)', 'event': ['BufRead', 'BufWritePost']}   "{{{2
endif


if !exists('g:quickfixsigns#longlines#width')
    let g:quickfixsigns#longlines#width_expr = '&tw'   "{{{2
endif


if index(g:quickfixsigns_signs, 'QFS_LONGLINES') == -1
    sign define QFS_LONGLINES text=$ texthl=WarningMsg
endif


function! quickfixsigns#longlines#GetList(filename) "{{{3
    if &tw == 0
        return []
    endif
    let bufnr = bufnr('%')
    let signs = []
    if bufnr != bufnr(a:filename)
        if g:quickfixsigns_debug
            throw "QuickFixSigns DEBUG: bufnr mismatch:" a:filename bufnr bufnr(a:filename)
        endif
    else
        let width = eval(g:quickfixsigns#longlines#width_expr)
        if width > 0
            let pos = getpos('.')
            try
                exec 'silent g/\%>'. width .'v./'
                            \ 'call add(signs, {"bufnr": bufnr, "lnum": line("."), "text": "Long line"})'
            finally
                call setpos('.', pos)
            endtry
        endif
    endif
    " TLogVAR signs
    return signs
endf

