vim9script noclean
# foldtext plugin
# Is a plugin to write better folded line texts.
# The goal is to bring something more useful than the Vim default.
# Also, it keeps indentation of the line as is, providing a better view of the
# text and understanding what is inside.
# Maintainer: Alessandro Antonello < aleantonello at hotmail dot com >
# ----------------------------------------------------------------------------
if get(g:, 'textfold_plugin_loaded', 0)
  finish
endif
let g:textfold_plugin_loaded = v:true

# ============================================================================
# Configuration
# ============================================================================

# List of filetypes where the text fold will be default.
# Or, in others words, where this plugin will be disabled.
# ----------------------------------------------------------------------------
if empty(get(g:, 'textfold_plugin_disabled_filetypes', []))
  let g:textfold_plugin_disabled_filetypes = ['help', 'qf', 'mail', 'man', 'gitcommit', 'changelog', 'nerdtree']
endif

# List of filetypes which syntax is similar of XML (a SGML kind)
# ----------------------------------------------------------------------------
if empty(get(g:, 'textfold_plugin_sgml_filetypes', []))
  let g:textfold_plugin_sgml_filetypes = ['html', 'xml', 'php', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact']
endif

# Suffix to be used in the number of lines folded.
# E.g.: '[ 23 lines]'
# ----------------------------------------------------------------------------
if len(get(g:, 'foldtext_plugin_lines_suffix', '')) == 0
  let g:foldtext_plugin_lines_suffix = 'lines'
endif

# The number of lines is printed inside square brackets. To change that, add
# the first and end characters in the array. If no enclosing characters are
# needed, use empty strings.
# ----------------------------------------------------------------------------
if empty(get(g:, 'foldtext_plugin_lines_brackets', []))
  let g:foldtext_plugin_lines_brackets = ['[', ']']
endif

import autoload '../autoload/textfold.vim'

set foldtext=textfold#BuildFoldedText()

