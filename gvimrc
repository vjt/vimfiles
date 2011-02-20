"tell the term has 256 colors
set t_Co=256

colorscheme torte
set guitablabel=%M%t

if has("gui_mac") || has("gui_macvim")
  " make Mac's Option key behave as the Meta key
  set invmmta
  set guifont=Anonymous:h10
  set transparency=10
endif

if has("gui_win32") || has("gui_win32s")
  set guifont=Consolas:h12
  set enc=utf-8
endif

"highlight trailing whitespace
set list
set listchars=tab:»·,trail:· ",eol:¶
