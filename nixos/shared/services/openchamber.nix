# openchamber — web UI for OpenCode sessions.
#
# Runs the OpenChamber server (systemd service) on loopback; browse to
# http://127.0.0.1:3000. Runs as your user so it sees the same projects, ssh
# keys, and opencode config as a manual `nix run`.
#
# The package comes from the openchamber overlay (overlays/openchamber.nix),
# which rebuilds it with corrected fixed-output hashes while upstream's flake
# is out of sync.
{ inputs, constants, pkgs, ... }:
{
  imports = [ inputs.openchamber.nixosModules.openchamber ];

  services.openchamber = {
    enable = true;
    user = constants.user.name;
    package = pkgs.openchamber;
  };
}
