" Mark quickfix & location list items with signs
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-14.
" @Last Change: 2012-10-02.
" @Revision:    1160
" GetLatestVimScripts: 2584 1 :AutoInstall: quickfixsigns.vim

if &cp || exists("loaded_quickfixsigns") || !has('signs')
    finish
endif
let loaded_quickfixsigns = 100

let s:save_cpo = &cpo
set cpo&vim

" Reset the signs in the current buffer.
command! QuickfixsignsSet call QuickfixsignsSet("")

" Disable quickfixsign.
command! QuickfixsignsDisable call s:ClearSigns(keys(g:quickfixsigns_register)) | call QuickfixsignsSelect([])

" Enable quickfixsign.
command! QuickfixsignsEnable call QuickfixsignsSelect(g:quickfixsigns_classes) | QuickfixsignsSet

" Toggle quickfixsign.
command! QuickfixsignsToggle call QuickfixsignsToggle()

" Select the sign classes that should be displayed and reset the signs 
" in the current buffer.
command! -nargs=+ -complete=customlist,quickfixsigns#CompleteSelect QuickfixsignsSelect call QuickfixsignsSelect([<f-args>]) | call QuickfixsignsUpdate()


if !exists('g:quickfixsigns_debug')
    let g:quickfixsigns_debug = 0
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
    "   marks   ... marks |'a|-zA-Z (see also " |g:quickfixsigns_marks|)
    "
    " The sign classes are defined in g:quickfixsigns_class_{NAME}.
    "
    " A sign class definition is a |Dictionary| with the following fields:
    "
    "   sign:  The name of the sign, which has to be defined. If the 
    "          value begins with "*", the value is interpreted as 
    "          function name that is called with a qfl item as its 
    "          single argument.
    "   get:   A vim script expression as string that returns a list 
    "          compatible with |getqflist()|.
    "   event: A list of events on which signs of this type should be set
    "   level: Precedence of signs (if there are more signs at a line, 
    "          the one with the higher level will be displayed)
    "   timeout: Update the sign at most every X seconds
    "   test:  Update the sign only if the expression is true.
    let g:quickfixsigns_classes = ['qfl', 'loc', 'marks', 'vcsdiff', 'breakpoints']   "{{{2
    " let g:quickfixsigns_classes = ['rel', 'qfl', 'loc', 'marks']   "{{{2
endif


if !exists('g:quickfixsigns_events')
    " List of events for signs that should be frequently updated.
    let g:quickfixsigns_events = ['BufEnter', 'CursorHold', 'CursorHoldI', 'InsertLeave', 'InsertEnter', 'InsertChange']   "{{{2
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
    let g:quickfixsigns_class_qfl = {'sign': 'QFS_QFL', 'get': 's:GetQFList(%s)', 'event': ['BufEnter', 'CursorHold', 'CursorHoldI', 'QuickFixCmdPost'], 'level': 7, 'scope': 'vim'}   "{{{2
endif


if !exists('g:quickfixsigns_class_loc')
    " Signs for |location| lists.
    let g:quickfixsigns_class_loc = {'sign': 'QFS_LOC', 'get': 's:GetLocList(%s)', 'event': ['BufEnter', 'CursorHold', 'CursorHoldI', 'QuickFixCmdPost'], 'level': 8}   "{{{2
endif


if !exists('g:quickfixsigns_class_cursor')
    " Sign for the current cursor position. The cursor position is 
    " lazily updated. If you want something more precise, consider 
    " setting 'cursorline'.
    let g:quickfixsigns_class_cursor = {'sign': 'QFS_CURSOR', 'get': 's:GetCursor(%s)', 'event': ['BufEnter', 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI'], 'timeout': 1, 'level': 3}   "{{{2
endif


if !exists('g:quickfixsigns_balloon')
    " If non-null, display a balloon when hovering with the mouse over 
    " the sign.
    " buffer-local or global
    let g:quickfixsigns_balloon = 1   "{{{2
endif


if !exists('g:quickfixsigns_max')
    " Don't display signs if the list is longer than n items.
    let g:quickfixsigns_max = 500   "{{{2
endif


if !exists('g:quickfixsigns_blacklist_buffer')
    " Don't show signs in buffers matching this |regexp|.
    let g:quickfixsigns_blacklist_buffer = '^\(__.*__\|NERD_tree_.*\|-MiniBufExplorer-\)$'   "{{{2
endif


if !exists('g:quickfixsigns_icons')
    if has("gui_running")
        if !has('win16') && !has('win32') && !has('win64')
            let s:icons_dir = expand('<sfile>:p:h:h:') .'/bitmaps/open_icon_library/16x16/'
            if isdirectory(s:icons_dir)
                let g:quickfixsigns_icons = {
                            \ 'qfl': s:icons_dir .'status/dialog-error-5.png',
                            \ 'loc': s:icons_dir .'status/dialog-warning-4.png',
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



" ----------------------------------------------------------------------
let s:quickfixsigns_base = 5272
let g:quickfixsigns_register = {}


function! s:PurgeRegister() "{{{3
    let bufnums = {}
    for [ikey, def] in items(g:quickfixsigns_register)
        let bufnr = def.bufnr
        if !bufloaded(bufnr)
            if g:quickfixsigns_debug && !has_key(bufnums, bufnr)
                echom "QuickFixSigns DEBUG PurgeRegister: Obsolete buffer:" bufnr
                let bufnums[bufnr] = 1
            endif
            call remove(g:quickfixsigns_register, ikey)
        endif
    endfor
endf


function! s:Redir(cmd) "{{{3
    let verbose = &verbose
    let &verbose = 0
    try
        redir => rv
        exec 'silent' a:cmd
        redir END
        return exists('rv')? rv : ''
    finally
        let &verbose = verbose
    endtry
endf


let s:signss = s:Redir('silent sign list')
let g:quickfixsigns_signs = split(s:signss, '\n')
call filter(g:quickfixsigns_signs, 'v:val =~ ''^sign QFS_''')
call map(g:quickfixsigns_signs, 'matchstr(v:val, ''^sign \zsQFS_\w\+'')')

if index(g:quickfixsigns_signs, 'QFS_QFL') == -1
    if exists('g:quickfixsigns_icons.qfl')
        exec 'sign define QFS_QFL text=* texthl=WarningMsg icon='. escape(g:quickfixsigns_icons.qfl, ' \')
    else
        sign define QFS_QFL text=* texthl=WarningMsg
    endif
endif

if index(g:quickfixsigns_signs, 'QFS_LOC') == -1
    if exists('g:quickfixsigns_icons.loc')
        exec 'sign define QFS_LOC text=> texthl=Special icon='. escape(g:quickfixsigns_icons.loc, ' \')
    else
        sign define QFS_LOC text=> texthl=Special
    endif
endif

if index(g:quickfixsigns_signs, 'QFS_CURSOR') == -1
    if exists('g:quickfixsigns_icons.cursor')
        exec 'sign define QFS_CURSOR text=- texthl=Question icon='. escape(g:quickfixsigns_icons.cursor, ' \')
    else
        sign define QFS_CURSOR text=- texthl=Question
    endif
endif

sign define QFS_DUMMY text=. texthl=NonText

let s:relmax = -1
function! s:GenRel(num) "{{{3
    " TLogVAR a:num
    " echom "DBG ". s:relmax
    if a:num > s:relmax && a:num < 100
        for n in range(s:relmax + 1, a:num)
            exec 'sign define QFS_REL_'. n .' text='. n .' texthl=LineNr'
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
    call QuickfixsignsSet("")
endf


" :display: QuickfixsignsSet(event, ?classes=[])
" (Re-)Set the signs that should be updated at a certain event. If event 
" is empty, update all signs.
"
" Normally, the end-user doesn't need to call this function.
"
" If the buffer-local variable b:quickfixsigns_ignore (a list of 
" strings) exists, sign classes in that list won't be displayed for the 
" current buffer.
function! QuickfixsignsSet(event, ...) "{{{3
    if exists("b:noquickfixsigns") && b:noquickfixsigns
        return
    endif
    " TLogVAR a:event, a:000
    let filename = a:0 >= 2 ? a:2 : expand('%:p')
    " TLogVAR a:event, filename, bufname('%')
    if fnamemodify(filename, ':t') =~ g:quickfixsigns_blacklist_buffer
        return
    endif
    if !exists('b:quickfixsigns_last_line')
        let b:quickfixsigns_last_line = 0
    endif
    let bufnr = bufnr(filename)
    let anyway = empty(a:event)
    " TLogVAR bufnr, anyway, a:event
    call s:UpdateLineNumbers()
    for [class, def] in s:ListValues()
        " TLogVAR class, def
        if anyway
            let set = 1
        elseif index(get(def, 'event', ['BufEnter']), a:event) != -1
            let set = !has_key(def, 'test') || eval(def.test)
        else
            let set = 0
        endif
        if a:0 >= 1 && !empty(a:1)
            let select = index(a:1, class) != -1
        else
            let select = 1
        endif
        if set && select
            " TLogVAR class, set, select
            let t_d = get(def, 'timeout', 0)
            let t_l = localtime()
            let t_s = string(def)
            if !exists('b:quickfixsigns_last_run')
                let b:quickfixsigns_last_run = {}
            endif
            " TLogVAR t_s, t_d, t_l
            if anyway || (t_d == 0) || (t_l - get(b:quickfixsigns_last_run, t_s, 0) >= t_d)
                if g:quickfixsigns_debug
                    call quickfixsigns#AssertNoObsoleteBuffers(g:quickfixsigns_register)
                endif
                let b:quickfixsigns_last_run[t_s] = t_l
                let list = s:GetList(def, filename)
                " TLogVAR len(list)
                " TLogVAR list
                " TLogVAR class, 'scope == buffer'
                let scope_test = s:GetScopeTest(class, bufnr, '')
                if !empty(scope_test)
                    " echom "DBG" scope_test
                    " echom "DBG" string(list)
                    call filter(list, scope_test)
                endif
                " TLogVAR list
                if !empty(list) && len(list) < g:quickfixsigns_max
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
                    call s:ClearBuffer(class, def.sign, bufnr, [])
                endif
            endif
        endif
    endfor
    let b:quickfixsigns_last_line = line('.')
endf


function! s:UpdateSigns(class, def, bufnr, list) "{{{3
    let new_ikeys = s:PlaceSign(a:class, a:def.sign, a:list)
    " if g:quickfixsigns_debug " DBG
        " let sign_ids = map(copy(new_ikeys), 'g:quickfixsigns_register[v:val].id') " DBG
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
    for [ikey, item] in items(g:quickfixsigns_register)
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
                    if has_key(g:quickfixsigns_register, new_ikey)
                        " TLogVAR slnum, lnum
                        call add(clear_ikeys, ikey)
                    else
                        call remove(g:quickfixsigns_register, ikey)
                        let item.ikey = new_ikey
                        let g:quickfixsigns_register[new_ikey] = item
                        " TLogVAR ikey, new_ikey
                    endif
                endif
            elseif g:quickfixsigns_debug
                echom "QuickFixSigns UpdateLineNumbers: id not found:" bufnr id
            endif
        endif
    endfor
    if !empty(clear_ikeys)
        call s:ClearSigns(clear_ikeys)
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


function! QuickfixsignsBalloon() "{{{3
    " TLogVAR v:beval_lnum, v:beval_col
    if v:beval_col <= 1
        let lnum = v:beval_lnum
        let bufnr = bufnr('%')
        " TLogVAR bufnr, lnum
        let bufname = bufname(bufnr)
        let acc = []
        for [class, def] in s:ListValues()
            let list = s:GetList(def, bufname)
            call filter(list, 'v:val.bufnr == bufnr && v:val.lnum == lnum')
            " TLogVAR list
            if !empty(list) && len(list) < g:quickfixsigns_max
                let acc += list
            endif
        endfor
        " TLogVAR acc
        return join(map(acc, 'v:val.text'), "\n")
    endif
    if exists('b:quickfixsigns_balloonexpr') && !empty(b:quickfixsigns_balloonexpr)
        let text = eval(b:quickfixsigns_balloonexpr)
        if !has('balloon_multiline')
            let text = substitute(text, '\n', ' ', 'g')
        endif
        return text
    else
        return ''
    endif
endf


function! QuickfixsignsToggle()
    if exists('g:quickfixsigns_register') && len(g:quickfixsigns_register) > 0
        exec 'QuickfixsignsDisable'
    else
        exec 'QuickfixsignsEnable'
    end
endfunction


function! s:GetCursor(bufname) "{{{3
    let pos = getpos('.')
    return [{'bufnr': bufnr('%'), 'lnum': pos[1], 'col': pos[2], 'text': 'Current line'}]
endf


function! s:ListValues() "{{{3
    let signs_lists = g:quickfixsigns_lists
    if exists('b:quickfixsigns_ignore')
        let signs_lists = filter(copy(signs_lists), 'index(b:quickfixsigns_ignore, v:key) == -1')
    endif
    return sort(items(signs_lists), 's:CompareClasses')
endf


function! s:CompareClasses(a, b) "{{{3
    let i1 = str2nr(get(a:a[1], 'level', 5))
    let i2 = str2nr(get(a:b[1], 'level', 5))
    return i1 == i2 ? 0 : i1 < i2 ? 1 : -1
endf


function! s:RelSign(item) "{{{3
    return 'QFS_'. a:item.text
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
    let ikeys = keys(g:quickfixsigns_register)
    if !empty(a:class)
        call filter(ikeys, 'g:quickfixsigns_register[v:val].class ==# a:class')
    endif
    " TLogVAR ikeys
    call s:ClearSigns(ikeys)
endf


function! s:RemoveBuffer(bufnr) "{{{3
    " TLogVAR a:bufnr
    let old_ikeys = keys(filter(copy(g:quickfixsigns_register), s:GetScopeTest('', str2nr(a:bufnr), '')))
    " TLogVAR old_ikeys
    call s:ClearSigns(old_ikeys)
endf


" Clear all signs with name SIGN in buffer BUFNR.
function! s:ClearBuffer(class, sign, bufnr, keep_ikeys) "{{{3
    " TLogVAR a:class, a:sign, a:bufnr, a:keep_ikeys
    let old_ikeys = keys(filter(copy(g:quickfixsigns_register), s:GetScopeTest(a:class, a:bufnr, 'v:val.class ==# a:class && index(a:keep_ikeys, v:key) == -1')))
    " TLogVAR old_ikeys
    " if g:quickfixsigns_debug " DBG
        " let sign_ids = map(copy(old_ikeys), 'g:quickfixsigns_register[v:val].id') " DBG
        " TLogVAR sign_ids
    " endif " DBG
    call s:ClearSigns(old_ikeys)
endf


function! s:ClearSigns(ikeys) "{{{3
    for ikey in a:ikeys
        let def   = g:quickfixsigns_register[ikey]
        let bufnr = def.bufnr
        if bufloaded(bufnr)
            " TLogVAR bufnr, ikey
            exec 'sign unplace '. def.id .' buffer='. bufnr
        elseif g:quickfixsigns_debug
            echom "Quickfixsigns DEBUG: bufnr not loaded:" bufnr ikey string(def)
        endif
        call remove(g:quickfixsigns_register, ikey)
    endfor
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
        let s:buffer_signs = {}
        return 1
    endif
endf


function! s:RemoveBufferSignsCache(cbs) "{{{3
    if a:cbs
        unlet s:buffer_signs
    endif
endf


function! s:SignExistsAt(bufnr, lnum, sign) "{{{3
    " TLogVAR a:bufnr, a:lnum, a:sign
    if !has_key(s:buffer_signs, a:bufnr)
        let s:buffer_signs[a:bufnr] = QuickfixsignsListBufferSigns(a:bufnr)
    endif
    let bsigns = copy(s:buffer_signs[a:bufnr])
    " TLogVAR bsigns
    if empty(a:sign)
        call filter(bsigns, 'v:val.lnum == a:lnum')
    else
        call filter(bsigns, 'v:val.lnum == a:lnum && v:val.name == a:sign')
    endif
    return len(bsigns) > 0
endf


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
    " TLogVAR a:sign, a:list
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
                if !empty(item) && bufloaded(item.bufnr)
                    let ikey = item.ikey
                    " TLogVAR ikey, item
                    call add(keep_ikeys, ikey)
                    if item.new
                        " TLogVAR item.bufnr, item.ikey
                        let cmd = ':sign place '. item.id .' line='. item.lnum .' name='. sign .' buffer='. item.bufnr
                        " TLogDBG cmd
                        exec cmd
                        let g:quickfixsigns_register[ikey] = item
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
    if a:sign[0] == '*'
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
        let a:item.new = !has_key(g:quickfixsigns_register, a:item.ikey)
        if a:item.new
            let item = a:item
            let item.id = s:quickfixsigns_base
            let s:quickfixsigns_base += 1
        else
            let item = extend(copy(g:quickfixsigns_register[a:item.ikey]), a:item)
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
    " TLogVAR a:bufname, bufnr(a:bufname), loclist
    return QuickfixsignsUnique(loclist)
endf


runtime! autoload/quickfixsigns/*.vim
call QuickfixsignsSelect(g:quickfixsigns_classes)
unlet! s:signss


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
    let s:will_purge_register = 1
    autocmd VimLeavePre * let s:will_purge_register = 0
    autocmd BufUnload * call s:RemoveBuffer(expand("<abuf>"))
    autocmd BufLeave * if s:will_purge_register | call s:PurgeRegister() | endif
    " autocmd BufRead,BufNewFile * exec 'sign place '. (s:quickfixsigns_base - 1) .' name=QFS_DUMMY line=1 buffer='. bufnr('%')
    autocmd User WokmarksChange if index(g:quickfixsigns_classes, 'marks') != -1 | call QuickfixsignsUpdate("marks") | endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
