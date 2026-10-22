# Zsh — interactive shell init (.zshrc).
#
# Runs on every interactive shell: keybindings, zsh-vi-mode, ~/.env sourcing,
# the `nd` helper, and micromamba init.
{ config, pkgs, ... }:
{
  programs.zsh.initContent = ''
    export OLLAMA_API_BASE=http://localhost:11434

    # Inside zellij, hide the host terminal's identity so tools that probe
    # $TERM_PROGRAM/$GHOSTTY_RESOURCES_DIR don't pick kitty placeholders that
    # zellij can't render (yazi#4216).
    if [ -n "$ZELLIJ" ]; then
      unset GHOSTTY_RESOURCES_DIR GHOSTTY_BIN_DIR TERM_PROGRAM TERM_PROGRAM_VERSION
    fi

    bindkey -e
    bindkey '^H' backward-delete-word
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word

    # Open commands in $EDITOR with C-v
    autoload -z edit-command-line
    zle -N edit-command-line
    bindkey "^v" edit-command-line

    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    if [ -f "$HOME/.env" ]; then
      set -a
      source "$HOME/.env"
      set +a
    fi

    bindkey '^E' autosuggest-accept
    bindkey '^J' history-down
    bindkey '^K' history-up

    # Enter a nix develop shell but keep THIS interactive zsh (vim-mode
    # bindings, highlighting, aliases all carry over) instead of nix's bare bash.
    nd() { nix develop "$@" --command zsh; }

    export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX='${config.home.homeDirectory}/.mamba';
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
        # nixpkgs wraps mamba/micromamba as `.mamba-wrapped`; the shell hook
        # resolves its own path via /proc/self/exe and bakes `.mamba-wrapped`
        # in, which then fails mamba's own "must be mamba or micromamba"
        # filename check. Point it back at the real micromamba wrapper.
        __mamba_setup="$(printf '%s' "$__mamba_setup" | sed "s#${pkgs.mamba-cpp}/bin/.mamba-wrapped#\$MAMBA_EXE#g")"
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"
    fi
    unset __mamba_setup
  '';
}
