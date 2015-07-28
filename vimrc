runtime! debian.vim

"CamelCaseMotion
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e

"load pathogen managed plugins
call pathogen#runtime_append_all_bundles()

"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom
"set showmatch   "show parenthesis/braces match

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set number      "add line numbers
set showbreak=...
set wrap linebreak nolist

"Put swap files here
"Disabled because it is unsafe, if you share the same
"source directory either via NFS or vmhgfs (my case).
"set directory=~/.vim/swap

"auto :w on :next, :prev, etc
set autowrite

"c	Auto-wrap comments using textwidth, inserting the current comment leader automatically.
"r	Automatically insert the current comment leader after hitting <Enter> in Insert mode.
"o	Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
"q	Allow formatting of comments with "gq".
"a	Automatic formatting of paragraphs.  Every time text is inserted or deleted the paragraph
"   will be reformatted.  See |auto-format|.  When the 'c' flag is present this only happens
"   for recognized comments.
"n	When formatting text, recognize numbered lists.  This actually uses
"l	Long lines are not broken in insert mode:
set formatoptions=croqlan

set textwidth=78
set encoding=utf-8

" Enable entering diacritics and other marks
" http://vim.wikia.com/wiki/Entering_special_characters
" set digraph - no, it gets in the way.

"mapping for command key to map navigation thru display lines instead
"of just numbered lines
vmap <D-j> gj
vmap <D-k> gk
vmap <D-4> g$
vmap <D-6> g^
vmap <D-0> g^
nmap <D-j> gj
nmap <D-k> gk
nmap <D-4> g$
nmap <D-6> g^
nmap <D-0> g^

"try to make possible to navigate within lines of wrapped lines
nmap <Down> gj
nmap <Up> gk
set fo=l

"statusline setup
set statusline=%f       "tail of the filename
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

"Git
set statusline+=\ %{StatuslineGitBranch()}

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"Display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=\ %y    "filetype

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=\ %#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=\ %#error#
set statusline+=%{StatuslineTrailingSpaceWarning()}
set statusline+=%*

"set statusline+=%{StatuslineLongLineWarning()}
"
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator

"set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight

set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"remove trailing whitespace on save
autocmd FileType c,cpp,javascript,ruby,eruby,html,css autocmd BufWritePre <buffer> :%s/\s\+$//e

"returns the current checked out branch inside square brackets if
"we're in a Git repository, nothing otherwise.
function! StatuslineGitBranch()
    let branch = GitBranch()
    if branch == ''
        return ''
    else
        return '[' . branch . ']'
    endif
endfunction

"return '[Trailing \s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[Trailing \s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"indent settings
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent

"folding settings
set foldmethod=marker   "fold based on markers
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:full
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"search case settings
set ignorecase
set smartcase

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"screen/xterm title
if &term == "screen" || &term == "screen-256color"
  set t_ts=k
  set t_fs=\
  set title
endif

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"Hide buffers when not displayed
"Disabled because long editor sessions start leaking
"lots of memory, and I DON'T WANT TO RESTART MY EDITOR.
"set hidden

"colorscheme and background - DARK
colorscheme torte
set bg=dark

silent! nmap <silent> <Leader>p :NERDTreeToggle<CR>
nnoremap <silent> <C-f> :call FindInNERDTree()<CR>

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

silent! nmap <silent> <Leader>B :BufExplorer<CR>
silent! nmap <silent> <Leader>X :TlistToggle<CR>

"map Q to something useful
noremap Q gq

"mark syntax errors with :signs
"let g:syntastic_enable_signs=1

"key mapping for vimgrep result navigation
map <A-o> :copen<CR>
map <A-q> :cclose<CR>
map <A-j> :cnext<CR>
map <A-k> :cprevious<CR>

"mappings for section navigation
map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

"Mappings for align
map <Leader>= :Align<CR>

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction

"key mapping for tab navigation
nmap <Tab> gt
nmap <S-Tab> gT

"Key mapping for textmate-like indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

"Copy and paste from X clipboard -
"http://vim.wikia.com/wiki/Accessing_the_system_clipboard#Simple_Work_around_for_X_Clipboards
"Clipboard
com -range Cz :silent :<line1>,<line2>w !xsel -i -b
"Primary
com -range Cx :silent :<line1>,<line2>w !xsel -i -p
"Secondary
com -range Cv :silent :<line1>,<line2>w !xsel -i -s
ca cv Cv
ca cz Cz
ca cx Cx

"Paste
com -range Pz :silent :r !xsel -o -b
com -range Px :silent :r !xsel -o -p
com -range Pv :silent :r !xsel -o -s
ca pz Pz
ca px Px
ca pv Pv
