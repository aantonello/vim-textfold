" Special cases for C/C++ kind languages
" Mainteiner: Alessandro Antonello
" ----------------------------------------------------------------------------
vim9script

# -
# Check against file type.
# ----------------------------------------------------------------------------
export def IsCppKind(ftype: string): bool
  final types = ['java', 'kotlin', 'c', 'cpp']
  return index(types, ftype) >= 0
enddef

# -
# Remove trailing '{' character of folded functions. Add '...}' for classes
# and structures.
# ----------------------------------------------------------------------------
export def CompleteCppFold(textLine: string): string
  final lastIndex: number = (strlen(textLine) - 1)
  final severalLines: bool = ((v:foldend - v:foldstart) > 1)

  var tail: string = ''

  if (strridx(textLine, '{') == lastIndex)
    tail = severalLines ? ' ... }' : ' }'
  elseif (strridx(textLine, '(') == lastIndex)
    tail = severalLines ? ' ... )' : ')'
  endif

  return textLine .. tail
enddef

