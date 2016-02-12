" @Author:      Sergey Vlasov (sergey@vlasov.me)
" @git:         http://github.com/tomtom/quickfixsigns_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2016-02-12
" @Revision:    9


" :doc:
"                                                     *quickfixsigns-vcsmerge*
" Add signs for merge conflicts produced by VCS like Git.

if exists('g:quickfixsigns#vcsmerge#loaded')
    finish
endif
let g:quickfixsigns#vcsmerge#loaded = 1
scriptencoding utf-8


if index(g:quickfixsigns_classes, 'vcsmerge') == -1
    finish
endif


if !exists('g:quickfixsigns_class_vcsmerge')
    " VCS merge conflict markers.
    "
    " Users have to enable this sign class by adding 'vcsmerge' to
    " |g:quickfixsigns_classes|.
    let g:quickfixsigns_class_vcsmerge = {
                \ 'sign': '*quickfixsigns#vcsmerge#Signs',
                \ 'get': 'quickfixsigns#vcsmerge#GetList(%s)',
                \ 'event': ['BufRead', 'BufWritePost']
                \ }
endif


if !exists('g:quickfixsigns#vcsmerge#regex')
    " Expressions to match conflict hunks.
    let g:quickfixsigns#vcsmerge#regex = {'TOP': '^<<<<<<< \@=', 'MID': '^=======$', 'BOT': '^>>>>>>> \@='}   "{{{2
endif


if !exists('g:quickfixsigns#vcsmerge#sign')
    " Signs to mark conflict hunks.
    let g:quickfixsigns#vcsmerge#sign = {'TOP': '<<', 'MID': '==', 'BOT': '>>'}   "{{{2
endif


if index(g:quickfixsigns_signs, 'QFS_VCSMERGE_TOP') == -1
    exec 'sign define QFS_VCSMERGE_TOP text='.  g:quickfixsigns#vcsmerge#sign.TOP .' texthl=Error'
endif

if index(g:quickfixsigns_signs, 'QFS_VCSMERGE_MID') == -1
    exec 'sign define QFS_VCSMERGE_MID text='.  g:quickfixsigns#vcsmerge#sign.MID .' texthl=Error'
endif

if index(g:quickfixsigns_signs, 'QFS_VCSMERGE_BOT') == -1
    exec 'sign define QFS_VCSMERGE_BOT text='.  g:quickfixsigns#vcsmerge#sign.BOT .' texthl=Error'
endif


" :nodoc:
function! quickfixsigns#vcsmerge#Signs(item)
    return 'QFS_VCSMERGE_'. a:item.change
endf


" :nodoc:
function! quickfixsigns#vcsmerge#GetList(filename)
    let bufnr = bufnr('%')
    let signs = []
    if bufnr != bufnr(a:filename)
        if g:quickfixsigns_debug
            throw "QuickFixSigns DEBUG: bufnr mismatch:" a:filename bufnr bufnr(a:filename)
        endif
    else
        let pos = getpos('.')
        try
            exec 'silent g/'. g:quickfixsigns#vcsmerge#regex.TOP. '/ call add(signs, {"bufnr": bufnr, "lnum": line("."), "change": "TOP", "text": "Conflict top hunk"})'
            exec 'silent g/'. g:quickfixsigns#vcsmerge#regex.MID. '/ call add(signs, {"bufnr": bufnr, "lnum": line("."), "change": "MID", "text": "Conflict middle hunk"})'
            exec 'silent g/'. g:quickfixsigns#vcsmerge#regex.BOT. '/ call add(signs, {"bufnr": bufnr, "lnum": line("."), "change": "BOT", "text": "Conflict bottom hunk"})'
        finally
            call setpos('.', pos)
        endtry
    endif
    " TLogVAR signs
    return signs
endf

