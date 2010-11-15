" Mark quickfix & location list items with signs
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-14.
" @Last Change: 2010-11-15.
" @Revision:    686
" GetLatestVimScripts: 2584 1 :AutoInstall: quickfixsigns.vim

if &cp || exists("loaded_quickfixsigns") || !has('signs')
    finish
endif
let loaded_quickfixsigns = 11

let s:save_cpo = &cpo
set cpo&vim


" Reset the signs in the current buffer.
command! QuickfixsignsSet call QuickfixsignsSet("")

" Select the sign classes that should be displayed and reset the signs 
" in the current buffer.
command! -nargs=+ -complete=customlist,quickfixsigns#CompleteSelect QuickfixsignsSelect call QuickfixsignsSelect([<f-args>]) | call QuickfixsignsUpdate()


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
    " A list definition is a |Dictionary| with the following fields:
    "
    "   sign:  The name of the sign, which has to be defined. If the 
    "          value begins with "*", the value is interpreted as 
    "          function name that is called with a qfl item as its 
    "          single argument.
    "   get:   A vim script expression as string that returns a list 
    "          compatible with |getqflist()|.
    "   event: The event on which signs of this type should be set. 
    "          Possible values: BufEnter, any
    let g:quickfixsigns_classes = ['cursor', 'qfl', 'loc', 'marks', 'vcsdiff']   "{{{2
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
    let g:quickfixsigns_class_rel = {'sign': '*s:RelSign', 'get': 's:GetRelList("rel")', 'event': g:quickfixsigns_events, 'max': 9, 'level': 9}  "{{{2
endif
let g:quickfixsigns_class_rel2 = copy(g:quickfixsigns_class_rel)
let g:quickfixsigns_class_rel2.get = 's:GetRelList("rel2")'
let g:quickfixsigns_class_rel2.max = 99


if !exists('g:quickfixsigns_class_qfl')
    " Signs for |quickfix| lists.
    let g:quickfixsigns_class_qfl = {'sign': 'QFS_QFL', 'get': 'getqflist()', 'event': ['BufEnter', 'CursorHold', 'CursorHoldI', 'QuickFixCmdPost'], 'scope': 'vim'}   "{{{2
endif


if !exists('g:quickfixsigns_class_loc')
    " Signs for |location| lists.
    let g:quickfixsigns_class_loc = {'sign': 'QFS_LOC', 'get': 'getloclist(0)', 'event': ['BufEnter', 'CursorHold', 'CursorHoldI']}   "{{{2
endif


if !exists('g:quickfixsigns_class_cursor')
    " Sign for the current cursor position. The cursor position is 
    " lazily updated. If you want something more precise, consider 
    " setting 'cursorline'.
    let g:quickfixsigns_class_cursor = {'sign': 'QFS_CURSOR', 'get': 's:GetCursor()', 'event': g:quickfixsigns_events}   "{{{2
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
    let g:quickfixsigns_blacklist_buffer = '^__.*__$'   "{{{2
endif


