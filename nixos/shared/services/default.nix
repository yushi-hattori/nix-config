{
  imports = [
    ./framework-control.nix
    # ./openchamber.nix  # disabled: redundant with the desktop app (each spawns its own opencode server)
    ./auto-timezone.nix
    ./printing.nix
    ./tlp.nix
    ./ollama.nix
    ./sunshine.nix
    ./waydroid.nix
    ./nix-ld.nix
  ];
}
