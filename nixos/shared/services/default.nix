{
  imports = [
    ./framework-control.nix
    # ./openchamber.nix  # disabled: stale bun-deps hash in the openchamber flake
    ./auto-timezone.nix
    ./printing.nix
    ./tlp.nix
    ./ollama.nix
    ./sunshine.nix
    ./kdeconnect.nix
    ./waydroid.nix
    ./nix-ld.nix
  ];
}
