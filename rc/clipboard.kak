# proof of concept; lack clipboard provider detection.
#
# implementation reference for later:
#
# https://github.com/helix-editor/helix/blob/0cb5e0b2caba61bbcf6f57ce58506882766d5eea/helix-view/src/clipboard.rs
# https://github.com/neovim/neovim/blob/f2906a4669a2eef6d7bf86a29648793d63c98949/runtime/autoload/provider/clipboard.vim#L68-L152
# https://github.com/extrawurst/gitui/blob/master/src/clipboard.rs
# https://github.com/inkarkat/vim-UnconditionalPaste
#
# https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=PasteMode
# PasteMode::Append
# PasteMode::Insert
# PasteMode::Replace
#
# declare-option str-list clipboard_copy_command 'pbcopy'
# declare-option str-list clipboard_paste_command 'pbpaste'
declare-option str clipboard_copy_command 'wl-copy'
declare-option str-list clipboard_copy_args

declare-option str clipboard_paste_command 'wl-paste'
declare-option str-list clipboard_paste_args '--no-newline'

define-command -override clipboard-yank %{
  nop %sh{
    printf 'echo -to-file %%(%s) -- "%%val{selections}"' "$kak_response_fifo" > "$kak_command_fifo"
    tr '\0' '\n' < "$kak_response_fifo" | eval "$kak_quoted_opt_clipboard_copy_command" "$kak_quoted_opt_clipboard_copy_args" > /dev/null 2>&1 &
  }
}

define-command -override clipboard-paste-append -params .. %{
  execute-keys '<a-!> %opt{clipboard_paste_command}<a-!> %opt{clipboard_paste_args}<a-!><ret><a-;>'
}

define-command -override clipboard-paste-insert -params .. %{
  execute-keys '! %opt{clipboard_paste_command}<a-!> %opt{clipboard_paste_args}<a-!><ret>'
}

define-command -override clipboard-paste-replace -params .. %{
  execute-keys '| %opt{clipboard_paste_command}<a-!> %opt{clipboard_paste_args}<a-!><ret>'
}

try %[ declare-user-mode clipboard ]
map -docstring 'yank joined selections into system clipboard' global clipboard y ': clipboard-yank<ret>'
map -docstring 'paste system clipboard after selections' global clipboard p ': clipboard-paste-append<ret>'
map -docstring 'paste system clipboard before selections' global clipboard P ': clipboard-paste-insert<ret>'
map -docstring 'replace selections with content of system clipboard' global clipboard R ': clipboard-paste-replace<ret>'

map -docstring 'enter clipboard mode' global user x ': enter-user-mode clipboard<ret>'
