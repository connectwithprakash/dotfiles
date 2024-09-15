" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

" List of plugins
Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'

" Initialize plugin system
call plug#end()

" General settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set clipboard=unnamedplus

" Key mappings
nmap <C-n> :NERDTreeToggle<CR>
nmap <C-p> :Files<CR>

" CoC (Conquer of Completion) settings
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-python']

" Lightline settings
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }