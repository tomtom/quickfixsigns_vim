" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @vcs:         http://vcshub.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-05-08.
" @Last Change: 2010-05-09.
" @Revision:    90

if index(g:quickfixsigns_classes, 'vcsdiff') == -1
    finish
endif


if !exists('g:quickfixsigns_class_vcsdiff')
    let g:quickfixsigns_class_vcsdiff = {'sign': '*quickfixsigns#vcsdiff#Signs', 'get': 'quickfixsigns#vcsdiff#GetList()', 'event': ['BufEnter,BufWritePost']}   "{{{2
endif


" A dictionary of supported VCS names and command templates that 
" generate a unified diff file. "%s" is replaced with the filename.
" Currently only git is supported.
" :read: let g:quickfixsigns#vcsdiff#cmds = {...} {{{2
let g:quickfixsigns#vcsdiff#cmds = {
            \ 'git': 'git diff -U0 %s',
            \ }


if !exists('g:quickfixsigns#vcsdiff#highlight')
    let g:quickfixsigns#vcsdiff#highlight = {'DEL': 'DiffDelete', 'ADD': 'DiffAdd', 'CHANGE': 'DiffChange'}   "{{{2
endif


exec 'sign define QFS_VCS_ADD text=+ texthl='. g:quickfixsigns#vcsdiff#highlight.ADD
exec 'sign define QFS_VCS_DEL text=- texthl='. g:quickfixsigns#vcsdiff#highlight.DEL
exec 'sign define QFS_VCS_CHANGE text== texthl='. g:quickfixsigns#vcsdiff#highlight.CHANGE


function! quickfixsigns#vcsdiff#Signs(item) "{{{3
    return 'QFS_VCS_'. a:item.text
endf


" Return the name of a VCS system based on the values of the following 
" variables:
"   - b:vcs_type
"   - b:VCSCommandVCSType
function! quickfixsigns#vcsdiff#GuessType() "{{{3
    if exists('b:vcs_type')
        return b:vcs_type
    elseif exists('b:VCSCommandVCSType')
        return b:VCSCommandVCSType
    endif
endf


" quickfixsigns#vcsdiff#GuessType() must return the name of a supported 
" VCS (see |g:quickfixsigns#vcsdiff#cmds|).
function! quickfixsigns#vcsdiff#GetList() "{{{3
    let vcs_type = quickfixsigns#vcsdiff#GuessType()
    if has_key(g:quickfixsigns#vcsdiff#cmds, vcs_type)
        let cmdt = g:quickfixsigns#vcsdiff#cmds[vcs_type]
        let cmds = printf(cmdt, shellescape(expand('%')))
        let diff = system(cmds)
        " TLogVAR diff
        if !empty(diff)
            let lines = split(diff, '\n')
            let changes = {}
            let from = 0
            let to = 0
            for line in lines
                " TLogVAR from, line
                if line =~ '^@@'
                    let m = matchlist(line, '^@@ -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@')
                    " TLogVAR line, m
                    let to = m[3]
                    " let from = m[1]
                    let from = to
                elseif from == 0
                    continue
                else
                    if line[0] == '-'
                        let change = 'DEL'
                        let change_lnum = from
                        let from += 1
                    elseif line[0] == '+'
                        let change = 'ADD'
                        let change_lnum = to
                        let to += 1
                    else
                        let from += 1
                        let to += 1
                    endif
                    " TLogVAR change_lnum, change
                    if has_key(changes, change_lnum)
                        let changes[change_lnum] = 'CHANGE'
                    else
                        let changes[change_lnum] = change
                    endif
                endif
            endfor
            let bnum = bufnr('%')
            let signs = []
            for [lnum, change] in items(changes)
                if change != 'DEL'
                    call add(signs, {"bufnr": bnum, "lnum": lnum, "text": change})
                endif
            endfor
            " TLogVAR signs
            return signs
        endif
    endif
    return []
endf


