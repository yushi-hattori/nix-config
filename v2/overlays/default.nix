# Aggregates the individual overlay files into one attrset.
#
# Each overlay is its own file (one per package override); add a new file here
# and reference it from flake.nix. Files that don't need `inputs` are plain
# `final: prev:` lambdas; those that do take an `{ inputs, ... }` arg.
{ inputs, ... }:
{
  stable-packages = import ./stable-packages.nix { inherit inputs; };
  nmtui-go = import ./nmtui-go.nix;
  opencode-latest = import ./opencode-latest.nix;
  zellij-latest = import ./zellij-latest.nix;
  yazi-latest = import ./yazi-latest.nix;
  libdisplay-info = import ./libdisplay-info.nix { inherit inputs; };
}
