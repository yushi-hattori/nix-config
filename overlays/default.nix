{ inputs, ... }:
let
  # Define the stable-packages overlay
  stablePackagesOverlay = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

in
{
  # Return an attribute set of overlays
  # Each attribute here will be an overlay
  stable-packages = stablePackagesOverlay;
}
