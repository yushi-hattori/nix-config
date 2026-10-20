# openchamber — web UI for OpenCode sessions.
#
# Provides `nixosModules.openchamber` (systemd service) plus `packages`
# (openchamber server + desktop GUI). Bundles its own pinned OpenCode 2.x CLI
# (separate from the top-level `opencode` input).
{ url = "github:openchamber/openchamber"; }
