
" 使うコマンド
command! Pythonimport call s:pythonimport(<q-args>)

function! s:pythonimport(x)
  let pos = getpos('.')
  let y = split(eval(a:x), ' ')
  let a:module = y[0]

  let line = printf("import %s", a:module)
  let newpos = search('^import', 'b')
  if newpos == 0
    call cursor(1, 3) " magic -> empty line -> modules
  else
    call cursor(newpos)
    call cursor(search('^[^ ]\|^$'))
  endif
  call append(getpos('.')[1] - 1, line)

  call setpos('.', pos)

endfunction

