{ inputs, ... }:
let
  # Define the stable-packages overlay
  stablePackagesOverlay = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Define the gemini-cli overlay
  geminiCliOverlay = import ./gemini-cli.nix;
in
{
  # Return an attribute set of overlays
  # Each attribute here will be an overlay
  stable-packages = stablePackagesOverlay;
  gemini-cli = geminiCliOverlay;
}