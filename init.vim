set number

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'itchyny/lightline.vim'

call plug#end()

"map <F8> :w <CR> :!g++ % -o %< && printf '\e[1;32m%-Compiled Successfully\e[m' <CR> :vsplit | terminal ./%< <CR>
map <F8>:terminal ./%< <CR>
map <F5> :w <CR> :!g++ % -o %< <CR>


