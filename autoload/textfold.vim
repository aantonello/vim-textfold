vim9script
# Vim 'autoload' script.
# Shared functions library.
# Author: Alessandro Antonello <antonello dot ale at gmail dot com>
# Date: 2011, November 11.

# ============================================================================
# Local Functions
# ============================================================================
var version = '1.0.0'

# Get the number of lines in the current buffer.
# ----------------------------------------------------------------------------
def LinesInBuffer() : number
  const info = getbufinfo('%')
  return empty(info) ? 0 : info[0].linecount
enddef

# Get the number of columns used by the 'number' option.
# If there is no line number shown, the function returns 0.
# ----------------------------------------------------------------------------
def NumberColumns() : number
  if getwinvar(0, '&number')
    return max([2, getwinvar(0, '&numberwidth')])
  endif
  return 0
enddef

# Get the number of coluns used by 'foldcolumn' option.
# If the option isn't set to the current buffer, the return is 0.
# ----------------------------------------------------------------------------
def FoldColumns() : number
  return getwinvar(0, '&foldcolumn')
enddef

# Get the number of columns used by 'signcolumn' option.
# If the signs column is disabled in this window, the result is 0.
# ----------------------------------------------------------------------------
def SignColumns() : number
  const signs_cfg = getwinvar(0, '&signcolumn')
  if signs_cfg == 'auto' || signs_cfg == 'yes'
    return 2
  endif
  return 0
enddef

# Formats the number of lines folded.
# Return: A string formatted as ' [%[width]d lines]'.
# ----------------------------------------------------------------------------
def FoldedLinesInfo(): string
  const lines = strlen(LinesInBuffer())
  const opening = g:foldtext_plugin_lines_brackets[0]
  const closing = g:foldtext_plugin_lines_brackets[1]
  const suffix  = g:foldtext_plugin_lines_suffix
  return printf(' %s%'.lines.'d %s%s', opening, (v:foldend - v:foldstart), suffix, closing)
enddef

# Check if the file type is disabled.
# Param: ftype File type of the current buffer.
# ----------------------------------------------------------------------------
def IsDisabled(ftype: string): bool
  final items = g:textfold_plugin_disabled_filetypes

  for item in items
    if ftype ==? item
      return true
    endif
  endfor

  return false
enddef

# Check whether the fold start line is in a comment line.
# Param: lin Fold line number.
# Param: col Column of the first non blank character in the line.
# ----------------------------------------------------------------------------
def IsComment(lin, col) : bool
  return synIDattr(synIDtrans(synID(lin, col, 1)), 'name') ==? 'comment'
enddef

# Check if is an html tag line.
# Param: line The current line of text fold.
# Param: ftype Buffer file type.
# Return: The new text to show in fold text.
# ----------------------------------------------------------------------------
def IsSgml(line: string, ftype: string): bool
  final fts = g:textfold_plugin_sgml_filetypes

  if index(fts, ftype) >= 0 && line =~? '^\s*<\w\+.*'
    return true
  endif
  return false
enddef

# Reduces the line of a comment.
# Param: line The current line of text fold.
# Param: lnum Number of the current line.
# Return: The new text to show in fold text.
# ----------------------------------------------------------------------------
def ReduceCommentLine(line: string, lnum: number): string
  var text: string

  if line =~? '^<!--.*'
    text = trim(line, '<!-> ')
  elseif line =~? '^/\*.*' || line =~? '^//.*'
    text = trim(line, '/*! ', 1)
  elseif line =~? '^".*'
    text = trim(line, '" ', 1)
  else
    text = line
  endif

  " Get the next line of text if we end up with a blank line.
  if strlen(text) == 0
    return trim(getline(lnum + 1))
  else
    return line
  endif
enddef

# Remove fold markers in the text line.
# Param line: The text line to process.
# Return The text line without fold markers.
# ----------------------------------------------------------------------------
def RemoveFoldMarkers(text: string): string
  const fmethod = getwinvar(0, '&foldmethod')
  if fmethod !=? 'marker'
    return text
  endif

  # Only the openning fold marker needs to be removed.
  const fmarker = split(getwinvar(0, '&foldmarker'), ',')
  return substitute(text, fmarker[0] .. '.*', '', 'g')
enddef

# ============================================================================
# Exported Functions
# ============================================================================

# Builds the text to present in a fold line.
# ----------------------------------------------------------------------------
export def BuildFoldedText() : string
  if getwinvar(0, '&diff')
    return foldtext()
  endif

  var ftype = getbufvar('%', '&filetype')
  if IsDisabled(ftype)
    return foldtext()
  endif

  var textLine = getline(v:foldstart)

  const lineIndent = indent(v:foldstart)
#  const numberColumns = NumberColumns()
  const isSgml = IsSgml(textLine, ftype)

  # Remove fold markers if needed.
  textLine = RemoveFoldMarkers(textLine)
  :echomsg 'RemoveFoldMarkers: ' .. textLine

  # Remove spaces from start and end of text.
  textLine = trim(textLine)

  # If the line is a comment, remove the comment markers.
  if IsComment(v:foldstart, lineIndent + 1)
    textLine = ReduceCommentLine(textLine, v:foldstart)
  endif

  const textTail = FoldedLinesInfo()
  const tailLength = strlen(textTail) + 1
  const winWidth = winwidth(0) - (tailLength + NumberColumns() + lineIndent + SignColumns() + FoldColumns())

  if winWidth <= tailLength
    return textTail
  endif

  const lineWidth = strdisplaywidth(textLine)
  if lineWidth > winWidth
    if isSgml
      textLine = strcharpart(textLine, 0, (winWidth - 6)) .. '... />'
    else
      textLine = strcharpart(textLine, 0, (winWidth - 3)) .. '...'
    endif
  elseif lineWidth < winWidth
    if isSgml && match(textLine, '.*[^/]>$') >= 0
      textLine = substitute(textLine, '>', '/>', '') .. repeat(' ', (winWidth - lineWidth - 1))
    else
      textLine = textLine . repeat(' ', (winWidth - lineWidth))
    endif
  endif

  return repeat(' ', lineIndent) .. textLine .. textTail
enddef