if !exists('g:quickfixsigns_icons')
    if has("gui_running")
        if !has('win16') && !has('win32') && !has('win64')
            let s:icons_dir = expand('<sfile>:p:h:h:') .'/bitmaps/open_icon_library/16x16/'
            if isdirectory(s:icons_dir)
                let g:quickfixsigns_icons = {
                            \ 'qfl': s:icons_dir .'status/dialog-error-5.png',
                            \ 'loc': s:icons_dir .'status/dialog-warning-4.png',
                            \ 'cursor': s:icons_dir .'actions/go-next-4.png'
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
let s:cursor_last_line = 0
let s:last_run = {}


redir => s:signss
silent sign list
redir END
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
	" FIXME: unset first
    let g:quickfixsigns_lists = {}
	for what in a:list
        if what != '-'
            let g:quickfixsigns_lists[what] = g:quickfixsigns_class_{what}
        endif
	endfor
endf


" :display: QuickfixsignsUpdate(?class="")
function! QuickfixsignsUpdate(...) "{{{3
    let what = a:0 >= 1 ? a:1 : ""
    call QuickfixsignsClear(what)
    call QuickfixsignsSet("")
endf


" (Re-)Set the signs that should be updated at a certain event. If event 
" is empty, update all signs.
"
" Normally, the end-user doesn't need to call this function.
function! QuickfixsignsSet(event) "{{{3
    if exists("b:noquickfixsigns") && b:noquickfixsigns
        return
    endif
    if bufname('%') =~ g:quickfixsigns_blacklist_buffer
        return
    endif
    " let lz = &lazyredraw
    " set lz
    " try
        let bufnr = bufnr('%')
        let anyway = empty(a:event)
        for [key, def] in s:ListValues()
            " TLogVAR key, def
            if anyway || index(get(def, 'event', ['BufEnter']), a:event) != -1
                let t_d = get(def, 'timeout', 0)
                let t_l = localtime()
                let t_s = string(def)
                " TLogVAR t_s, t_d, t_l
                if anyway || (t_d == 0) || (t_l - get(s:last_run, t_s, 0) >= t_d)
                    if a:event == 'BufEnter'
                        call s:PruneRegister()
                    endif
                    let s:last_run[t_s] = t_l
                    let list = copy(eval(def.get))
                    " TLogVAR list
                    " TLogVAR key, 'scope == buffer'
                    call filter(list, 's:Scope(key, v:val) == "vim" || v:val.bufnr == bufnr')
                    " TLogVAR list
                    if !empty(list) && len(list) < g:quickfixsigns_max
                        let new_ids = s:PlaceSign(key, def.sign, list)
                        call s:ClearBuffer(key, def.sign, bufnr, new_ids)
                        if has('balloon_eval') && g:quickfixsigns_balloon
                            if exists('g:loaded_tlib') && g:loaded_tlib >= 39
                                call tlib#balloon#Register('QuickfixsignsBalloon()')
                            elseif !exists('b:quickfixsigns_balloon') && empty(&balloonexpr)
                                let b:quickfixsigns_ballooneval = &ballooneval
                                let b:quickfixsigns_balloonexpr = &balloonexpr
                                setlocal ballooneval balloonexpr=QuickfixsignsBalloon()
                                let b:quickfixsigns_balloon = 1
                            endif
                        endif
                    else
                        call s:ClearBuffer(key, def.sign, bufnr, [])
                    endif
                endif
            endif
        endfor
    " finally
    "     if &lz != lz
    "         let &lz = lz
    "     endif
    " endtry
endf


function! QuickfixsignsBalloon() "{{{3
    " TLogVAR v:beval_lnum, v:beval_col
    if v:beval_col <= 1
        let lnum = v:beval_lnum
        let bufnr = bufnr('%')
        let acc = []
        for [key, def] in s:ListValues()
            let list = eval(def.get)
            call filter(list, 'v:val.bufnr == bufnr && v:val.lnum == lnum')
            if !empty(list)
                let acc += list
            endif
        endfor
        " TLogVAR acc
        return join(map(acc, 'v:val.text'), "\n")
    endif
    if exists('b:quickfixsigns_balloonexpr') && !empty(b:quickfixsigns_balloonexpr)
        return eval(b:quickfixsigns_balloonexpr)
    else
        return ''
    endif
endf


function! s:GetCursor() "{{{3
    let pos = getpos('.')
    let s:cursor_last_line = pos[1]
    return [{'bufnr': bufnr('%'), 'lnum': pos[1], 'col': pos[2], 'text': 'Current line'}]
endf


function! s:ListValues() "{{{3
    return sort(items(g:quickfixsigns_lists), 's:CompareClasses')
endf


function! s:CompareClasses(a, b) "{{{3
    let i1 = get(a:a[1], 'level', 5)
    let i2 = get(a:b[1], 'level', 5)
    return i1 == i2 ? 0 : i1 < i2 ? 1 : -1
endf


function! s:RelSign(item) "{{{3
    return 'QFS_'. a:item.text
endf


function! s:GetRelList(class) "{{{3
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
    for ikey in ikeys
        let def = g:quickfixsigns_register[ikey]
        let bufnr = def.bufnr
        if bufnr(bufnr) != -1
            exec 'sign unplace '. def.id .' buffer='. bufnr
        endif
        call remove(g:quickfixsigns_register, ikey)
    endfor
endf


" Clear all signs with name SIGN in buffer BUFNR.
function! s:ClearBuffer(class, sign, bufnr, new_ikeys) "{{{3
    " TLogVAR a:class, a:sign, a:bufnr, a:new_ikeys
    let old_ikeys = keys(filter(copy(g:quickfixsigns_register), 'v:val.class ==# a:class && index(a:new_ikeys, v:key) == -1 && (s:Scope(a:class, v:val) == "vim" || v:val.bufnr == a:bufnr)'))
    " TLogVAR old_ikeys
    for ikey in old_ikeys
        let def = g:quickfixsigns_register[ikey]
        " TLogVAR def
        " echom "DBG sign unplace ". def.id .' buffer='. def.bufnr
        exec 'sign unplace '. def.id .' buffer='. def.bufnr
        call remove(g:quickfixsigns_register, ikey)
    endfor
endf


function! s:PruneRegister() "{{{3
    for [ikey, item] in items(g:quickfixsigns_register)
        if bufnr(item.bufnr) == -1
            call remove(g:quickfixsigns_register, ikey)
        endif
    endfor
endf


function! s:Scope(class, item) "{{{3
    if has_key(a:item, 'scope')
        let rv = a:item.scope
    else
        let rv = get(g:quickfixsigns_class_{a:class}, 'scope', 'buffer')
    endif
    " TLogVAR rv, a:class, a:item
    return rv
endf


function! s:SetItemId(item) "{{{3
    " TLogVAR a:item
    let bufnr = get(a:item, 'bufnr', -1)
    if bufnr == -1
        return -1
    else
        let scope = s:Scope(a:item.class, a:item)
        let sign = s:GetSign(g:quickfixsigns_class_{a:item.class}.sign, a:item)
        if has_key(a:item, 'ikey') && !empty(a:ikey.ikey)
            let ikey = a:item.ikey
        else
            let ikey = join([a:item.lnum, a:item.class, sign, bufnr], "\t")
        endif
        if has_key(g:quickfixsigns_register, ikey)
            let item = extend(copy(g:quickfixsigns_register[ikey]), a:item)
            let item.new = 0
        else
            let item = a:item
            let item.new = 1
        endif
        if !has_key(item, 'id') " || item.id == 0
            let item.id = s:quickfixsigns_base
            let s:quickfixsigns_base += 1
        endif
        let item.ikey = ikey
        let g:quickfixsigns_register[ikey] = item
        return item
    endif
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
    let new_ikeys = []
    for item in a:list
        let sign = s:GetSign(a:sign, item)
        let item = extend(item, {'class': a:class, 'sign': a:sign}, 'keep')
        " TLogVAR item
        let item = s:SetItemId(item)
        let ikey = item.ikey
        " TLogVAR ikey, item
        call add(new_ikeys, ikey)
        if item.new
            let lnum = get(item, 'lnum', 0)
            if lnum > 0
                let id = item.id
                " TLogVAR item
                " TLogDBG ':sign place '. id .' line='. lnum .' name='. sign .' buffer='. item.bufnr
                exec ':sign place '. id .' line='. lnum .' name='. sign .' buffer='. item.bufnr
            endif
        endif
    endfor
    return new_ikeys
endf


runtime! autoload/quickfixsigns/*.vim
call QuickfixsignsSelect(g:quickfixsigns_classes)
unlet s:signss


augroup QuickFixSigns
    autocmd!
    let s:ev_set = []
    for [s:key, s:def] in s:ListValues()
        for s:ev in get(s:def, 'event', ['BufEnter'])
            if index(s:ev_set, s:ev) == -1
                exec 'autocmd '. s:ev .' * call QuickfixsignsSet("'. s:ev .'")'
                call add(s:ev_set, s:ev)
            endif
        endfor
    endfor
    unlet s:ev_set
    if exists('s:key')
        unlet s:ev s:key s:def
    endif
    " autocmd BufRead,BufNewFile * exec 'sign place '. (s:quickfixsigns_base - 1) .' name=QFS_DUMMY line=1 buffer='. bufnr('%')
    autocmd User WokmarksChange if index(g:quickfixsigns_classes, 'marks') != -1 | call QuickfixsignsUpdate("marks") | endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
finish

CHANGES:
0.1
- Initial release

0.2
- exists('b:quickfixsigns_balloonexpr')

0.3
- Old signs weren't always removed
- Avoid "flicker" etc.
- g:quickfixsigns_max: Don't display signs if the list is longer than n items.
Incompatible changes:
- Removed g:quickfixsigns_show_marks variable
- g:quickfixsigns_marks: Marks that should be used for signs
- g:quickfixsigns_lists: event field is a list
- g:quickfixsigns_lists: timeout field: don't re-display this list more often than n seconds

0.4
- FIX: Error when g:quickfixsigns_marks = [] (thanks Ingo Karkat)
- s:ClearBuffer: removed old code
- QuickfixsignsMarks(state): Switch the display of marks on/off.

0.5
- Set balloonexpr only if empty (don't try to be smart)
- Disable CursorMoved(I) events, when &lazyredraw isn't set.

0.6
- Don't require qfl.item.text to be set

0.7
- b:noquickfixsigns: If true, disable quickfixsigns for the current 
buffer (patch by Sergey Khorev; must be set before entering a buffer)
- b:quickfixsigns_ignore_marks: A list of ignored marks (per buffer)

0.8
- Support for relative line numbers
- QuickfixsignsSet command
- quickfixsigns#RelNumbersOnce()

0.9
- Support for vcs diff (this requires either b:vcs_type or 
b:VCSCommandVCSType to be set to a supported vcs, e.g. git)

