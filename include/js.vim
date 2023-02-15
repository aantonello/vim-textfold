" Special cases for Javascript and Typescript files.
" Maintainer: Alessandro Antonello
" ----------------------------------------------------------------------------
vim9script

# -
#  Checks against the file type.
# ----------------------------------------------------------------------------
export def IsJSKind(ftype: string): bool
  final types = ['javascript', 'typescript', 'js', 'ts', 'javascriptreact', 'typescriptreact']
  return index(types, ftype) >= 0
enddef

# -
#  Add the ending for an opening 'import' statement.
# ----------------------------------------------------------------------------
export def CompleteCloseImport(textLine: string): string
  if textLine =~# '^\s*import\s\+{.*$'
    var lastLine = getline(v:foldend)
    if stridx(lastLine, '}') > 0    # We have some keywords on last line.
      return textLine .. ' ... ' .. lastLine
    elseif stridx(textLine, '{') == (strlen(textLine) - 1)
      const included = getline(v:foldstart + 1)
      return textLine .. trim(included) .. ' ... ' .. lastLine
    endif
    return textLine .. ' ... ' .. lastLine
  endif
  return textLine
enddef

