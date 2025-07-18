" Mark quickfix & location list items with signs
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-14.
" @Last Change: 2017-10-12.
" @Revision:    1517
" GetLatestVimScripts: 2584 1 :AutoInstall: quickfixsigns.vim

if &cp || exists("g:loaded_quickfixsigns") || !has('signs')
    finish
endif
let g:loaded_quickfixsigns = 106
scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


" :display: :QuickfixsignsSet [SIGN ...]
" Reset the signs in the current buffer.
command! -bar -nargs=* QuickfixsignsSet call QuickfixsignsSet('', split(<q-args>, '\s\+'))

" Disable quickfixsign.
command! -bar QuickfixsignsDisable call s:ClearSigns(keys(s:quickfixsigns_register), 1) | call QuickfixsignsSelect([]) | let s:clists = {}

" Enable quickfixsign.
command! -bar QuickfixsignsEnable call QuickfixsignsSelect(g:quickfixsigns_classes) | call QuickfixsignsSet('')

" Toggle quickfixsign.
command! -bar QuickfixsignsToggle call QuickfixsignsToggle()

" Select the sign classes that should be displayed and reset the signs 
" in the current buffer.
command! -bar -nargs=+ -complete=customlist,quickfixsigns#CompleteSelect QuickfixsignsSelect call QuickfixsignsSelect([<f-args>]) | call QuickfixsignsUpdate()

" Print the text for the signs at the current line.
command! -bar Quickfixsignsecho call QuickfixsignsEcho(bufnr("%"), line("."))


if !exists('g:quickfixsigns_debug')
    let g:quickfixsigns_debug = 0
endif


if !exists('g:quickfixsigns_echo_map')
    " Call |:Quickfixsignsecho|. Print the text for the signs at the 
    " current line.
    let g:quickfixsigns_echo_map = '<Leader>qq'   "{{{2
endif
if !empty(g:quickfixsigns_echo_map)
    exec 'nnoremap' g:quickfixsigns_echo_map ':Quickfixsignsecho<cr>'
endif


