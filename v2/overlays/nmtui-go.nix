# nmtui-go — modern NetworkManager TUI (Bubbletea), maintained since 2025.
#
# Not packaged in nixpkgs, so build it from the pinned upstream commit. It
# drives `nmcli` only, so it stays fully compatible with NetworkManager — unlike
# iwd-native TUIs (e.g. impala) which fight NetworkManager for the device.
#
# To bump: update `rev`/`version`, refresh the two hashes below.
final: prev: {
  nmtui-go = prev.buildGoModule rec {
    pname = "nmtui-go";
    version = "2026-03-17";
    src = final.fetchFromGitHub {
      owner = "doeixd";
      repo = "nmtui-go";
      rev = "ca92f5645ca6362a8399558e9cb71d930ce2588e";
      hash = "sha256-ti/EHR6ld3nvS69Oywx59yYJgBSfU1uLROkNHTNMg/0=";
    };
    subPackages = [ "cmd" ];
    vendorHash = "sha256-FYrLLZHd7C98LzmIUuEpJxLEqT2j/7GWHTcjNRRV4xY=";
    postInstall = ''
      mv "$out/bin/cmd" "$out/bin/nmtui-go"
    '';
    meta = {
      description = "Modern TUI for managing NetworkManager Wi-Fi, built with Bubbletea";
      homepage = "https://github.com/doeixd/nmtui-go";
      license = final.lib.licenses.mit;
      platforms = final.lib.platforms.linux;
      mainProgram = "nmtui-go";
    };
  };
}
