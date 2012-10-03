" quickfixsigns.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-03-19.
" @Last Change: 2012-10-02.
" @Revision:    0.0.141


if !exists('g:quickfixsigns#use_relativenumber')
    " VIM 7.3 and later: If non-zero, |quickfixsigns#RelNumbersOnce()| 
    " uses 'relativenumber' instead of signs. This avoids clashes with 
    " other signs and is faster, but it could cause the visible text area 
    " to be temporarily moved to the right.
    let g:quickfixsigns#use_relativenumber = v:version >= 703   "{{{2
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
        if g:quickfixsigns#use_relativenumber
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


function! quickfixsigns#AssertUniqueSigns(bufnr, bufsigns) "{{{3
    let dict = {}
    echohl WarningMsg
    try
        for bsign in a:bufsigns
            let key = printf("%s|%s", bsign.lnum, bsign.name)
            if has_key(dict, key)
                echom ("QuickFixSigns AssertUniqueSigns: duplicate bufnr=". a:bufnr .":") bsign.sign
            else
                let dict[key] = 1
            endif
        endfor
    finally
        echohl NONE
    endtry
endf


function! quickfixsigns#AssertNoObsoleteBuffers(register) "{{{3
    let buffers = {}
    for val in values(a:register)
        if !bufloaded(val.bufnr)
            let buffers[val.bufnr] = 1
        endif
    endfor
    if !empty(buffers)
        echom "QuickFixSigns: Marks for obsolete buffers:" join(sort(keys(buffers)), ', ')
    endif
endf


" :display: quickfixsigns#MoveSigns(n, ?pattern="", ?blockwise=0) "{{{3
function! quickfixsigns#MoveSigns(n, ...) "{{{3
    let pattern = a:0 >= 1 ? a:1 : ''
    let blockwise = a:0 >= 2 ? a:2 : 0
    let reverse = a:n < 0
    let unique_lnums = {}
    let lnum = line('.')
    " TLogVAR a:n, lnum
    for bsign in QuickfixsignsListBufferSigns(bufnr('%'))
        " TLogVAR bsign
        if (reverse && bsign.lnum < lnum) || (!reverse && bsign.lnum > lnum)
            if empty(pattern) || bsign.name =~ pattern
                let unique_lnums[bsign.lnum] = 1
            endif
        endif
    endfor
    let lnums = keys(unique_lnums)
    if empty(lnums)
        let rv = lnum
    else
        let lnums = sort(map(lnums, 'str2nr(v:val)'), 's:NumericSort')
        if blockwise
            " TLogVAR blockwise, len(lnums), lnums
            let lnums1 = []
            let last_lnum1 = -1
            for lnum1 in (reverse ? lnums : reverse(lnums))
                let lnum2 = reverse ? last_lnum1 + 1 : last_lnum1 - 1
                if lnum1 != lnum2
                    call add(lnums1, lnum1)
                endif
                let last_lnum1 = lnum1
            endfor
            let lnums = reverse ? lnums1 : reverse(lnums1)
            " TLogVAR len(lnums), lnums
        endif
        if reverse
            if -a:n > len(lnums)
                let rv = lnums[0]
            else
                let rv = lnums[a:n]
            endif
        else
            if a:n >= len(lnums)
                let rv = lnums[-1]
            else
                let rv = lnums[a:n - 1]
            endif
        endif
    endif
    " TLogVAR rv
    exec rv
endf


function! s:NumericSort(i1, i2)
    let i1 = str2nr(a:i1)
    let i2 = str2nr(a:i2)
    return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endf


" :nodoc:
function! quickfixsigns#CompleteSigns(ArgLead, CmdLine, CursorPos) "{{{3
    let unique_names = {}
    for bsign in QuickfixsignsListBufferSigns(bufnr('%'))
        let unique_names[bsign.name] = 1
    endfor
    return join(sort(keys(unique_names)), "\n")
endf

