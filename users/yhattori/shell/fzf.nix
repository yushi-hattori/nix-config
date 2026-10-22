# fzf — fuzzy finder.
#
# Powers most of the scripts (fif, fkill, cd-to-project) and general fuzzy
# selection. Ctrl-R history search is disabled here (atuin owns it); the bind
# sends selection to nvim (ctrl-e) or the clipboard (ctrl-y).
{ ... }:
{
  programs.fzf = {
    enable = true;
    historyWidget.command = "";
    defaultCommand = "find .";
    defaultOptions = [
      "--bind '?:toggle-preview'"
      "--bind 'ctrl-a:select-all'"
      "--bind 'ctrl-e:execute(echo {+} | xargs -o nvim)'"
      "--bind 'ctrl-y:execute-silent(echo {+} | wl-copy)'"
      "--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'"
      "--height=40%"
      "--info=inline"
      "--layout=reverse"
      "--multi"
      "--preview '([[ -f {}  ]] && (bat --color=always --style=numbers,changes {} || cat {})) || ([[ -d {}  ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
      "--preview-window=:hidden"
      "--prompt='~ ' --pointer='▶' --marker='✓'"
    ];
  };
}
