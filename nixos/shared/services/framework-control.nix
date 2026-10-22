# framework-control — Framework fan/power/charging control.
#
# Local service with a web UI to tweak fans (auto/manual/curve), power profiles
# (AMD P-State EPP / cpufreq), and battery charge limits. Ships in nixpkgs, so
# no flake input is needed — just enable the service.
{ ... }:
{
  services.framework-control.enable = true;
}
