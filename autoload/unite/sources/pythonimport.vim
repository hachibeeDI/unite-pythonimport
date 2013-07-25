let s:save_cpo = &cpo
set cpo&vim

let s:pythonimport_source = {
\       'name': 'pythonimport',
\       'description': 'append import sentence for python modules',
\       'action_table': {
\             'import_module': {
\                 'description': 'append import xxx'
\               },
\             'from_module_import_target': {
\                 'description': 'append from xxx import xxx'
\               },
\           },
\       'default_action': 'import_module',
\       }

" 辞書変数のリストを返す関数
function! s:pythonimport_source.gather_candidates(args, context)
  let importable_list = s:get_module_sources()
  return map(
        \ importable_list,
        \ '{
        \   "word": v:val,
        \   "source": "pythonimport",
        \   "kind": "command",
        \   "action__module_name": v:val,
        \ }'
        \)
endfunction

" unite用のリストを作成する
function! s:get_module_sources()

  python <<EOM
from pydoc import ModuleScanner
from string import find

modules = []
modules_append = modules.append

def callback(path, modname, desc, modules=modules):
    if modname and modname[-9:] == '.__init__':
        modname = modname[:-9]
    if modname not in modules:
       modules.append(modname)

def onerror(modname):
    callback(None, modname, None)

ModuleScanner().run(callback, onerror=onerror)

vim.command('let l:modules = {0}'.format(modules))
EOM

  return l:modules
endfunction


function! s:pythonimport_source.action_table.import_module.func(candidate)
  let module_name = printf('"%s"', a:candidate.action__module_name)
  call s:pythonimport(module_name)
endfunction


function! s:pythonimport_source.action_table.from_module_import_target.func(candidate)
  let module_name = printf('"%s"', a:candidate.action__module_name)
  call s:python_from_import(module_name)
endfunction


function! unite#sources#pythonimport#define()
  return has('python') ? s:pythonimport_source : []
endfunction



" TODO: action用関数. 別ファイルから呼ぶ方法とかわかったら別ファイルに
" TODO: pos調整を高階関数とかで綺麗にする
function! s:pythonimport(x)
  let pos = getpos('.')
  let y = split(eval(a:x), ' ')
  let modulename = y[0]

  let line = printf("import %s", modulename)
  let newpos = search('^import', 'b')
  if newpos == 0
    " 1:magic -> 2:empty line -> 3:modules
    call cursor(1, 3)
  else
    call cursor(newpos)
    call cursor(search('^[^ ]\|^$'))
  endif
  call append(getpos('.')[1] - 1, line)

  call setpos('.', pos)
endfunction


function! s:python_from_import(x)
  let pos = getpos('.')
  let y = split(eval(a:x), ' ')
  let modulename = y[0]

  "let l:module_par_path = split(l:module, '\.')
  " NOTE: ここで補完候補にモジュールなりクラスなりを出してやるとか
  let target_module = input('target: ')
  let line = printf("from %s import %s", modulename, target_module)
  let newpos = search('^from', 'b')
  if newpos == 0
    " 1:magic -> 2:empty line -> 3:modules
    call cursor(1, 3)
  else
    call cursor(newpos)
    call cursor(search('^[^ ]\|^$'))
  endif
  call append(getpos('.')[1] - 1, line)

  call setpos('.', pos)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
