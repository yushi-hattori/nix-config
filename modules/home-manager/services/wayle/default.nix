{ pkgs, ... }:
# put this directly into your home-manager config or into a home-manager import
{
  services.wayle = {
    enable = true;

    # Whether to automatically install soft dependencies used by wayle that
    # will be required based on your config.
    autoInstallDependencies = true;

    # tip: you can automatically translate your TOML config to Nix by running
    # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
    settings = {
      bar = {
        layout = [
          # add more attribute sets with different monitors if wayle should
          # have different layouts on each
          {
            monitor = "*"; # replace "DP-1" with "*" for all monitors
            show = true;
            center = [
              "clock"
              "weather"
            ];
            left = [ "dashboard" ];
            right = [ "volume" ];
          } # this is a 'list' of 'attribute sets', no semi-colons after the closing braces needed
        ];
      };
      modules = {
        clock = {
          format = "%H:%M:%S";
          dropdown-show-seconds = false;
        };
        weather = {
          location = "Denver";
          units = "imperial";
        };
      };
      osd = {
        monitor = "*";
      };
      styling = {
        palette = {
          bg = "#282a36";
          blue = "#8be9fd";
          # ...
        };
        # wallust will be automatically installed if this is set
        theme-provider = "wallust";
      };
      # the following wallpaper option can be omitted if you're not using
      # wayle's wallpaper engine
      wallpaper = {
        # this will automatically install aww
        engine-enabled = true;

        cycling-directory = "~/nix-config/files/wallpaper/";
        cycling-mode = "shuffle";
      };
    };
  };
}
