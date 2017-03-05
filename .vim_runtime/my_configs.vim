"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Fast quit
nmap <leader>q :q<cr>

" Close Buffer
nmap <leader>x :bd<cr>

" Edit .vimrc
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

" Insert Timestamp
nnoremap <F7> "=strftime("%Y-%m-%d %H:%M")<CR>P
inoremap <F7> <C-R>=strftime("%Y-%m-%d %H:%M")<CR>

"------------------------
" Function Keybindings
"------------------------
nmap <F6> :NERDTreeToggle<cr>

"------------------------
" Blackwater Park Studios
"------------------------
"Edit Journal
nnoremap <leader>ops <C-w><C-v><C-l>:e $MYOPSDIR/journal.md<cr>

"------------------
" Useful Functions
"------------------
" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
