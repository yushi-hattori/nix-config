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
      ff = "fastfetch";
      conda = "micromamba";
      mamba = "micromamba";

      # NixOS
      update-fw-all = "update-fw && update-fw-hm";
      update-fw = "sudo nixos-rebuild switch --flake .#framework13";
      update-fw-hm = "home-manager switch --flake .#yhattori@framework13 -b backup";
      "gc" = "sudo nix-collect-garbage -d";

      # git
      gaa = "git add --all";
      gcam = "git commit --all --message";
      gcl = "git clone";
      gco = "git checkout";
      ggl = "git pull";
      ggp = "git push";

      # kubectl
      k = "kubectl";
      kgno = "kubectl get node";
      kdno = "kubectl describe node";
      kgp = "kubectl get pods";
      kep = "kubectl edit pods";
      kdp = "kubectl describe pods";
      kdelp = "kubectl delete pods";
      kgs = "kubectl get svc";
      kes = "kubectl edit svc";
      kds = "kubectl describe svc";
      kdels = "kubectl delete svc";
      kgi = "kubectl get ingress";
      kei = "kubectl edit ingress";
      kdi = "kubectl describe ingress";
      kdeli = "kubectl delete ingress";
      kgns = "kubectl get namespaces";
      kens = "kubectl edit namespace";
      kdns = "kubectl describe namespace";
      kdelns = "kubectl delete namespace";
      kgd = "kubectl get deployment";
      ked = "kubectl edit deployment";
      kdd = "kubectl describe deployment";
      kdeld = "kubectl delete deployment";
      kgsec = "kubectl get secret";
      kdsec = "kubectl describe secret";
      kdelsec = "kubectl delete secret";

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
