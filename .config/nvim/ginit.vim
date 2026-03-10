" This file is for GUI
" Enable Mouse. Enabled in neovim options
" set mouse=a

" Enable font ligatures
if exists(':GuiRenderLigatures')
    GuiRenderLigatures 1
endif

" if exists(':GuiAdaptiveFont')
    " GuiAdaptiveFont 1
" endif

" Right Click Context Menu (Copy-Cut-Paste)
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv
