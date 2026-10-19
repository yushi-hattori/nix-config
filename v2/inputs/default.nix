# Auto-import every `*.nix` file in this directory as a flake input.
# The filename (minus `.nix`) becomes the input name, so adding an input is
# just dropping a new `<name>.nix` file here — no need to edit this file.
let
  # List every entry in this directory and keep only `*.nix` files,
  # excluding this `default.nix` itself (so we don't import ourselves).
  files = builtins.filter
    (n: n != "default.nix" && builtins.match ".*\.nix$" n != null)
    (builtins.attrNames (builtins.readDir ./.));
in
# Turn that list into `{ <name> = <imported attrset>; ... }`.
builtins.listToAttrs (map (n: {
  # Strip the trailing `.nix` to get the input name (e.g. "home-manager.nix" -> "home-manager").
  name = builtins.substring 0 (builtins.stringLength n - 4) n;
  # Import the file; it must evaluate to an input-spec attrset.
  value = import (./. + "/${n}");
}) files)
