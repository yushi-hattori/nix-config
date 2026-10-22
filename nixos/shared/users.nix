# users — the yhattori user account.
#
# Without this the getty autologin has no user to log in as, and the graphical
# session never starts. (home-manager only sets `home.username`; it doesn't
# create the NixOS system user.)
{ constants, pkgs, ... }:
{
  # Make zsh a valid login shell in /etc/shells (required when setting it below).
  programs.zsh.enable = true;

  users.users.${constants.user.name} = {
    description = constants.user.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "lp"
      "scanner"
      "input"
      "video"
      "audio"
    ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # User avatar (AccountsService)
  system.activationScripts.avatar.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${constants.user.avatar} /var/lib/AccountsService/icons/${constants.user.name}
    touch /var/lib/AccountsService/users/${constants.user.name}
    if ! grep -q "^Icon=" /var/lib/AccountsService/users/${constants.user.name}; then
      if ! grep -q "^\[User\]" /var/lib/AccountsService/users/${constants.user.name}; then
        echo "[User]" >> /var/lib/AccountsService/users/${constants.user.name}
      fi
      echo "Icon=/var/lib/AccountsService/icons/${constants.user.name}" >> /var/lib/AccountsService/users/${constants.user.name}
    fi
  '';
}
