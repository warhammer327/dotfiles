require("config.lazy")
---"install mason then do LspInstall language
require("mason").setup()
require("mason-lspconfig").setup()
vim.cmd([[
    syntax on                   " syntax highlighting
    set nocompatible            " disable compatibility to old-time vi
    set tabstop=4               " number of columns occupied by a tab 
    set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
    set expandtab               " converts tabs to white space
    set shiftwidth=4            " width for autoindents
    set autoindent              " indent a new line the same amount as the line just typed
    set number relativenumber   " show actual and relative line number
    set wildmode=longest,list   " get bash-like tab completions
    set mouse=a                 " enable mouse click
    set cursorline              " highlight current cursorline
    set ttyfast                 " Speed up scrolling in Vim
]])
