" quickfixsigns.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.lithom.net
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-03-19.
" @Last Change: 2010-04-03.
" @Revision:    0.0.26

let s:save_cpo = &cpo
set cpo&vim


function! quickfixsigns#CompleteSelect(ArgLead, CmdLine, CursorPos) "{{{3
    " TLogVAR a:ArgLead, a:CmdLine, a:CursorPos
    let start = len('quickfixsigns_class_')
    let vars = filter(keys(g:), 'v:val =~ ''^quickfixsigns_class_''. a:ArgLead')
    call map(vars, 'strpart(v:val, start)')
    let selected = split(a:CmdLine, '\s\+')
    call filter(vars, 'index(selected, v:val) == -1')
    if a:CmdLine =~ '\<QuickfixsignsSelect\s\+$'
        call insert(vars, join(g:quickfixsigns_classes))
    endif
    return vars
endf


" Display relative line numbers. Remove the signs when the cursor moves.
function! quickfixsigns#RelNumbersOnce() "{{{3
    if !has_key(g:quickfixsigns_lists, 'rel2')
        let s:list = keys(g:quickfixsigns_lists)
        call QuickfixsignsSelect(s:list + ['rel2'])
        call QuickfixsignsUpdate("rel2")
        augroup QuickFixSignsRelNumbersOnce
            autocmd!
            autocmd CursorMoved,CursorMovedI * call QuickfixsignsSelect(s:list) | call QuickfixsignsClear('rel2') | autocmd! QuickFixSignsRelNumbersOnce
        augroup END
    endif
endf



" redraw

let &cpo = s:save_cpo
unlet s:save_cpo