if !exists('g:quickfixsigns_classes')
    " A list of sign classes that should be displayed.
    " Can be one of:
    "
    "   rel     ... relative line numbers
    "   cursor  ... current line
    "   qfl     ... |quickfix| list
    "   loc     ... |location| list
    "   vcsdiff ... mark changed lines (see |quickfixsigns#vcsdiff#GetList()|)
    "   vcsmerge .. merge conflicts produced by VCS like Git
    "   marks   ... marks |'a|-zA-Z (see also |g:quickfixsigns#marks#global| 
    "               and |g:quickfixsigns#marks#buffer|)
    "
    " The sign classes are defined in g:quickfixsigns_class_{NAME}.
    "
    " A sign class definition is a |Dictionary| with the following fields:
    "
    "   sign:  The name of the sign, which has to be defined. If the 
    "          value begins with "*", the value is interpreted as 
    "          function name that is called with a qfl item as its 
    "          single argument.
    "   get:   A format string (see |printf|) for VIM |expression|, 
    "          containing one "%s" placeholder (the filename), that 
    "          returns a list compatible with |getqflist()|.
    "   event: A list of events on which signs of this type should be 
    "          set (default: BufEnter)
    "   level: Precedence of signs (if there are more signs at a line, 
    "          the one with the higher level will be displayed)
    "   maxsigns: Override the value of |g:quickfixsigns_max|
    "   timeout: Update the sign at most every X seconds (defaults to 
    "          |g:quickfixsigns_timeout|)
    "   test:  Update the sign only if the expression is true.
    let g:quickfixsigns_classes = ['qfl', 'loc', 'marks', 'vcsdiff', 'breakpoints']   "{{{2
    " let g:quickfixsigns_classes = ['rel', 'qfl', 'loc', 'marks']   "{{{2
endif


if !exists('g:quickfixsigns_timeout')
    " The default number of seconds for the timeout option for sign 
    " class definitions (see |g:quickfixsigns_classes|).
    let g:quickfixsigns_timeout = 0   "{{{2
endif


if !exists('g:quickfixsigns_events_default')
    let g:quickfixsigns_events_default = exists('g:loaded_ArgsAndMore') || exists('g:loaded_EnhancedJumps') ? [] : ['BufEnter']   "{{{2
endif


if !exists('g:quickfixsigns_events_base')
    let g:quickfixsigns_events_base = g:quickfixsigns_events_default + ['CursorHold', 'CursorHoldI']   "{{{2
endif


if !exists('g:quickfixsigns_events')
    " List of events for signs that should be frequently updated.
    let g:quickfixsigns_events = g:quickfixsigns_events_base + ['BufReadPost', 'InsertEnter', 'InsertLeave']   "{{{2
endif


if !exists('g:quickfixsigns_class_rel')
    " Signs for number of lines relative to the current line.
    " Since 7.3, vim provides the 'relativenumber' option that provides 
    " a similar functionality.
    " See also |quickfixsigns#RelNumbersOnce()|.
    let g:quickfixsigns_class_rel = {'sign': '*s:RelSign', 'get': 's:GetRelList(%s, "rel")', 'event': g:quickfixsigns_events, 'max': 9, 'level': 9}  "{{{2
endif


if !exists('g:quickfixsigns_class_rel2')
    let g:quickfixsigns_class_rel2 = copy(g:quickfixsigns_class_rel)
    let g:quickfixsigns_class_rel2.get = 's:GetRelList(%s, "rel2")'
    let g:quickfixsigns_class_rel2.max = 99
endif


if !exists('g:quickfixsigns_class_qfl')
    " Signs for |quickfix| lists.
    let g:quickfixsigns_class_qfl = {'sign': '*s:QflSign', 'get': 's:GetQFList(%s)', 'event': g:quickfixsigns_events_base + ['QuickFixCmdPost'], 'level': 7, 'scope': 'vim'}   "{{{2
endif


if !exists('g:quickfixsigns_class_loc')
    " Signs for |location| lists.
    let g:quickfixsigns_class_loc = {'sign': '*s:LocSign', 'get': 's:GetLocList(%s)', 'event': g:quickfixsigns_events_base + ['QuickFixCmdPost'], 'level': 8}   "{{{2
endif


if !exists('g:quickfixsigns_list_types')
    let g:quickfixsigns_list_types = 'EW'   "{{{2
endif


if !exists('g:quickfixsigns_sign_may_use_double')
    " FIX Confliction between quickfixsigns_vim and ambiwidth=double
    " https://github.com/tomtom/quickfixsigns_vim/issues/72
    let g:quickfixsigns_sign_may_use_double = !exists('&ambiwidth') || &ambiwidth ==# 'single'   "{{{2
endif


if !exists('g:quickfixsigns_class_cursor')
    " Sign for the current cursor position. The cursor position is 
    " lazily updated. If you want something more precise, consider 
    " setting 'cursorline'.
    let g:quickfixsigns_class_cursor = {'sign': 'QFS_CURSOR', 'get': 's:GetCursor(%s)', 'event': g:quickfixsigns_events_base + ['CursorMoved', 'CursorMovedI'], 'timeout': 1, 'level': 3}   "{{{2
endif


if !exists('g:quickfixsigns_balloon')
    " If non-null, display a balloon when hovering with the mouse over 
    " the sign.
    " buffer-local or global
    let g:quickfixsigns_balloon = 1   "{{{2
endif


if !exists('g:quickfixsigns_echo_balloon')
    " If true, echo text in tooltip balloon also on the command line. 
    " You may have to press ENTER to continue.
    let g:quickfixsigns_echo_balloon = 0   "{{{2
endif


if !exists('g:quickfixsigns_max')
    " Don't display signs if the list is longer than n items.
    let g:quickfixsigns_max = 500   "{{{2
endif


if !exists('g:quickfixsigns_blacklist_buffer')
    " Don't show signs in buffers matching this |regexp|.
    let g:quickfixsigns_blacklist_buffer = '\(^\|[\/]\)\(__.*__\|ControlP\|NERD_tree_.*\|-MiniBufExplorer-\|\[unite\] - .*\)$'   "{{{2
endif


if !exists('g:quickfixsigns_type_rx')
    " A dictionary of {&filetype: [[TYPE, REGEXP] ...]}.
    " If a qfl or loc list item has no type defined, match the item 
    " against the |regexp| and assume TYPE if it matches.
    " Use "*" for default values.
    " This way, users can patch suboptimal 'errorformat' definitions.
    let g:quickfixsigns_type_rx = {'*': [['E', '\c\<error\>'], ['W', '\c\<warning\>']]}   "{{{2
endif


if !exists('g:quickfixsigns_protect_sign_rx')
    " Don't set signs at lines with signs whose name match this 
    " |regexp|.
    let g:quickfixsigns_protect_sign_rx = ''   "{{{2
endif


if !exists('g:quickfixsigns_icons')
    if has("gui_running")
        if !has('win16') && !has('win32') && !has('win64')
            let s:icons_dir = expand('<sfile>:p:h:h:') .'/bitmaps/open_icon_library/16x16/'
            if isdirectory(s:icons_dir)
                let g:quickfixsigns_icons = {
                            \ 'qfl': s:icons_dir .'others/bullet-star.png',
                            \ 'qfl_E': s:icons_dir .'status/dialog-warning-2.png',
                            \ 'qfl_W': s:icons_dir .'others/flag-red-2.png',
                            \ 'loc': s:icons_dir .'others/bullet-blue.png',
                            \ 'loc_E': s:icons_dir .'status/dialog-warning-3.png',
                            \ 'loc_W': s:icons_dir .'others/flag-orange.png',
                            \ 'cursor': s:icons_dir .'actions/go-next-4.png',
                            \ 'breakpoint': s:icons_dir .'actions/media-playback-pause-3.png'
                            \ }
            endif
            unlet s:icons_dir
        endif
    endif
    if !exists('g:quickfixsigns_icons')
        " A dictionary {TYPE => IMAGE_FILENAME} that is used to select 
        " icons that should be displayed as signs.
        " Defaults to empty on windows and non-gui versions.
        let g:quickfixsigns_icons = {}   "{{{2
    endif
endif


if !exists('g:quickfixsigns_use_dummy')
    " If true, set a dummy sign. It's recommended to use dummy signs 
    " when |g:quickfixsigns_classes| does not contain "marks".
    let g:quickfixsigns_use_dummy = index(g:quickfixsigns_classes, 'marks') == -1   "{{{2
endif


" ----------------------------------------------------------------------
let s:quickfixsigns_base = 5272
let s:quickfixsigns_register = {}


function! s:PurgeRegister() "{{{3
    let bufnums = {}
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
    for [ikey, def] in items(s:quickfixsigns_register)
        let bufnr = def.bufnr
        if !bufloaded(bufnr)
            " TLogVAR bufnr, ikey
            if g:quickfixsigns_debug && !has_key(bufnums, bufnr)
                echom "QuickFixSigns DEBUG PurgeRegister: Obsolete buffer:" bufnr
                let bufnums[bufnr] = 1
            endif
            call remove(s:quickfixsigns_register, ikey)
        endif
    endfor
endf


function! s:Redir(cmd) "{{{3
    let verbose = &verbose
    let &verbose = 0
    try
        if exists('*execute')
            let rv = execute(a:cmd, 'silent')
        else
            let rv = ''
            redir => rv
            exec 'silent' a:cmd
            redir END
        endif
        return exists('rv')? rv : ''
    finally
        let &verbose = verbose
    endtry
endf


let g:quickfixsigns_signs = split(s:Redir('sign list'), '\n')
call filter(g:quickfixsigns_signs, 'v:val =~ ''^sign QFS_''')
call map(g:quickfixsigns_signs, 'matchstr(v:val, ''^sign \zsQFS_\w\+'')')


function! s:DefineSign(name, text, texthl, icon_name) abort "{{{3
    if index(g:quickfixsigns_signs, a:name) == -1
        let cmd = 'sign define '. a:name .' text='. a:text .' texthl='. a:texthl
        if !empty(a:icon_name) && has_key(g:quickfixsigns_icons, a:icon_name)
            let cmd .= ' icon='. escape(g:quickfixsigns_icons[a:icon_name], ' \')
        endif
        exec cmd
        call add(g:quickfixsigns_signs, a:name)
    endif
endf

call s:DefineSign('QFS_CURSOR', '-', 'Question', 'cursor')
" ╠►☼☺‡
" ├⇒→◊☻†
call s:DefineSign('QFS_QFL', (g:quickfixsigns_sign_may_use_double && &enc ==? 'utf-8' ? '►' : '*'),'WarningMsg', 'qfl')
call s:DefineSign('QFS_LOC', (g:quickfixsigns_sign_may_use_double && &enc ==? 'utf-8' ? '◊' : '>'), 'Special', 'loc')

for s:char in split(g:quickfixsigns_list_types, '\zs')
    call s:DefineSign('QFS_QFL_'. s:char, (g:quickfixsigns_sign_may_use_double && &enc ==? 'utf-8' ? '║' : '*') . s:char, 'WarningMsg', 'qfl_'. s:char)
    call s:DefineSign('QFS_LOC_'. s:char, (g:quickfixsigns_sign_may_use_double && &enc ==? 'utf-8' ? '│' : '>') . s:char, 'Special', 'loc_'. s:char)
endfor
unlet! s:char

let s:relmax = -1
function! s:GenRel(num) "{{{3
    " TLogVAR a:num
    if a:num > s:relmax && a:num < 100
        for n in range(s:relmax + 1, a:num)
            call s:DefineSign('QFS_REL_'. n, n, 'LineNr', '')
        endfor
        let s:relmax = a:num
    endif
endf


function! QuickfixsignsSelect(list) "{{{3
    let classes = exists('g:quickfixsigns_lists') ? keys(g:quickfixsigns_lists) : []
    let g:quickfixsigns_lists = {}
	for what in a:list
        if exists('g:quickfixsigns_class_'. what)
            let g:quickfixsigns_lists[what] = g:quickfixsigns_class_{what}
            let iwhat = index(classes, what)
            if iwhat != -1
                call remove(classes, iwhat)
            endif
        endif
	endfor
    for class in classes
        call QuickfixsignsClear(class)
    endfor
endf


" :display: QuickfixsignsUpdate(?class="")
function! QuickfixsignsUpdate(...) "{{{3
    let what = a:0 >= 1 ? a:1 : ""
    call QuickfixsignsClear(what)
    call QuickfixsignsSet('')
endf


let s:clists = {}

" :display: QuickfixsignsSet(event, ?classes=[], ?filename=expand('%:p'))
" (Re-)Set the signs that should be updated at a certain event. If event 
" is empty, update all signs.
"
" Normally, the end-user doesn't need to call this function.
"
" If the buffer-local variable b:quickfixsigns_ignore (a list of 
" strings) exists, sign classes in that list won't be displayed for the 
" current buffer.
function! QuickfixsignsSet(event, ...) "{{{3
    " TLogVAR a:event, a:000
    if exists("b:noquickfixsigns") && b:noquickfixsigns
        return
    endif
    if exists("g:noquickfixsigns") && g:noquickfixsigns
        return
    endif
    let bufsignclasses = s:ListValues()
    " TLogVAR bufsignclasses
    if empty(bufsignclasses)
        return
    endif
    " TLogVAR a:event, a:000
    let filename = a:0 >= 2 ? a:2 : expand('%:p')
    " TLogVAR a:event, filename, bufname('%')
    if empty(filename) || filename =~ g:quickfixsigns_blacklist_buffer
        return
    endif
    if !exists('b:quickfixsigns_last_line')
        let b:quickfixsigns_last_line = 0
    endif
    let anyway = empty(a:event)
    " TLogVAR anyway, a:event
    let must_updatelinenumbers = 1
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
    for [class, def] in bufsignclasses
        " TLogVAR class, def
        if anyway
            let set = 1
        else
            let set = index(get(def, 'event', g:quickfixsigns_events_default), a:event) != -1
            if set
                if has_key(def, 'test')
                    let set = eval(def.test)
                endif
            elseif exists('b:quickfixsigns_needs_update') && b:quickfixsigns_needs_update
                let set = 1
                let b:quickfixsigns_needs_update = 0
            endif
        endif
        if a:0 >= 1 && !empty(a:1)
            let select = index(a:1, class) != -1
        else
            let select = 1
        endif
        if set && select
            " TLogVAR class, set, select
            let t_d = get(def, 'timeout', g:quickfixsigns_timeout)
            if t_d != 0
                let t_l = localtime()
                let t_s = string(def)
                if !exists('b:quickfixsigns_last_run')
                    let b:quickfixsigns_last_run = {}
                endif
                " TLogVAR t_s, t_d, t_l
                " echom "DBG" t_l - get(b:quickfixsigns_last_run, t_s, 0) >= t_d
            endif
            if anyway || (t_d == 0) || (t_l - get(b:quickfixsigns_last_run, t_s, 0) >= t_d)
                if g:quickfixsigns_debug
                    call quickfixsigns#AssertNoObsoleteBuffers(s:quickfixsigns_register)
                endif
                if t_d != 0
                    let b:quickfixsigns_last_run[t_s] = t_l
                endif
                let list = s:GetList(def, filename)
                let okey = class .'*'. filename
                let olist = get(s:clists, okey, [])
                if list != olist
                    if must_updatelinenumbers
                        let must_updatelinenumbers = 0
                        call s:UpdateLineNumbers()
                    endif
                    " TLogVAR len(list)
                    " TLogVAR list
                    " TLogVAR class, 'scope == buffer'
                    let bufnr = bufnr(filename)
                    let s:clists[okey] = deepcopy(list)
                    let scope_test = s:GetScopeTest(class, bufnr, '')
                    if !empty(scope_test)
                        " echom "DBG" scope_test
                        " echom "DBG" string(list)
                        call filter(list, scope_test)
                    endif
                    " TLogVAR len(list)
                    " TLogVAR list
                    let maxsigns = get(def, 'maxsigns', g:quickfixsigns_max)
                    if !empty(list) && len(list) <= maxsigns
                        call s:UpdateSigns(class, def, bufnr, list)
                        if has('balloon_eval') && g:quickfixsigns_balloon
                            if exists('g:loaded_tlib') && g:loaded_tlib >= 39  " ignore dependency
                                call tlib#balloon#Register('QuickfixsignsBalloon()')
                            elseif !exists('b:quickfixsigns_balloon') && empty(&balloonexpr)
                                let b:quickfixsigns_ballooneval = &ballooneval
                                let b:quickfixsigns_balloonexpr = &balloonexpr
                                setlocal ballooneval balloonexpr=QuickfixsignsBalloon()
                                let b:quickfixsigns_balloon = 1
                            endif
                        endif
                    else
                        if !empty(list) && g:quickfixsigns_debug
                            echohl WarningMsg
                            echom 'QuickFixSigns DEBUG: not displaying' len(list)
                                        \ class 'signs (max' maxsigns .'; see :h g:quickfixsigns_max).'
                            echohl NONE
                        endif
                        call s:ClearBuffer(class, def.sign, bufnr, [])
                    endif
                endif
            endif
        endif
    endfor
    let b:quickfixsigns_last_line = line('.')
endf


function! s:UpdateSigns(class, def, bufnr, list) "{{{3
    " TLogVAR a:class, a:bufnr, len(a:list)
    let new_ikeys = s:PlaceSign(a:class, a:def.sign, a:list)
    " TLogVAR len(new_ikeys)
    " if g:quickfixsigns_debug " DBG
        " let sign_ids = map(copy(new_ikeys), 's:quickfixsigns_register[v:val].id') " DBG
        " TLogVAR sign_ids
    " endif " DBG
    call s:ClearBuffer(a:class, a:def.sign, a:bufnr, new_ikeys)
    if g:quickfixsigns_debug
        call quickfixsigns#AssertUniqueSigns(a:bufnr, QuickfixsignsListBufferSigns(a:bufnr))
    endif
endf


function! s:UpdateLineNumbers() "{{{3
    let buffersigns = {}
    let clear_ikeys = []
    " echom "DBG UpdateLineNumbers quickfixsigns_register" string(s:quickfixsigns_register)
    for [ikey, item] in items(s:quickfixsigns_register)
        let bufnr = item.bufnr
        " if bufnr(bufnr) == -1
        if !bufloaded(bufnr) || bufnr <= 0
            if g:quickfixsigns_debug
                echom "QuickFixSigns DEBUG UpdateLineNumbers: Invalid bufnr:" string(bufnr)
            endif
        else
            let lnum = item.lnum
            let id = item.id
            if !has_key(buffersigns, bufnr)
                let bsigns = QuickfixsignsListBufferSigns(bufnr)
                let bufnrsigns = {}
                for sign in bsigns
                    let bufnrsigns[sign.id] = sign.lnum
                endfor
                let buffersigns[bufnr] = bufnrsigns
            else
                let bufnrsigns = buffersigns[bufnr]
            endif
            if has_key(bufnrsigns, id)
                let slnum = bufnrsigns[id]
                if slnum != lnum
                    " TLogVAR ikey, lnum, slnum
                    let item.lnum = slnum
                    let new_ikey = s:GetIKey(item)
                    if has_key(s:quickfixsigns_register, new_ikey)
                        " TLogVAR slnum, lnum
                        call add(clear_ikeys, ikey)
                    else
                        call remove(s:quickfixsigns_register, ikey)
                        let item.ikey = new_ikey
                        let s:quickfixsigns_register[new_ikey] = item
                        " TLogVAR ikey, new_ikey
                    endif
                endif
            elseif g:quickfixsigns_debug
                echom "QuickFixSigns UpdateLineNumbers: id not found:" bufnr id
            endif
        endif
    endfor
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
    if !empty(clear_ikeys)
        call s:ClearSigns(clear_ikeys, 1)
    endif
endf


function! s:GetList(def, filename) "{{{3
    " TLogVAR a:def, a:filename
    let getter = printf(a:def.get, string(a:filename))
    " TLogVAR getter
    let list = copy(eval(getter))
    return list
endf


function! QuickfixsignsUnique(list) "{{{3
    let items = {}
    for item in a:list
        let id = printf('%d*%d', get(item, 'bufnr', get(item, 'filename', '')), get(item, 'lnum', 0))
        if has_key(items, id)
            let oitem = items[id]
            let oitem.text = join([get(oitem, 'text', ''), get(item, 'text', '')], "\n")
            let items[id] = oitem
        else
            let items[id] = item
        endif
    endfor
    return values(items)
endf


function! s:GetSignsAtLine(bufnr, lnum) abort "{{{3
    " TLogVAR a:bufnr, a:lnum
    let bufname = bufname(a:bufnr)
    let acc = []
    for [class, def] in s:ListValues()
        let list = s:GetList(def, bufname)
        " TLogVAR class, len(list)
        call filter(list, 'v:val.bufnr == a:bufnr && v:val.lnum == a:lnum')
        " TLogVAR len(list), g:quickfixsigns_max
        if !empty(list) && len(list) < g:quickfixsigns_max
            let acc += list
        endif
    endfor
    return acc
endf


function! s:GetSignsTextAtLine(bufnr, lnum) abort "{{{3
    let acc = s:GetSignsAtLine(a:bufnr, a:lnum)
    " TLogVAR acc
    let text = join(map(acc, 'v:val.text'), "\n")
    return text
endf


function! QuickfixsignsEcho(bufnr, lnum) abort "{{{3
    let l:text = s:GetSignsTextAtLine(a:bufnr, a:lnum)
    echo l:text
endf


function! QuickfixsignsBalloon() "{{{3
    " TLogVAR v:beval_lnum, v:beval_col
    if v:beval_col <= 1
        let text = s:GetSignsTextAtLine(bufnr('%'), v:beval_lnum)
        " TLogVAR text
    elseif exists('b:quickfixsigns_balloonexpr') && !empty(b:quickfixsigns_balloonexpr)
        let text = eval(b:quickfixsigns_balloonexpr)
        if !has('balloon_multiline')
            let text = substitute(text, '\n', ' ', 'g')
        endif
    else
        let text = ''
    endif
    if exists('g:loaded_tlib') && g:loaded_tlib >= 39  " ignore dependency
        if !empty(text) && g:quickfixsigns_echo_balloon
            call tlib#notify#Echo(substitute(text, '\n', '|', 'g'), "Statement")
        endif
    endif
    return text
endf


function! QuickfixsignsToggle()
    if exists('g:quickfixsigns_lists') && !empty(g:quickfixsigns_lists)
        QuickfixsignsDisable
    else
        QuickfixsignsEnable
    end
endf


function! s:GetCursor(bufname) "{{{3
    let pos = getpos('.')
    return [{'bufnr': bufnr('%'), 'lnum': pos[1], 'col': pos[2], 'text': 'Current line'}]
endf


function! s:ListValues() "{{{3
    if !exists('b:quickfixsigns_sorted_lists') || b:quickfixsigns_lists != g:quickfixsigns_lists
        let signs_lists = g:quickfixsigns_lists
        if exists('b:quickfixsigns_ignore')
            let signs_lists = filter(copy(signs_lists), 'index(b:quickfixsigns_ignore, v:key) == -1')
        endif
        let b:quickfixsigns_lists = copy(g:quickfixsigns_lists)
        let b:quickfixsigns_sorted_lists = sort(items(signs_lists), 's:CompareClasses')
    endif
    return b:quickfixsigns_sorted_lists
endf


function! s:CompareClasses(a, b) "{{{3
    let i1 = str2nr(get(a:a[1], 'level', 5))
    let i2 = str2nr(get(a:b[1], 'level', 5))
    return i1 == i2 ? 0 : i1 < i2 ? 1 : -1
endf


function! s:RelSign(item) "{{{3
    return 'QFS_'. a:item.text
endf


function! s:QflSign(item) "{{{3
    return s:ListSign(a:item, 'QFS_QFL')
endf


function! s:LocSign(item) "{{{3
    return s:ListSign(a:item, 'QFS_LOC')
endf


function! s:ListSign(item, base) "{{{3
    let type = get(a:item, 'type', '')
    if empty(type) && a:item.bufnr > 0 && !empty(get(a:item, 'text', ''))
        let ft = getbufvar(a:item.bufnr, '&ft')
        if empty(ft)
            let ft = '*'
        endif
        let text = a:item.text
        for [t, rx] in get(g:quickfixsigns_type_rx, ft, [])
            if text =~ rx
                let type = t
                break
            endif
        endfor
    endif
    " TLogVAR a:item, a:base, type
    if empty(type) || stridx(g:quickfixsigns_list_types, type) == -1
        return a:base
    else
        return a:base .'_'. type
    endif
endf


function! s:GetRelList(bufname, class) "{{{3
	let lnum = line('.')
	let col = col('.')
	let bufnr = bufnr('%')
    let top = line('w0') - lnum
    let bot = line('w$') - lnum
    let max = g:quickfixsigns_class_{a:class}.max
    if max >= 0
        let top = max([top, -max])
        let bot = min([bot, max])
    endif
    " TLogVAR top, bot
    call s:GenRel(max([abs(top), abs(bot)]))
    return map(range(top, bot), '{"bufnr": bufnr, "lnum": lnum + v:val, "col": col, "text": "REL_". abs(v:val)}')
endf


" Clear all signs with name SIGN.
function! QuickfixsignsClear(class) "{{{3
    " TLogVAR a:sign_rx
    let ikeys = keys(s:quickfixsigns_register)
    if !empty(a:class)
        call filter(ikeys, 's:quickfixsigns_register[v:val].class ==# a:class')
    endif
    " TLogVAR ikeys
    call s:ClearSigns(ikeys, 1)
endf


function! s:RemoveBuffer(bufnr, quick) "{{{3
    " TLogVAR a:bufnr
    let old_ikeys = keys(filter(copy(s:quickfixsigns_register), s:GetScopeTest('', str2nr(a:bufnr), '')))
    " TLogVAR old_ikeys
    let bufname = fnamemodify(bufname(a:bufnr), ':p')
    let bufname_rx = '\V*'. escape(bufname, '\') .'\$'
    " TLogVAR bufname_rx
    " echom "DBG" string(keys(s:clists))
    let s:clists = filter(s:clists, 'v:key !~# bufname_rx')
    " echom "DBG" string(keys(s:clists))
    call s:ClearSigns(old_ikeys, !a:quick)
endf


" Clear all signs with name SIGN in buffer BUFNR.
function! s:ClearBuffer(class, sign, bufnr, keep_ikeys) "{{{3
    " TLogVAR a:class, a:sign, a:bufnr, a:keep_ikeys
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
    let old_ikeys = keys(filter(copy(s:quickfixsigns_register), s:GetScopeTest(a:class, a:bufnr, 'v:val.class ==# a:class && index(a:keep_ikeys, v:key) == -1')))
    " TLogVAR old_ikeys
    " if g:quickfixsigns_debug " DBG
        " let sign_ids = map(copy(old_ikeys), 's:quickfixsigns_register[v:val].id') " DBG
        " TLogVAR sign_ids
    " endif " DBG
    call s:ClearSigns(old_ikeys, 1)
endf


function! s:ClearSigns(ikeys, unplace) "{{{3
    " TLogVAR a:ikeys, a:unplace
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
    for ikey in a:ikeys
        let def   = s:quickfixsigns_register[ikey]
        let bufnr = def.bufnr
        if a:unplace
            if bufloaded(bufnr)
                " TLogVAR bufnr, ikey
                exec 'sign unplace '. def.id .' buffer='. bufnr
            elseif g:quickfixsigns_debug
                echom "Quickfixsigns DEBUG: bufnr not loaded:" bufnr ikey string(def)
            endif
        endif
        call remove(s:quickfixsigns_register, ikey)
    endfor
    " echom "DBG quickfixsigns_register" string(s:quickfixsigns_register)
endf


function! s:GetScopeTest(class, bufnr, tests) "{{{3
    let scope = empty(a:class) ? 'buffer' : get(g:quickfixsigns_class_{a:class}, 'scope', 'buffer')
    if scope == "vim"
        let rv = a:tests
    else
        let test = '(get(v:val, "scope", "buffer") == "vim" || v:val.bufnr == '. a:bufnr .')'
        if empty(a:tests)
            let rv = test
        else
            let rv = a:tests .' && '. test
        endif
    endif
    " TLogVAR rv
    return rv
endf


function! s:CreateBufferSignsCache() "{{{3
    if exists('s:buffer_signs')
        return 0
    else
        let s:buffer_signs = {'blacklist': {}}
        return 1
    endif
endf


function! s:RemoveBufferSignsCache(cbs) "{{{3
    if a:cbs
        unlet s:buffer_signs
    endif
endf


function! s:GetBufferSignsBlacklist(bufnr) abort "{{{3
    if !has_key(s:buffer_signs.blacklist, a:bufnr)
        " TODO
        let s:buffer_signs.blacklist[a:bufnr] = s:BlacklistedLnums(QuickfixsignsListBufferSigns(a:bufnr))
    endif
    return s:buffer_signs.blacklist[a:bufnr]
endf


function! s:BlacklistedLnums(qfs) abort "{{{3
    let lnums = {}
    if !empty(g:quickfixsigns_protect_sign_rx)
        for signdef in a:qfs
            if signdef.name =~ g:quickfixsigns_protect_sign_rx
                let lnums[signdef.lnum] = 1
            endif
        endfor
    endif
    return lnums
endf


function! s:CheckOtherSigns(bufnr, lnum) "{{{3
    " TLogVAR a:bufnr, a:lnum
    return !has_key(s:GetBufferSignsBlacklist(a:bufnr), a:lnum)
endf


" function! s:SignExistsAt(bufnr, lnum, sign) "{{{3
"     " TLogVAR a:bufnr, a:lnum, a:sign
"     if !has_key(s:buffer_signs, a:bufnr)
"         let s:buffer_signs[a:bufnr] = QuickfixsignsListBufferSigns(a:bufnr)
"     endif
"     let bsigns = copy(s:buffer_signs[a:bufnr])
"     " TLogVAR bsigns
"     if empty(a:sign)
"         call filter(bsigns, 'v:val.lnum == a:lnum')
"     else
"         call filter(bsigns, 'v:val.lnum == a:lnum && v:val.name == a:sign')
"     endif
"     return len(bsigns) > 0
" endf


function! QuickfixsignsListBufferSigns(bufnr) "{{{3
    if a:bufnr == -1
        return []
    endif
    let signss = s:Redir('sign place buffer='. a:bufnr)
    if exists('signss')
        let signs = split(signss, '\n')
        let signs = map(signs, 's:ProcessSign(v:val)')
        let signs = filter(signs, '!empty(v:val)')
        " if len(signs) > 2
        "     call remove(signs, 0, 1)
        " else
        "     let signs = []
        " endif
    else
        if g:quickfixsigns_debug
            echohl WarningMsg
            echom "DEBUG quickfixsigns: BufferSigns:" a:bufnr
            echohl NONE
        endif
        let signs = []
    endif
    return signs
endf


function! s:ProcessSign(sign) "{{{3
    let m = matchlist(a:sign, '^\s\+\S\+=\(\d\+\)\s\+\S\+=\(\d\+\)\s\+\S\+=\(\S\+\)\s*$')
    " TLogVAR a:sign, m
    if empty(m)
        return {}
    else
        return {
                    \ 'sign': a:sign,
                    \ 'lnum': str2nr(m[1]),
                    \ 'id': str2nr(m[2]),
                    \ 'name': m[3],
                    \ }
    endif
endf


" Add signs for all locations in LIST. LIST must confirm with the 
" quickfix list format (see |getqflist()|; only the fields lnum and 
" bufnr are required).
"
" list:: a quickfix or location list
" sign:: a sign defined with |:sign-define|
function! s:PlaceSign(class, sign, list) "{{{3
    " TAssertType a:sign, 'string'
    " TAssertType a:list, 'list'
    " TLogVAR a:class, a:sign, len(a:list)
    let keep_ikeys = []
    let cbs = s:CreateBufferSignsCache()
    try
        for item in a:list
            " TLogVAR item
            if item.lnum > 0
                let sign = s:GetSign(a:sign, item)
                let item = extend(item, {'class': a:class, 'sign': sign})
                let item = s:SetItemId(item)
                " TLogVAR item
                if !empty(item) && bufloaded(item.bufnr) && s:CheckOtherSigns(item.bufnr, item.lnum)
                    let ikey = item.ikey
                    " TLogVAR ikey, item
                    call add(keep_ikeys, ikey)
                    if item.new
                        " TLogVAR item.bufnr, item.ikey
                        let cmd = ':sign place '. item.id .' line='. item.lnum .' name='. sign .' buffer='. item.bufnr
                        " TLogDBG cmd
                        exec cmd
                        let s:quickfixsigns_register[ikey] = item
                    endif
                endif
            endif
        endfor
    finally
        call s:RemoveBufferSignsCache(cbs)
    endtry
    return keep_ikeys
endf


function! s:GetSign(sign, item) "{{{3
    if a:sign[0] ==# '*'
        let sign = call(a:sign[1 : -1], [a:item])
        " TLogVAR sign
    else
        let sign = a:sign
    endif
    return sign
endf


function! s:SetItemId(item) "{{{3
    " TLogVAR a:item
    let bufnr = get(a:item, 'bufnr', -1)
    if bufnr == -1
        return  {}
    else
        if !has_key(a:item, 'ikey')
            let a:item.ikey = s:GetIKey(a:item)
        endif
        let a:item.new = !has_key(s:quickfixsigns_register, a:item.ikey)
        if a:item.new
            let item = a:item
            let item.id = s:quickfixsigns_base
            let s:quickfixsigns_base += 1
        else
            let item = extend(copy(s:quickfixsigns_register[a:item.ikey]), a:item)
            if !has_key(item, 'id')
                echohl WarningMsg
                echom "Quickfixsigns: Internal error: No ID:" string(item)
            endif
        endif
        return item
    endif
endf


function! s:GetIKey(item) "{{{3
    let subitems = map(['lnum', 'bufnr', 'sign', 'class', 'text'], 'get(a:item, v:val, "")')
    return join(subitems, '*')
endf


function! s:GetQFList(bufname) "{{{3
    return QuickfixsignsUnique(getqflist())
endf


function! s:GetLocList(bufname) "{{{3
    let loclist = getloclist(bufwinnr(a:bufname))
    " TLogVAR a:bufname, bufnr(a:bufname), len(loclist)
    return QuickfixsignsUnique(loclist)
endf


runtime! autoload/quickfixsigns/*.vim
call QuickfixsignsSelect(g:quickfixsigns_classes)


augroup QuickFixSigns
    autocmd!
    let s:ev_set = []
    for [s:class, s:def] in s:ListValues()
        for s:ev in get(s:def, 'event', ['BufEnter'])
            if index(s:ev_set, s:ev) == -1
                exec 'autocmd '. s:ev .' * call QuickfixsignsSet("'. s:ev .'", [], expand("<afile>:p"))'
                call add(s:ev_set, s:ev)
            endif
        endfor
    endfor
    unlet s:ev_set
    if exists('s:class')
        unlet s:ev s:class s:def
    endif

    autocmd BufLeave * if !v:dying | call s:PurgeRegister() | endif
    autocmd BufDelete * call s:RemoveBuffer(expand("<abuf>"), 1)
    if g:quickfixsigns_use_dummy
        call s:DefineSign('QFS_DUMMY', '.', 'NonText', '')
        exec "autocmd BufRead,BufNewFile * exec 'sign place' (". s:quickfixsigns_base ." - expand('<abuf>')) 'name=QFS_DUMMY line=1 buffer='. expand('<abuf>')"
    endif
    autocmd User WokmarksChange if index(g:quickfixsigns_classes, 'marks') != -1 | call QuickfixsignsUpdate("marks") | endif
augroup END

if !has('vim_starting') && !exists('g:tplugin_starting')
    QuickfixsignsSet
endif


let &cpo = s:save_cpo
unlet s:save_cpo
