" Special cases for C/C++ kind languages
" Mainteiner: Alessandro Antonello
" ----------------------------------------------------------------------------
vim9script

# -
# Check against file type.
# ----------------------------------------------------------------------------
export def IsCppKind(ftype: string): bool
  final types = ['java', 'kotlin', 'c', 'cpp', 'swift', 'dart']
  return index(types, ftype) >= 0
enddef

# -
# Remove trailing '{' character of folded functions. Add '...}' for classes,
# structures, functions, etc...
# ----------------------------------------------------------------------------
export def CompleteCppFold(textLine: string): string
  final lastIndex: number = (strlen(textLine) - 1)
  final severalLines: bool = ((v:foldend - v:foldstart) > 1)

  var tail: string = ''

  if (strridx(textLine, '{') == lastIndex)
    # Check if we have an open parenthesys before the opened brace that wasn't
    # closed. Do the same for an opened bracket.
    final lastOpenParen = strridx(textLine, '(', (lastIndex - 1))
    final lastCloseParen = strridx(textLine, ')', (lastIndex - 1))
    final lastOpenBracket = strridx(textLine, '[', (lastIndex - 1))
    final lastCloseBracket = strridx(textLine, ']', (lastIndex - 1))

    if (lastOpenParen > lastCloseParen)
      tail = severalLines ? ' ... })' : ' })'
    elseif (lastOpenBracket > lastCloseBracket)
      tail = severalLines ? ' ... }]' : ' }]'
    else
      tail = severalLines ? ' ... }' : ' }'
    endif
  elseif (strridx(textLine, '(') == lastIndex)
    # Check if we start another fold in the same line where this fold ends.
    final lastTextLine = getline(v:foldend)
    if (strridx(lastTextLine, '{') == (strlen(lastTextLine) - 1))
      tail = severalLines ? ' ... ) { }' : ') { }'
    else
      tail = severalLines ? ' ... )' : ')'
    endif
  endif

  return textLine .. tail
enddef

