{ inputs, ... }:
let
  # Define the stable-packages overlay
  stablePackagesOverlay = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
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
}
