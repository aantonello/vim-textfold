" foldtext plugin
" Is a plugin to write better folded line texts.
" The goal is to bring something more useful than the Vim default.
" Also, it keeps indentation of the line as is, providing a better view of the
" text and understanding what is inside.
" Maintainer: Alessandro Antonello < aleantonello at hotmail dot com >
" ----------------------------------------------------------------------------
if get(g:, 'textfold_plugin_loaded', 0) || v:version < 900
  finish
endif
let g:textfold_plugin_loaded = v:true

import '../include/textfold.vim'

" ============================================================================
" Configuration
" ============================================================================

" List of filetypes where the text fold will be default.
" Or, in others words, where this plugin will be disabled.
" ----------------------------------------------------------------------------
if empty(get(g:, 'textfold_plugin_disabled_filetypes', []))
  let g:textfold_plugin_disabled_filetypes = ['help', 'qf', 'mail', 'man', 'gitcommit', 'changelog', 'nerdtree']
endif

" List of filetypes which syntax is similar of XML (a SGML kind)
" ----------------------------------------------------------------------------
if empty(get(g:, 'textfold_plugin_sgml_filetypes', []))
  let g:textfold_plugin_sgml_filetypes = ['html', 'xml', 'php', 'javascriptreact', 'typescriptreact']
endif

" How to format the 'lines folded' information.
" The information is placed at the right side of the window. The '%s' format
" specifier is where the number will be placed.
" ----------------------------------------------------------------------------
if len(get(g:, 'foldtext_plugin_lines_format', '')) == 0
  let g:foldtext_plugin_lines_format = ' [%s lines]'
endif

function FoldLine()
  if (getwinvar(0, '&diff'))
    return foldtext()
  endif

  " Build a dictionary with current options values. This method garantees that
  " the user can change its options at any time and the function will respect
  " that change.
  let options = {
        \ 'disabled': get(g:, 'textfold_plugin_disabled_filetypes', []),
        \ 'sgml':     get(g:, 'textfold_plugin_sgml_filetypes', []),
        \ 'suffix':   get(g:, 'foldtext_plugin_lines_format', get(b:, 'foldtext_plugin_lines_format', ''))
        \ }

  return textfold#FoldedText(options)
  "return s:textfold.FoldedText(options)
endfunction

