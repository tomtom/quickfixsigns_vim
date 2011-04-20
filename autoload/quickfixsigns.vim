" quickfixsigns.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-03-19.
" @Last Change: 2011-04-20.
" @Revision:    0.0.48


if !exists('g:quickfixsigns#use_relativenumber')
    " VIM 7.3 and later: If non-zero, |quickfixsigns#RelNumbersOnce()| 
    " uses 'relativenumber' instead of signs. This avoids clashes with 
    " other signs and is faster, but it could cause the visual text area 
    " to be moved to the right.
    let g:quickfixsigns#use_relativenumber = 1   "{{{2
endif


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
" From vim 7.3 on, this uses the 'relativenumber' option.
function! quickfixsigns#RelNumbersOnce() "{{{3
    if !has_key(g:quickfixsigns_lists, 'rel2')
        if v:version >= 703 && g:quickfixsigns#use_relativenumber
            if !&relativenumber
                augroup QuickFixSignsRelNumbersOnce
                    autocmd!
                    autocmd CursorMoved,CursorMovedI,TabLeave,WinLeave * setlocal norelativenumber
                    if ! &cul
                        autocmd CursorMoved,CursorMovedI,TabLeave,WinLeave * setlocal nocul
                    endif
                    if ! &cuc
                        autocmd CursorMoved,CursorMovedI,TabLeave,WinLeave * setlocal nocuc
                    endif
                    autocmd CursorMoved,CursorMovedI,TabLeave,WinLeave * autocmd! QuickFixSignsRelNumbersOnce
                augroup END
                setlocal relativenumber cul cuc
            endif
        else
            let s:list = keys(g:quickfixsigns_lists)
            call QuickfixsignsSelect(s:list + ['rel2'])
            call QuickfixsignsUpdate("rel2")
            augroup QuickFixSignsRelNumbersOnce
                autocmd!
                autocmd CursorMoved,CursorMovedI,TabLeave,WinLeave * call QuickfixsignsSelect(s:list) | call QuickfixsignsClear('rel2') | autocmd! QuickFixSignsRelNumbersOnce
            augroup END
        endif
    endif
endf


" redraw

