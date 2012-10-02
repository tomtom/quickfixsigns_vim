" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    0.0.21

if !exists('g:tinykeymap#map#quickfixsigns#map')
    let g:tinykeymap#map#quickfixsigns#map = g:tinykeymap#mapleader .'s'   "{{{2
endif

if !exists('g:tinykeymap#map#quickfixsigns#options')
    " :read: let g:tinykeymap#map#quickfixsigns#options = {...}   "{{{2
    let g:tinykeymap#map#quickfixsigns#options = {
                \ 'name': 'Go to sign',
                \ 'start': 'let g:tinykeymap#map#quickfixsigns#pattern = ""',
                \ 'stop': 'unlet! g:tinykeymap#map#quickfixsigns#pattern',
                \ }
    if exists('g:loaded_tlib')
        let g:tinykeymap#map#quickfixsigns#options.after = 'call tlib#buffer#ViewLine(line("."))'
        let g:tinykeymap#map#quickfixsigns#options.start .= '|call tlib#buffer#ViewLine(line("."))'
    else
        let g:tinykeymap#map#quickfixsigns#options.after = 'norm! zz'
    endif
endif

call tinykeymap#EnterMap("quickfixsigns", g:tinykeymap#map#quickfixsigns#map, g:tinykeymap#map#quickfixsigns#options)
call tinykeymap#Map("quickfixsigns", "j", "call quickfixsigns#MoveSigns(<count1>, g:tinykeymap#map#quickfixsigns#pattern)",
            \ {'desc': 'Move to the next sign'})
call tinykeymap#Map("quickfixsigns", "k",
            \ "call quickfixsigns#MoveSigns(-<count1>, g:tinykeymap#map#quickfixsigns#pattern)",
            \ {'desc': 'Move to the previous sign'})
call tinykeymap#Map("quickfixsigns", "l",
            \ "call quickfixsigns#MoveSigns(<count1>, g:tinykeymap#map#quickfixsigns#pattern, 1)",
            \ {'desc': 'Move to the next group of signs'})
call tinykeymap#Map("quickfixsigns", "h",
            \ "call quickfixsigns#MoveSigns(-<count1>, g:tinykeymap#map#quickfixsigns#pattern, 1)",
            \ {'desc': 'Move to the previous group of signs'})
call tinykeymap#Map("quickfixsigns", "<Down>",
            \ "call quickfixsigns#MoveSigns(<count1>, g:tinykeymap#map#quickfixsigns#pattern)",
            \ {'desc': 'Move to the next sign'})
call tinykeymap#Map("quickfixsigns", "<Up>",
            \ "call quickfixsigns#MoveSigns(-<count1>, g:tinykeymap#map#quickfixsigns#pattern)",
            \ {'desc': 'Move to the previous sign'})
call tinykeymap#Map("quickfixsigns", "<Right>",
            \ "call quickfixsigns#MoveSigns(<count1>, g:tinykeymap#map#quickfixsigns#pattern, 1)",
            \ {'desc': 'Move to the next group of signs'})
call tinykeymap#Map("quickfixsigns", "<Left>",
            \ "call quickfixsigns#MoveSigns(-<count1>, g:tinykeymap#map#quickfixsigns#pattern, 1)",
            \ {'desc': 'Move to the previous group of signs'})
call tinykeymap#Map("quickfixsigns", "<Space>",
            \ "let g:tinykeymap#map#quickfixsigns#pattern = input('Sign Regexp: ', g:tinykeymap#map#quickfixsigns#pattern, 'custom,quickfixsigns#CompleteSigns')",
            \ {'desc': 'Edit the sign regexp filter'})

