# proof of concept; lack clipboard provider detection.
#
# implementation reference for later:
#
# https://github.com/helix-editor/helix/blob/0cb5e0b2caba61bbcf6f57ce58506882766d5eea/helix-view/src/clipboard.rs
# https://github.com/neovim/neovim/blob/f2906a4669a2eef6d7bf86a29648793d63c98949/runtime/autoload/provider/clipboard.vim#L68-L152
# https://github.com/extrawurst/gitui/blob/master/src/clipboard.rs
# https://github.com/inkarkat/vim-UnconditionalPaste
#
declare-option str-list clipboard_copy_command 'pbcopy'
declare-option str-list clipboard_paste_command 'pbpaste'

define-command -override clipboard-yank %{
  nop %sh{
    eval "set -- $kak_quoted_selections"
    printf '%s\n' "$@" | eval "$kak_quoted_opt_clipboard_copy_command"
  }
}

define-command -override clipboard-paste -params .. %{
  evaluate-commands -save-regs '"' %{
    set-register dquote %sh(eval "$kak_quoted_opt_clipboard_paste_command")
    execute-keys %arg{@}
  }
}

define-command -override clipboard-paste-characterwise -params .. %{
  evaluate-commands -save-regs '"' %{
    set-register dquote %sh(eval "$kak_quoted_opt_clipboard_paste_command" | kak -f '<s>\n+\z<ret>d')
    execute-keys %arg{@}
  }
}

define-command -override clipboard-paste-linewise -params .. %{
  evaluate-commands -save-regs '"' %{
    set-register dquote %sh(eval "$kak_quoted_opt_clipboard_paste_command" | kak -f 'gedo')
    execute-keys %arg{@}
  }
}

try %[ declare-user-mode clipboard ]
map -docstring 'yank joined selections into system clipboard' global clipboard y ': clipboard-yank<ret>'
map -docstring 'paste system clipboard after selections (characterwise)' global clipboard p ': clipboard-paste-characterwise p<ret>'
map -docstring 'paste system clipboard before selections (characterwise)' global clipboard <a-p> ': clipboard-paste-characterwise P<ret>'
map -docstring 'paste system clipboard after selections (linewise)' global clipboard P ': clipboard-paste-linewise p<ret>'
map -docstring 'paste system clipboard before selections (linewise)' global clipboard <a-P> ': clipboard-paste-linewise P<ret>'
map -docstring 'replace selections with content of system clipboard' global clipboard R ': clipboard-paste R<ret>'

map -docstring 'enter clipboard mode' global normal <c-v> ': enter-user-mode clipboard<ret>'
