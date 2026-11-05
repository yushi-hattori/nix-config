# Spotify — music.
#
# Force Spotify onto X11 (XWayland) instead of Ozone-Wayland. Spotify is a
# Chromium/CEF app: on Wayland it draws its own client-side title bar, tinted
# from the GTK3 accent (Materia-dark's blue #8ab4f8), with no way to theme it.
# On X11, xwayland-satellite draws the title bar instead — which we've patched
# dark (overlays/xwayland-satellite-dark.nix) — so it matches VLC.
#
# nixpkgs' spotify wrapper unsets DISPLAY when NIXOS_OZONE_WL=1 to force
# Wayland; we unset NIXOS_OZONE_WL and pass --ozone-platform=x11 to override.
{ pkgs, ... }:
let
  spotify-x11 = pkgs.symlinkJoin {
    name = "spotify-x11";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/spotify
      makeWrapper ${pkgs.spotify}/bin/spotify $out/bin/spotify \
        --unset NIXOS_OZONE_WL \
        --add-flags "--ozone-platform=x11"
    '';
    meta = pkgs.spotify.meta // {
      mainProgram = "spotify";
    };
  };
in
{
  home.packages = [ spotify-x11 ];
}
