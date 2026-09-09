{ inputs, ... }:
let
  # Define the stable-packages overlay
  stablePackagesOverlay = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # nmtui-go — modern NetworkManager TUI (Bubbletea), maintained since 2025.
  # Not packaged in nixpkgs, so build it from the pinned upstream commit. It
  # drives `nmcli` only, so it stays fully compatible with our NetworkManager
  # (iwd backend) setup — unlike iwd-native TUIs (e.g. impala) which fight
  # NetworkManager for the device.
  # To bump: update `rev`/`version`, refresh the two hashes below.
  nmtuiGoOverlay = final: prev: {
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
  };

  # dan-online/opencode-nix lags behind upstream anomalyco/opencode releases.
  # Override to the latest release until the upstream flake catches up.
  # To bump: update `version` and refresh the hash with
  #   nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url --type sha256 <url>)"
  opencodeLatestOverlay = final: prev: {
    opencode = prev.opencode.overrideAttrs (old: rec {
      version = "1.18.29";
      src = final.fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
        hash = "sha256-6oALf/ViJrcJUhJsn8HiUXykxLVoL9nT+eh0SWl6EZQ=";
      };
    });
  };

in
{
  # Return an attribute set of overlays
  # Each attribute here will be an overlay
  stable-packages = stablePackagesOverlay;
  opencode-latest = opencodeLatestOverlay;
  nmtui-go = nmtuiGoOverlay;
}
