" commentary.vim - Comment stuff out
" Modified by foodbag for fixed width commenting.
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.3
" GetLatestVimScripts: 3695 1 :AutoInstall: commentary.vim

if exists("g:loaded_commentary") || &cp || v:version < 700
  finish
endif
let g:loaded_commentary = 1
if !exists("g:commentary_fixed")
  let g:commentary_fixed = 0
endif
if !exists("g:commentary_fixed_pos")
  let g:commentary_fixed_pos=0
endif

function! s:surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(
        \ &commentstring, '\S\zs%s',' %s','') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:strip_white_space(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0 && a:line[strlen(a:line)-strlen(r[1:]):-1] == r[1:]
    return [l[0:-2], r[1:]]
  endif
  return [l, r]
endfunction

function! s:go(type,...) abort
  if a:0
    let [lnum1, lnum2] = [a:type, a:1]
  else
    let [lnum1, lnum2] = [line("'["), line("']")]
  endif

  let [l_, r_] = s:surroundings()
  let uncomment = 2
  for lnum in range(lnum1,lnum2)
    if g:commentary_fixed
      let line = getline(lnum)
      if line != '' && line[g:commentary_fixed_pos] == ' '
        let uncomment = 0
      endif
    else
      let line = matchstr(getline(lnum),'\S.*\s\@<!')
      let [l, r] = s:strip_white_space(l_,r_,line)
      if line != '' && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
        let uncomment = 0
      endif
    endif
  endfor

  for lnum in range(lnum1,lnum2)
    let line = getline(lnum)
    if g:commentary_fixed
      let r_f = &commentstring[:-3]
      let r_f_len = strlen(r_f)
      if uncomment
        if g:commentary_fixed_pos == 0
          let line = ' ' . line[g:commentary_fixed_pos+r_f_len:]
        else
          let line = line[0:g:commentary_fixed_pos-1] . ' ' . line[g:commentary_fixed_pos+r_f_len:]
        endif
      else
        if g:commentary_fixed_pos == 0
          let line = r_f . line[g:commentary_fixed_pos+1:]
        else
          let line = line[0:g:commentary_fixed_pos-1] . r_f . line[g:commentary_fixed_pos+1:]
        endif
      endif
    else
      if strlen(r) > 2 && l.r !~# '\\'
        let line = substitute(line,
              \'\M'.r[0:-2].'\zs\d\*\ze'.r[-1:-1].'\|'.l[0].'\zs\d\*\ze'.l[1:-1],
              \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
      endif
      if uncomment
        let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
      else
        let line = substitute(line,'^\%('.matchstr(getline(lnum1),'^\s*').'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
      endif
    endif
    call setline(lnum,line)
  endfor
  let modelines = &modelines
  try
    set modelines=0
    silent doautocmd User CommentaryPost
  finally
    let &modelines = modelines
  endtry
endfunction

function! s:textobject(inner) abort
  let [l_, r_] = s:surroundings()
  let [l, r] = [l_, r_]
  let lnums = [line('.')+1, line('.')-2]
  for [index, dir, bound, line] in [[0, -1, 1, ''], [1, 1, line('$'), '']]
    while lnums[index] != bound && line ==# '' || !(stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let lnums[index] += dir
      let line = matchstr(getline(lnums[index]+dir),'\S.*\s\@<!')
      let [l, r] = s:strip_white_space(l_,r_,line)
    endwhile
  endfor
  while (a:inner || lnums[1] != line('$')) && empty(getline(lnums[0]))
    let lnums[0] += 1
  endwhile
  while a:inner && empty(getline(lnums[1]))
    let lnums[1] -= 1
  endwhile
  if lnums[0] <= lnums[1]
    execute 'normal! 'lnums[0].'GV'.lnums[1].'G'
  endif
endfunction

xnoremap <silent> <Plug>Commentary     :<C-U>call <SID>go(line("'<"),line("'>"))<CR>
nnoremap <silent> <Plug>Commentary     :<C-U>set opfunc=<SID>go<CR>g@
nnoremap <silent> <Plug>CommentaryLine :<C-U>set opfunc=<SID>go<Bar>exe 'norm! 'v:count1.'g@_'<CR>
onoremap <silent> <Plug>Commentary        :<C-U>call <SID>textobject(0)<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call <SID>textobject(1)<CR>
nmap <silent> <Plug>CommentaryUndo <Plug>Commentary<Plug>Commentary
command! -range -bar Commentary call s:go(<line1>,<line2>)

if !hasmapto('<Plug>Commentary') || maparg('gc','n') ==# ''
  xmap gc  <Plug>Commentary
  nmap gc  <Plug>Commentary
  omap gc  <Plug>Commentary
  nmap gcc <Plug>CommentaryLine
  nmap cgc <Plug>ChangeCommentary
  nmap gcu <Plug>Commentary<Plug>Commentary
endif

" vim:set et sw=2:
