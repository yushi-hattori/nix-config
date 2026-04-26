{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Zsh shell configuration
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    history = {
      append = true;
      extended = true;
    };
    syntaxHighlighting = {
      enable = true;
    };

    shellAliases = {
      main = "zellij attach --create main";

      ff = "fastfetch";
      sunshine-ui = "zen https://localhost:47990 &>/dev/null &";
      conda = "micromamba";
      mamba = "micromamba";

      # NixOS
      update-fw-all = "update-fw && update-fw-hm";
      update-fw = "cd ~/nix-config && sudo nixos-rebuild switch --flake .#framework13";
      update-fw-hm = "cd ~/nix-config && home-manager switch --flake .#yhattori@framework13 -b backup";
      "gc" = "sudo nix-collect-garbage -d";

      # python
      deeplearning = "conda activate deeplearning";

      impala = "impala"; # Wifi TUI
      wifi = "alacritty --title wifi-tui -e impala"; # Wifi TUI
      walker = "walker";

      ld = "lazydocker";
      lg = "lazygit";

      repo = "cd $HOME/Documents/repositories";
      temp = "cd $HOME/Downloads/temp";

      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      "cd" = "z";
      ".." = "cd ..";
      ls = "eza --icons always"; # default view
      ll = "eza -bhl --icons --group-directories-first"; # long list
      la = "eza -abhl --icons --group-directories-first"; # all list
      lt = "eza --tree --level=2 --icons"; # tree
    };
    initContent = ''
      # Ollama API configuration
      export OLLAMA_API_BASE=http://localhost:11434

      # kubectl auto-complete
      source <(kubectl completion zsh)

      # bindings
      bindkey -e
      bindkey '^H' backward-delete-word
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # open commands in $EDITOR with C-e
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^v" edit-command-line

      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        # Enable ALT-C fzf keybinding on Mac
        bindkey 'ć' fzf-cd-widget
      ''}


      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      if [ -f "$HOME/.env" ]; then
        set -a
        source "$HOME/.env"
        set +a
      fi

      bindkey '^E' autosuggest-accept  # Ctrl + e to accept autosuggestions
      bindkey '^J' history-down        # Ctrl + j to move down in history
      bindkey '^K' history-up          # Ctrl + k to move up in history

      # >>> mamba initialize >>>
      # !! Contents within this block are managed by 'micromamba shell init' !!
      export MAMBA_EXE='/nix/store/szq88nrq86pa50339h01hl983q2apnhl-micromamba-2.4.0/bin/micromamba';
      export MAMBA_ROOT_PREFIX='${config.home.homeDirectory}/.mamba';
      __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__mamba_setup"
      else
          alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
      fi
      unset __mamba_setup
      # <<< mamba initialize <<<
    '';
  };
}
