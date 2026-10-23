# dconf — GNOME-style desktop settings.
#
# Declares dark mode, the :close button layout, Nautilus list view and
# hidden-file visibility in the GTK file chooser. These used to only exist in
# the dconf database; declaring them means a fresh install gets them too.
{ lib, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-dark";
      "cursor-theme" = "Yaru";
      "font-name" = "Roboto 11";
      "icon-theme" = "Tela-circle-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = lib.mkForce ":close";
    };

    "org/gnome/nautilus/preferences" = {
      "default-folder-viewer" = "list-view";
      "migrated-gtk-settings" = true;
      "search-filter-time-type" = "last_modified";
      "search-view" = "list-view";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      "show-hidden" = true;
    };

    "org/gtk/settings/file-chooser" = {
      "show-hidden" = true;
    };
  };
}
