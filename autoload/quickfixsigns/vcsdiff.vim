" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @vcs:         http://vcshub.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-05-08.
" @Last Change: 2010-11-11.
" @Revision:    174

if index(g:quickfixsigns_classes, 'vcsdiff') == -1
    finish
endif


if !exists('g:quickfixsigns_class_vcsdiff')
    let g:quickfixsigns_class_vcsdiff = {'sign': '*quickfixsigns#vcsdiff#Signs', 'get': 'quickfixsigns#vcsdiff#GetList()', 'event': ['BufEnter,BufWritePost']}   "{{{2
endif


" A dictionary of supported VCS names and command templates that 
" generate a unified diff file. "%s" is replaced with the filename.
" Supported vcs: git, hg, svn
" :read: let g:quickfixsigns#vcsdiff#cmds = {...} {{{2
let g:quickfixsigns#vcsdiff#cmds = {
            \ 'git': 'git diff -U0 %s',
            \ 'hg': 'hg diff -U0 %s',
            \ 'svn': 'svn diff -x -u %s',
            \ }


if !exists('g:quickfixsigns#vcsdiff#highlight')
    " The highlighting of deleted lines can sometimes be confusing. In 
    " order to disable the display of signs for DEL changes, save the 
    " following line as after/autoload/quickfixsigns/vcsdiff.vim: >
    "
    "   call remove(g:quickfixsigns#vcsdiff#highlight, 'DEL')
    let g:quickfixsigns#vcsdiff#highlight = {'DEL': 'DiffDelete', 'ADD': 'DiffAdd', 'CHANGE': 'DiffChange'}   "{{{2
endif


exec 'sign define QFS_VCS_ADD text=+ texthl='. g:quickfixsigns#vcsdiff#highlight.ADD
exec 'sign define QFS_VCS_DEL text=- texthl='. g:quickfixsigns#vcsdiff#highlight.DEL
exec 'sign define QFS_VCS_CHANGE text== texthl='. g:quickfixsigns#vcsdiff#highlight.CHANGE


" :nodoc:
function! quickfixsigns#vcsdiff#Signs(item) "{{{3
    return 'QFS_VCS_'. a:item.change
endf


" Return the name of a VCS system based on the values of the following 
" variables:
"   - b:vcs_type
"   - b:VCSCommandVCSType
function! quickfixsigns#vcsdiff#GuessType() "{{{3
    if exists('b:vcs_type')
        let type = b:vcs_type
    elseif exists('b:VCSCommandVCSType')
        " vcscommand
        let type = tolower(b:VCSCommandVCSType)
    elseif exists('b:git_dir')
        " fugitive
        let type = 'git'
    else
        let type = ''
    endif
    if has_key(g:quickfixsigns#vcsdiff#cmds, type)
        return type
    else
        return ''
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
            let change_defs = {}
            let from = 0
            let to = 0
            for line in lines
                " TLogVAR from, line
                if line =~ '^@@'
                    let m = matchlist(line, '^@@ -\(\d\+\)\(,\d\+\)\? +\(\d\+\)\(,\d\+\)\? @@')
                    " TLogVAR line, m
                    let to = m[3]
                    " let change_lnum = m[1]
                    let from = to
                elseif from == 0
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
                    if !empty(change) && has_key(change_defs, change_lnum)
                        if change_defs[change_lnum].change == 'CHANGE' || change_defs[change_lnum].change != change
                            let change = 'CHANGE'
                        endif
                        if has('balloon_multiline')
                            let text = change_defs[change_lnum].text ."\n". line
                        else
                            let text = line
                        endif
                    endif
                    let change_defs[change_lnum] = {'change': change, 'text': text}
                endif
            endfor
            let bufnr = bufnr('%')
            let signs = []
            for [lnum, change_def] in items(change_defs)
                if !has_key(g:quickfixsigns#vcsdiff#highlight, change_def.change)
                    continue
                endif
                if change_def.change == 'DEL' && lnum < line('$') && !has_key(change_defs, lnum + 1)
                    let lnum += 1
                endif
                if has('balloon_multiline')
                    let text = change_def.change .":\n". change_def.text
                else
                    let text = change_def.change .": ". change_def.text
                endif
                call add(signs, {"bufnr": bufnr, "lnum": lnum,
                            \ "change": change_def.change, "text": text})
            endfor
            " TLogVAR signs
            return signs
        endif
    endif
    return []
endf


