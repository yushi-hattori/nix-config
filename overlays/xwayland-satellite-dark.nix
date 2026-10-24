# xwayland-satellite-dark — dark title bar for X11 (XWayland) windows.
#
# VLC runs on XWayland (it loads libqxcb, not the Wayland plugin), and
# xwayland-satellite draws its own title bar for X11 windows. That title bar is
# hardcoded white in src/server/decoration.rs and has no config option, so we
# patch the colors: dark bar + light title text, matching VLC's own dark
# toolbar/menu (33,33,33). Leaves the close-button square light so its black ×
# stays visible.
#
# To drop: remove this file from overlays/default.nix and the overlay list.
final: prev: {
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/server/decoration.rs \
        --replace-fail 'bar.fill(Color::WHITE);' \
                       'bar.fill(Color::from_rgba8(33, 33, 33, 255));' \
        --replace-fail 'paint.set_color(Color::WHITE);' \
                       'paint.set_color(Color::from_rgba8(33, 33, 33, 255));' \
        --replace-fail 'ColorU8::from_rgba(0, 0, 0, (coverage * 255.0) as u8)' \
                       'ColorU8::from_rgba(220, 220, 220, (coverage * 255.0) as u8)'
    '';
  });
}
