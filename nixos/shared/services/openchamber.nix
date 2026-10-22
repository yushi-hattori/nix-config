# openchamber — web UI for OpenCode sessions.
#
# Runs the OpenChamber server (systemd service) on loopback; browse to
# http://127.0.0.1:3000. Runs as your user so it sees the same projects, ssh
# keys, and opencode config as a manual `nix run`. Module comes from the
# openchamber flake.
{ inputs, constants, ... }:
{
  imports = [ inputs.openchamber.nixosModules.openchamber ];

  services.openchamber = {
    enable = true;
    user = constants.user.name;
  };
}
