# scripts — custom bin scripts.
#
# Sources ./bin into ~/.local/bin (on PATH). Individual scripts:
#   fif, fkill, git-reset, ocr, cd-to-project, pull-all, screen-recorder.
{ pkgs, ... }:
{
  home.file = {
    ".local/bin" = {
      recursive = true;
      source = ./bin;
    };
  };

  # screen-recorder needs wf-recorder (+ slurp, installed system-wide).
  home.packages = [ pkgs.wf-recorder ];
}
