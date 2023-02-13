" Functions to build useful folded text lines.
" Maintainer: Alessandro Antonello <antonello dot ale @ gmail dot com>
" ============================================================================

const version = '1.0.2'

" ----------------------------------------------------------------------------
" Local functions
" ----------------------------------------------------------------------------

" Check if the current buffer has a disabled filetype.
" ----------------------------------------------------------------------------
fun s:IsDisabled(ftype, config)
  if empty(a:config) || (index(a:ftype, a:config) < 0)
    return v:false
  endif
  return v:true
endfun

" Check whether the current filetype is SGML kind.
" ----------------------------------------------------------------------------
fun s:IsSgmlKind(ftype, config, line)
  " If the filetype is in the SGML configuration list and the folded line
  " starts with an angled bracket.
  return ((index(a:ftype, a:config) >= 0) && a:line =~? '^\s*<\w\+.*') ? v:true : v:false
endfun

" Remove fold markers if we have it in the current line.
" ----------------------------------------------------------------------------
fun s:RemoveFoldMarkers(line)
  const marker = split(getwinvar(0, '&foldmarker'), ',')
  if empty(marker)
    return a:line
  else
    echomsg 'RemoveFoldMarkers('..a:line..') = [' .. marker[0] ..', '..marker[1]..']'
    return substitute(a:line, marker[0] .. '.*', '', 'g')
  endif
endfun

" Check if text line is part of a comment.
" ----------------------------------------------------------------------------
fun s:LineIsComment(line, column)
  return synIDattr(synIDtrans(synID(a:line, a:column, 1)), 'name') ==? 'comment'
endfun

" Retieve the end comment string on a block comment configuration.
" This function uses the 'comments' configuration of the current buffer to
" compute the string to be used in the tail of a commented string.
" ----------------------------------------------------------------------------
fun s:GetEndCommentStr()
  const stringList  = matchlist(getbufvar('%', '&commentstring'), '\(.*\)\?%s\(.*\)\?')
  if len(stringList) > 2
    return ' ' .. stringList[2]
  endif
  return ''
endfun

" -
"  Retrieve the number of bytes in buffer.
" ----------------------------------------------------------------------------
fun s:GetBufferLineCount()
  const bufinfo = getbufinfo('%')
  return (empty(bufinfo) ? 1 : bufinfo[0].linecount)
endfun

" -
"  Format the number of lines information at the end of the text.
" ----------------------------------------------------------------------------
fun s:FomatLinesInfo(setting)
  const lineCount = s:GetBufferLineCount()
  const pattern   = printf(a:setting, '%'..strchars(lineCount)..'d')
  return printf(pattern, (v:foldend - v:foldstart))
endfun

" -
"  Calculates the maximum length, in characteres, that we have available in
"  the current window.
" ----------------------------------------------------------------------------
fun s:MeasureAvailableSpace()
  const signs = getwinvar(0, '&signcolumn')
  const signColumns = (signs == 'auto' || signs == 'yes') ? 2 : 0
  const lineNumbers = (getwinvar(0, '&number') ? max([2, getwinvar(0, '&numberwidth')]) : 0)
  const foldColumns = getwinvar(0, '&foldcolumn')
  const winWidth    = winwidth(0)

  " We always take one character more to have a space between the number of
  " lines folded and the edge of the window.
  return winWidth - (signColumns + lineNumbers + foldColumns + 1)
endfun

" ----------------------------------------------------------------------------
" Exported functions
" ----------------------------------------------------------------------------

" -
"  Process the folded line information.
"  @param options is a dictionary with the following properties:
"         - disabled: a list with disabled filetypes;
"         - sgml: a list with files we can consider of SGML kind.
"         - suffix: format of the folded line suffix.
" ----------------------------------------------------------------------------
fun textfold#FoldedText(options)
  const ftype = getbufvar('%', '&filetype')
  if s:IsDisabled(ftype, a:options.disabled)
    return foldtext()
  endif

  " Get the line to be shown in the folded text. It will be changed several
  " times in this function.
  let textLine = getline(v:foldstart)
  let textTail = ''

  let lineIndent = indent(v:foldstart)
  let sgmlKind   = s:IsSgmlKind(ftype, a:options.sgml, textLine)

  if s:LineIsComment(v:foldstart, (lineIndent + 1))
    let textLine = s:RemoveFoldMarkers(textLine)
    let textTail = s:GetEndCommentStr()
  endif

  const suffix = s:FomatLinesInfo(a:options.suffix)
  const availableSpace = s:MeasureAvailableSpace()
  const textWidth = strdisplaywidth(textLine)
  const lineWidth = strdisplaywidth(textTail .. suffix) + textWidth
  const difference = availableSpace - lineWidth

  if difference < 0
    const ellipsis = '... '
    let textTail = ellipsis .. textTail         " Add ellipsis at the end of our line
    let textLine = strcharpart(textLine, 0, textWidth + difference - strdisplaywidth(ellipsis))
  elseif difference > 0
    let textTail .= repeat(' ', difference)   " Fill with spaces
  endif

  return textLine .. textTail .. suffix
endfun

