{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
    config = {
      # Use high quality video output profile
      profile = "gpu-hq";
      # Keep the player open after finishing playback
      keep-open = "yes";
      # Display time and duration in OSD
      osd-level = 1;
      # Save playback position on quit
      save-position-on-quit = "yes";
    };
  };

  # Enable catppuccin theming for mpv.
  catppuccin.mpv.enable = true;
}
