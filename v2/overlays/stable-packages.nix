# stable-packages — pin a second nixpkgs (25.11) under `stable.*`.
#
# The system tracks nixos-unstable, but some packages are kept on stable for
# known-good behavior / fewer rebuilds. Access as `pkgs.stable.<pkg>`.
{ inputs, ... }:
final: prev: {
  stable = import inputs.nixpkgs-stable {
    system = final.system;
    config.allowUnfree = true;
  };
}
