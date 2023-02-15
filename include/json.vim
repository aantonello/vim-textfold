" Special tratment for JSON files
" Maintainer: Alessandro Antonello
" ----------------------------------------------------------------------------
vim9script

# What is special about JSON?
# When you have syntax fold enable you end up with lines like:
#
# "some-element": {                                               [  10 lines]
# "some-array": [                                                 [  24 lines]
#
# We can work better on that providing a clue whether the object or array are
# empty or not without opening the fold. By providing ellipses when ther are
# some information inside of them or just closing the declaration:
#
# "some-element": { ... }                                         [  10 lines]
#
# Now you know, just by looking at it, that there is data inside the fold.
#
# "some-array": [ ]                                               [   1 lines]
#
# Here, there is nothing inside this array.

# -
#  Selects the closing symbol of a fold element or array according to its
#  content.
# ----------------------------------------------------------------------------
export def SelectLineEnding(textLine: string): string
  const trimmed = trim(textLine, ' ', 2)
  if stridx(trimmed, '{') == (strlen(trimmed) - 1)
    return (v:foldend - v:foldstart) > 1 ? ' ... }' : ' }'
  elseif stridx(trimmed, '[') == (strlen(trimmed) - 1)
    return (v:foldend - v:foldstart) > 1 ? ' ... ]' : ' ]'
  endif
  return ''
enddef

