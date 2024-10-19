vim.cmd([[
    set nocompatible            " disable compatibility to old-time vi
    set tabstop=4               " number of columns occupied by a tab 
    set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
    set expandtab               " converts tabs to white space
    set shiftwidth=4            " width for autoindents
    set autoindent              " indent a new line the same amount as the line just typed
    set number                  " add line numbers
    set wildmode=longest,list   " get bash-like tab completions
    syntax on                   " syntax highlighting
    set mouse=a                 " enable mouse click
"    set clipboard=unnamedplus   " using system clipboard
    set cursorline              " highlight current cursorline
    set ttyfast                 " Speed up scrolling in Vim
]])
