" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @git:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-05-08.
" @Last Change: 2012-10-02.
" @Revision:    492

if exists('g:quickfixsigns#vcsdiff#loaded')
    finish
endif
let g:quickfixsigns#vcsdiff#loaded = 1
scriptencoding utf-8


if index(g:quickfixsigns_classes, 'vcsdiff') == -1
    finish
endif


if !exists('g:quickfixsigns#vcsdiff#vcs')
    " Show signs for new (+), changed (=), or deleted (-) lines.
    "
    " The signs for deleted lines are shown on the line before the 
    " deleted one. I.e. if line 20 was deleted, the "-" sign will be put 
    " on line 19.
    "
    " A dictionary of supported VCS names. Its values are dictionaries 
    " with the following keys:
    "     cmd ... command templates that generate a unified diff file. 
    "     "%s" is replaced with the filename.
    "     dir ... the directory name
    " Currently supported vcs: git, hg, svn, bzr
    " :read: let g:quickfixsigns#vcsdiff#vcs = {...}  "{{{2
    let g:quickfixsigns#vcsdiff#vcs = {
                \ 'git': {'cmd': 'git diff --no-ext-diff -U0 %s', 'dir': '.git'}
                \ , 'hg': {'cmd': 'hg diff -U0 %s', 'dir': '.hg'}
                \ , 'svn': {'cmd': 'svn diff --diff-cmd diff --extensions -U0 %s', 'dir': '.svn'}
                \ , 'bzr': {'cmd': 'bzr diff --diff-options=-U0 %s', 'dir': '.bzr'}
                \ }
endif


if !exists('g:quickfixsigns_class_vcsdiff')
    let g:quickfixsigns_class_vcsdiff = {'sign': '*quickfixsigns#vcsdiff#Signs', 'get': 'quickfixsigns#vcsdiff#GetList(%s)', 'event': ['BufRead', 'BufWritePost'], 'level': 6}   "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#cd')
    let g:quickfixsigns#vcsdiff#cd = 'cd'   "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#cmd_separator')
    " Command to join two shell commands.
    let g:quickfixsigns#vcsdiff#cmd_separator = '&&'  "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#guess_type')
    " If true, guess the vcs type by searching for the repo directory on 
    " the hard disk (i.e., this will result in disk accesses for new 
    " buffers).
    " Can also be buffer-local.
    let g:quickfixsigns#vcsdiff#guess_type = 1   "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#list_type')
    " Defines how changed lines are displayed. Must be one of:
    "   0 ... QuickFixSigns's original version
    "   1 ... An alternative version that works more like `diff -y` (see 
    "         |quickfixsigns#vcsdiff#GetList1()|)
    let g:quickfixsigns#vcsdiff#list_type = 1   "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#highlight')
    " The highlighting of deleted lines can sometimes be confusing. In 
    " order to disable the display of signs for DEL changes, save the 
    " following line as after/autoload/quickfixsigns/vcsdiff.vim: >
    "
    "   call remove(g:quickfixsigns#vcsdiff#highlight, 'DEL')
    let g:quickfixsigns#vcsdiff#highlight = {'DEL': 'QuickFixSignsDiffDelete', 'ADD': 'QuickFixSignsDiffAdd', 'CHANGE': 'QuickFixSignsDiffChange'}   "{{{2
endif


if !exists('g:quickfixsigns#vcsdiff#del_numbered')
    " If true, add an indicator for how many lines were deleted next to 
    " the sign for deleted lines.
    let g:quickfixsigns#vcsdiff#del_numbered = 1   "{{{2
endif


if len(filter(values(g:quickfixsigns#vcsdiff#highlight), 'v:val =~ ''^QuickFixSignsDiff''')) > 0
    hi QuickFixSignsDiffAdd    ctermfg=0 ctermbg=2 guifg=black  guibg=green
    hi QuickFixSignsDiffDelete ctermfg=0 ctermbg=1 guifg=yellow guibg=red
    hi QuickFixSignsDiffChange ctermfg=0 ctermbg=3 guifg=black  guibg=yellow
endif


if index(g:quickfixsigns_signs, 'QFS_VCS_ADD') == -1
    exec 'sign define QFS_VCS_ADD text=+ texthl='. g:quickfixsigns#vcsdiff#highlight.ADD
endif
if index(g:quickfixsigns_signs, 'QFS_VCS_DEL') == -1
    exec 'sign define QFS_VCS_DEL text=- texthl='. g:quickfixsigns#vcsdiff#highlight.DEL
endif
if index(g:quickfixsigns_signs, 'QFS_VCS_CHANGE') == -1
    exec 'sign define QFS_VCS_CHANGE text== texthl='. g:quickfixsigns#vcsdiff#highlight.CHANGE
endif


if g:quickfixsigns#vcsdiff#del_numbered
    for s:i in range(1, 9) + ['M']
        if !has_key(g:quickfixsigns#vcsdiff#highlight, 'DEL'. s:i) && has_key(g:quickfixsigns#vcsdiff#highlight, 'DEL')
            let g:quickfixsigns#vcsdiff#highlight['DEL'. s:i] = g:quickfixsigns#vcsdiff#highlight.DEL
        endif
        if index(g:quickfixsigns_signs, 'QFS_VCS_DEL'. s:i) == -1
            let s:text = s:i == 'M' ? '-' : s:i
            exec 'sign define QFS_VCS_DEL'. s:i 'text=-'. s:text 'texthl='. g:quickfixsigns#vcsdiff#highlight.DEL
        endif
        unlet! s:i s:text
    endfor
endif


" :nodoc:
function! quickfixsigns#vcsdiff#Signs(item) "{{{3
    return 'QFS_VCS_'. a:item.change
endf


" Return the name of a VCS system based on the values of the following 
" variables:
"
"   - b:git_dir
"   - b:vcs_type
"   - b:VCSCommandVCSType
"
" If none of these variables is defined, try to guess the vcs type.
function! quickfixsigns#vcsdiff#GuessType() "{{{3
    if exists('b:vcs_type')
        let type = b:vcs_type
    else
        if exists('b:VCSCommandVCSType')
            " vcscommand
            let type = tolower(b:VCSCommandVCSType)
        elseif exists('b:git_dir')
            " fugitive
            let type = 'git'
        else
            let type = ''
        endif
        " TLogVAR type
        if (exists('b:quickfixsigns#vcsdiff#guess_type') ? b:quickfixsigns#vcsdiff#guess_type : g:quickfixsigns#vcsdiff#guess_type) && empty(type)
            let path = escape(expand('%:p:h'), ',') .';'
            let depth = -1
            for vcs in keys(g:quickfixsigns#vcsdiff#vcs)
                let dir = g:quickfixsigns#vcsdiff#vcs[vcs].dir
                " TLogVAR dir
                let vcsdir = finddir(dir, path)
                if !empty(vcsdir)
                    let vcsdir_depth = len(split(fnamemodify(vcsdir, ':p'), '\/'))
                    if vcsdir_depth > depth
                        let depth = vcsdir_depth
                        let type = vcs
                        " TLogVAR type, depth
                    endif
                endif
            endfor
        endif
        let b:vcs_type = type
    endif
    " TLogVAR type
    if has_key(g:quickfixsigns#vcsdiff#vcs, type)
        return type
    else
        return ''
    endif
endf


function! quickfixsigns#vcsdiff#GetList(filename) "{{{3
    if !(type(g:quickfixsigns#vcsdiff#list_type) == 0 && g:quickfixsigns#vcsdiff#list_type >= 0 && g:quickfixsigns#vcsdiff#list_type <= 1)
        throw "Quickfixsigns: g:quickfixsigns#vcsdiff#list_type must be 0 or 1 but was ".   g:quickfixsigns#vcsdiff#list_type
    endif
    return quickfixsigns#vcsdiff#GetList{g:quickfixsigns#vcsdiff#list_type}(a:filename)
endf


" quickfixsigns#vcsdiff#GuessType() must return the name of a supported 
" VCS (see |g:quickfixsigns#vcsdiff#vcs|).
function! quickfixsigns#vcsdiff#GetList0(filename) "{{{3
    if &buftype =~ '\<\(nofile\|quickfix\|help\)\>' || &previewwindow || exists('b:fugitive_type')
        return []
    endif
    let vcs_type = quickfixsigns#vcsdiff#GuessType()
    " TLogVAR a:filename, vcs_type
    " Ignore files that are not readable
    if has_key(g:quickfixsigns#vcsdiff#vcs, vcs_type) && filereadable(a:filename)
        let cmdt = g:quickfixsigns#vcsdiff#vcs[vcs_type].cmd
        let dir  = fnamemodify(a:filename, ':h')
        let file = fnamemodify(a:filename, ':t')
        let cmds = join([
                    \ printf("%s %s", g:quickfixsigns#vcsdiff#cd, shellescape(dir)),
                    \ printf(cmdt, shellescape(file))
                    \ ], g:quickfixsigns#vcsdiff#cmd_separator)
        " TLogVAR cmds
        let diff = system(cmds)
        " TLogVAR diff
        let bufnr = bufnr('%')
        let bufdiff = exists('b:quickfixsigns_vcsdiff') ? b:quickfixsigns_vcsdiff : ''
        if !empty(diff)
            if diff != bufdiff || !exists('b:quickfixsigns_vcsdiff_signs')
                let b:quickfixsigns_vcsdiff = diff
                if g:quickfixsigns_debug && bufnr != bufnr(a:filename)
                    echom "QuickFixSigns DEBUG: bufnr mismatch:" a:filename bufnr bufnr(a:filename)
                endif
                let lastlnum = line('$')
                let lines = split(diff, '\n')
                let change_defs = {}
                let from = -1
                let to = -1
                let last_change_lnum = 0
                let last_del = 0
                for line in lines
                    if line =~ '^@@\s'
                        let m = matchlist(line, '^@@ -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@')
                        " TLogVAR line, m
                        let to = str2nr(m[3])
                        " TLogVAR "@@", to
                        " let change_lnum = m[1]
                        let from = to
                    elseif line =~ '^@@@\s'
                        let m = matchlist(line, '^@@@ -\(\d\+\)\(,\d\+\)\? -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@@')
                        " TLogVAR line, m
                        let to = str2nr(m[5])
                        " TLogVAR "@@@", to
                        " let change_lnum = m[1]
                        let from = to
                    elseif from < 0
                        continue
                    else
                        if line[0] == '-'
                            let change = 'DEL'
                            let text = line
                            let change_lnum = from
                            let from += 1
                        elseif line[0] == '+'
                            let change = 'ADD'
                            let text = line
                            let change_lnum = to
                            let to += 1
                        else
                            let from += 1
                            let to += 1
                            let change = ''
                            continue
                        endif
                        " TLogVAR change_lnum, change
                        if change_lnum < 1
                            let change_lnum = 1
                        elseif change_lnum > lastlnum
                            let change_lnum = lastlnum
                        endif
                        if !empty(change) && has_key(change_defs, change_lnum)
                            if change_defs[change_lnum].change == 'CHANGE' || change_defs[change_lnum].change != change
                                let change = 'CHANGE'
                            endif
                            let text = s:BalloonJoin(change_defs[change_lnum].text, line)
                        endif
                        if last_change_lnum > 0 && last_del > 0 && change_lnum == last_del + 1 && change == 'DEL' && change_defs[last_change_lnum].change == 'DEL'
                            let change_defs[last_change_lnum].text = s:BalloonJoin(change_defs[last_change_lnum].text, text)
                        else
                            let change_defs[change_lnum] = {'change': change, 'text': text}
                            let last_change_lnum = change_lnum
                        endif
                        if change == 'DEL' || change == 'CHANGE'
                            let last_del = change_lnum
                        endif
                    endif
                endfor
                let signs = []
                " TLogVAR change_defs
                for [lnum, change_def] in items(change_defs)
                    if !has_key(g:quickfixsigns#vcsdiff#highlight, change_def.change)
                        continue
                    endif
                    " if change_def.change == 'DEL' && lnum < line('$') && !has_key(change_defs, lnum + 1)
                    "     let lnum += 1
                    " endif
                    let text = s:BalloonJoin(change_def.change .":", change_def.text)
                    " TLogVAR bufnr, lnum, change_def.change, text
                    call add(signs, {"bufnr": bufnr, "lnum": lnum,
                                \ "change": change_def.change, "text": text})
                endfor
                " TLogVAR signs
                let b:quickfixsigns_vcsdiff_signs = copy(signs)
                return signs
            else
                return copy(b:quickfixsigns_vcsdiff_signs)
            endif
        endif
    endif
    return []
endf


" quickfixsigns#vcsdiff#GuessType() must return the name of a supported 
" VCS (see |g:quickfixsigns#vcsdiff#vcs|).
" This version by Chronial works more like diff -y (see 
" https://github.com/Chronial/vim-quickfixsigns/commit/1cf739c790746157c3cb9b6234c1454333397c9e 
" for details).
function! quickfixsigns#vcsdiff#GetList1(filename) "{{{3
    if &buftype =~ '\<\(nofile\|quickfix\|help\)\>' || &previewwindow || exists('b:fugitive_type')
        return []
    endif
    let vcs_type = quickfixsigns#vcsdiff#GuessType()
    " TLogVAR a:filename, vcs_type
    " Ignore files that are not readable
    if has_key(g:quickfixsigns#vcsdiff#vcs, vcs_type) && filereadable(a:filename)
        let cmdt = g:quickfixsigns#vcsdiff#vcs[vcs_type].cmd
        let dir  = fnamemodify(a:filename, ':h')
        let file = fnamemodify(a:filename, ':t')
        let cmds = join([
                    \ printf("%s %s", g:quickfixsigns#vcsdiff#cd, shellescape(dir)),
                    \ printf(cmdt, shellescape(file))
                    \ ], g:quickfixsigns#vcsdiff#cmd_separator)
        " TLogVAR cmds
        let diff = system(cmds)
        " TLogVAR diff
        let bufnr = bufnr('%')
        let bufdiff = exists('b:quickfixsigns_vcsdiff') ? b:quickfixsigns_vcsdiff : ''
        if !empty(diff)
            if diff != bufdiff || !exists('b:quickfixsigns_vcsdiff_signs')
                let b:quickfixsigns_vcsdiff = diff
                if g:quickfixsigns_debug && bufnr != bufnr(a:filename)
                    echom "QuickFixSigns DEBUG: bufnr mismatch:" a:filename bufnr bufnr(a:filename)
                endif
                let lastlnum = line('$')
                let lines = split(diff, '\n')
                let change_defs = {}
                let from = -1
                let to = -1
                let block_start = -1
                let block_text = ""
                for line in lines
                    if line =~ '^@'
                        if line =~ '^@@\s'
                            let m = matchlist(line, '^@@ -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@')
                            let to = str2nr(m[3])
                            " TLogVAR "@@", to
                        elseif line =~ '^@@@\s'
                            let m = matchlist(line, '^@@@ -\(\d\+\)\(,\d\+\)\? -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@@')
                            let to = str2nr(m[5])
                            " TLogVAR "@@@", to
                        endif
                        " TLogVAR line, m
                        let from = to
                        let block_start = to
                        let block_text = m[0]
                    elseif from < 0
                        continue
                    else
                        " Note: This algorithm assumes that all the deletions
                        " per hunk will come before the insertions
                        if line[0] == '-'
                            let change = 'DEL'
                            let block_text = s:BalloonJoin(block_text, line)
                            let change_lnum = from
                            let from += 1
                        elseif line[0] == '+'
                            let change = to > from - 1 ? 'ADD' : 'CHANGE'
                            let change_lnum = to
                            let to += 1
                        else
                            let from += 1
                            let to += 1
                            let change = ''
                            continue
                        endif
                        " TLogVAR change_lnum, change
                        if change_lnum < 1
                            let change_lnum = 1
                        elseif change_lnum > lastlnum
                            let change_lnum = lastlnum
                        endif
                        if change == 'DEL'
                            if g:quickfixsigns#vcsdiff#del_numbered
                                let ldiff = from - block_start
                                " TLogVAR block_start, from, to, ldiff
                                if ldiff < 1
                                    let change = 'DEL'
                                elseif ldiff > 9
                                    let change = 'DELM'
                                else
                                    let change = 'DEL'. ldiff
                                endif
                            endif
                            let change_defs[block_start] = {'change': change, 'text': block_text}
                            " TLogVAR block_start, change_defs[block_start], ldiff
                        else
                            let change_defs[change_lnum] = {'change': change, 'text': block_text}
                            " TLogVAR change_lnum, change_defs[change_lnum]
                            let last_change_lnum = change_lnum
                        endif
                    endif
                endfor
                let signs = []
                for [lnum, change_def] in items(change_defs)
                    if !has_key(g:quickfixsigns#vcsdiff#highlight, change_def.change)
                        continue
                    endif
                    " if change_def.change == 'DEL' && lnum < line('$') && !has_key(change_defs, lnum + 1)
                    "     let lnum += 1
                    " endif
                    " TLogVAR bufnr, lnum, change_def.change, change_def.text
                    call add(signs, {"bufnr": bufnr, "lnum": lnum,
                                \ "change": change_def.change, "text": change_def.text})
                endfor
                " TLogVAR signs
                let b:quickfixsigns_vcsdiff_signs = copy(signs)
                return signs
            else
                return copy(b:quickfixsigns_vcsdiff_signs)
            endif
        endif
    endif
    return []
endf


function! s:BalloonJoin(...) "{{{3
    if has('balloon_multiline')
        return join(a:000, "\n")
    else
        return join(a:000, " ")
    endif
endf

