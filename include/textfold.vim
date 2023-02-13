" Functions to build useful folded text lines.
" Maintainer: Alessandro Antonello <antonello dot ale @ gmail dot com>
" ============================================================================
vim9script

const version = '1.0.2'

# ----------------------------------------------------------------------------
# Local functions
# ----------------------------------------------------------------------------

# Check if the current buffer has a disabled filetype.
# ----------------------------------------------------------------------------
def IsDisabled(ftype: string, config: list<string>): bool
  if empty(config) || (index(ftype, config) < 0)
    return false
  endif
  return true
enddef

# Check whether the current filetype is SGML kind.
# ----------------------------------------------------------------------------
def IsSgmlKind(ftype: string, config: list<string>, line: string): bool
  # If the filetype is in the SGML configuration list and the folded line
  # starts with an angled bracket.
  return ((index(ftype, config) >= 0) && line =~? '^\s*<\w\+.*') ? true : false
enddef

# Remove fold markers if we have it in the current line.
# ----------------------------------------------------------------------------
def RemoveFoldMarkers(line: string): string
  const marker = split(getwinvar(0, '&foldmarker'), ',')
  if empty(marker)
    return line
  else
    return substitute(line, marker[0] .. '.*', '', 'g')
  endif
enddef

# Check if text line is part of a comment.
# ----------------------------------------------------------------------------
def LineIsComment(line: number, column: number): bool
  return synIDattr(synIDtrans(synID(line, column, 1)), 'name') ==? 'comment'
enddef

# Retieve the end comment string on a block comment configuration.
# This function uses the 'comments' configuration of the current buffer to
# compute the string to be used in the tail of a commented string.
# ----------------------------------------------------------------------------
def GetEndCommentStr(): string
  const stringList  = matchlist(getbufvar('%', '&commentstring'), '\(.*\)\?%s\(.*\)\?')
  if len(stringList) > 2
    return ' ' .. stringList[2]
  endif
  return ''
enddef

# -
#  Retrieve the number of bytes in buffer.
##
def GetBufferLineCount(): number
  const bufinfo = getbufinfo('%')
  return (empty(bufinfo) ? 1 : bufinfo[0].linecount)
enddef

# -
#  Format the number of lines information at the end of the text.
##
def FormatLinesInfo(setting: string): string
  const lineCount = GetBufferLineCount()
  const pattern   = printf(setting, '%'..strchars(lineCount)..'d')
  return printf(pattern, (v:foldend - v:foldstart))
enddef

# -
#  Calculates the maximum length, in characteres, that we have available in
#  the current window.
##
def MeasureAvailableSpace(): number
  const signs = getwinvar(0, '&signcolumn')
  const signColumns = (signs == 'auto' || signs == 'yes') ? 2 : 0
  const lineNumbers = (getwinvar(0, '&number') ? max([2, getwinvar(0, '&numberwidth')]) : 0)
  const foldColumns = getwinvar(0, '&foldcolumn')
  const winWidth    = winwidth(0)

  # We always take one character more to have a space between the number of
  # lines folded and the edge of the window.
  return winWidth - (signColumns + lineNumbers + foldColumns + 1)
enddef

# ----------------------------------------------------------------------------
# Exported functions
# ----------------------------------------------------------------------------

# -
#  Process the folded line information.
#  @param options is a dictionary with the following properties:
#         - disabled: a list with disabled filetypes;
#         - sgml: a list with files we can consider of SGML kind.
#         - suffix: format of the folded line suffix.
##
export def FoldedText(options: dict<any>): string
  const ftype = getbufvar('%', '&filetype')
  if IsDisabled(ftype, options.disabled)
    return foldtext()
  endif

  return getline(v:foldstart)

  # Get the line to be shown in the folded text. It will be changed several
  # times in this function.
  var textLine = getline(v:foldstart)
  var textTail = ''

  const lineIndent = indent(v:foldstart)
  const sgmlKind   = IsSgmlKind(ftype, options.sgml, textLine)

  if LineIsComment(v:foldstart, (lineIndent + 1))
    textLine = RemoveFoldMarkers(textLine)
    textTail = GetEndCommentStr()
  endif

  const suffix = FormatLinesInfo(options.suffix)
  const availableSpace = MeasureAvailableSpace()
  const textWidth = strdisplaywidth(textLine)
  const lineWidth = strdisplaywidth(textTail .. suffix) + textWidth
  const difference = availableSpace - lineWidth

  if difference < 0
    const ellipsis = '... '
    textTail = ellipsis .. textTail         # Add ellipsis at the end of our line
    textLine = strcharpart(textLine, 0, textWidth + difference - strdisplaywidth(ellipsis))
  elseif difference > 0
    textTail .= repeat(' ', difference)   # Fill with spaces
  endif

  return textLine .. textTail .. suffix
enddef
