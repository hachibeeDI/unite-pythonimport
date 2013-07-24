let s:save_cpo = &cpo
set cpo&vim

let s:pythonimport_source = {
\       'name': 'pythonimport',
\       }

" 辞書変数のリストを返す関数
function! s:pythonimport_source.gather_candidates(args, context)
  let importable_list = Pythonimport_define()
  return map(
        \ importable_list,
        \ '{
        \   "word": v:val,
        \   "source": "pythonimport",
        \   "kind": "command",
        \   "action__command": printf("silent Pythonimport \"%s\"", v:val),
        \ }'
        \)
endfunction

" unite用のリストを作成する
function! Pythonimport_define()

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

vim.command('let modules = {0}'.format(modules))
EOM

  return modules
endfunction


function! unite#sources#pythonimport#define()
  " TODO: +python有効か調べるやつ
  return s:pythonimport_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo