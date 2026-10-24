# openchamber + openchamber-desktop — rebuilt with corrected fixed-output
# hashes against OpenChamber's own nixpkgs pin.
#
# Upstream HEAD drifts: its flake pins opencode v2.1.3 while packages/electron
# requires v2.1.4, and nix/hashes.json still holds the old bun-deps +
# opencode-node-modules hashes. The flake's own `throwIf` guard then fails every
# evaluation, so `inputs.openchamber.packages.*` is unusable until upstream
# re-bakes. This overlay recreates the two affected derivations:
#
#   * opencode-cli       -> opencode v2.1.4 (input overridden in flake.nix)
#   * openchamber        -> package.nix against a patched source whose
#                           hashes.json carries the re-baked bun-deps hash
#   * openchamber-desktop-> gui.nix on top of the above + nixpkgs' electron
#
# Re-bake with `nix run .#update-hashes` in a checkout of openchamber HEAD and
# copy the two values into `hashes` below. Drop this overlay once upstream
# re-syncs its flake and go back to the flake's own packages.
{ inputs, ... }:
final: prev:
let
  system = final.stdenv.hostPlatform.system;
  ocPkgs = inputs.openchamber.inputs.nixpkgs.legacyPackages.${system};
  opencode = inputs.openchamber.inputs.opencode;
  version = (builtins.fromJSON (builtins.readFile "${inputs.openchamber}/package.json")).version;

  hashes = {
    opencodeNodeModules = "sha256-3c3nMY6ebAxqRugN01rdvACinbe1vIVDCpVDFR/N94M=";
    bunDeps = "sha256-Z48U5qkgL+y5LCSstqu09NzhnISLStGI6iz8x40LslU=";
  };

  # OpenCode CLI, recreated from openchamber's flake.nix `opencode-cli` binding
  # (the flake's own copy throws on the pin/version mismatch). Same quirks as
  # upstream: copy the monorepo root script/ dir before the build, drop the
  # completion postInstall, and disable the auto-updater on the wrapped binary.
  opencode-cli = (ocPkgs.callPackage "${opencode}/nix/opencode.nix" {
    node_modules = ocPkgs.callPackage "${opencode}/nix/node_modules.nix" {
      rev = opencode.rev or "dirty";
      hash = hashes.opencodeNodeModules;
    };
  }).overrideAttrs (old: {
    preBuild = "cp -R ${opencode}/script ./script";
    postInstall = "";
    postFixup = ''
      wrapProgram "$out/bin/opencode" --set OPENCODE_DISABLE_AUTOUPDATE 1
    '';
  });

  # Copy of the openchamber source with the baked hashes written back in, so
  # package.nix picks up the correct bun-deps hash (it reads ./hashes.json).
  patchedSrc = ocPkgs.runCommand "openchamber-src-patched" { } ''
    cp -r ${inputs.openchamber} "$out"
    chmod -R u+w "$out"
    cat > "$out/nix/hashes.json" <<'EOF'
    {
      "bunDeps": "${hashes.bunDeps}",
      "opencodeNodeModules": "${hashes.opencodeNodeModules}"
    }
    EOF
  '';

  openchamber = ocPkgs.callPackage "${patchedSrc}/nix/package.nix" {
    self = patchedSrc;
    inherit version;
    opencodeCli = opencode-cli;
  };

  # Electron major read from packages/electron devDependencies at eval time,
  # exactly as the openchamber flake does (nixpkgs' minor may trail the caret).
  electronSpec =
    (builtins.fromJSON (builtins.readFile "${inputs.openchamber}/packages/electron/package.json")).devDependencies.electron;
  electronMajor = ocPkgs.lib.versions.major (ocPkgs.lib.removePrefix "^" electronSpec);
  electron = ocPkgs.${"electron_${electronMajor}"} or (throw "openchamber pins electron ${electronSpec}, but nixpkgs has no electron_${electronMajor}");

  openchamber-desktop = ocPkgs.callPackage "${patchedSrc}/nix/gui.nix" {
    self = patchedSrc;
    inherit version;
    opencodeCli = opencode-cli;
    src = openchamber.passthru.src;
    openchamberCore = openchamber.passthru.core;
    inherit electron;
  };
in
{
  openchamber = openchamber;
  openchamber-desktop = openchamber-desktop;
}
