" Project configuration file.
" This template enables you to set configurations before any other vim stuff
" is loaded.
" For GUI configurations, use the 'script.gvimrc' template.
set nocp

"" NOTE: to remember. Uncomment only what you need. When none of this is used,
"  `g:coc_plugin_enabled` is the default and will be available.

"let g:ale_plugin_enabled = v:true             " Enable ALE plugin
"let g:android_plugin_enabled = v:true         " Enable Android plugin
let g:coc_plugin_enabled = v:true             " Enable coc-nvim plugin.
let g:devicons_enabled = v:true               " Enable WebDevIcons.
let g:airline_powerline_fonts = 1             " Enable powerline fonts in airline
"let g:airline_tabline_enabled = 1             " Enable airline tabline.

let g:gui_treeview = 'nerdtree'               " For NERDTree automatic show up set to v:true
let g:gui_columns  = 196                      " Startup width
let g:gui_lines    = 99                       " Startup height
let g:color_light  = 'intellij'               " Sets color for day light.
let g:color_night  = 'darkZ'                  " Sets color for night.

"let g:fc_DefaultFont='AnonymiceNerdFontComplete-:h13'

let g:atpl_UsersList = {
      \ '@PROJECT@': 'vim-textfold',
      \ '@OWNER@'  : 'aantonello',
      \ '@VERSION@': '1.0.3'
      \}

" Keep this line. It will asure that Vim will start smothly.
source $HOME/.vim/vimrc

