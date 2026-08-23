{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      theme = {
        mode = "system";
        dark = "Ayu Dark";
        light = "Ayu Light";
      };
      hour_format = "hour24";
      vim_mode = true;
      ui_font_size = 16;
      buffer_font_size = 14;
      terminal = {
        font_family = "JetBrainsMono Nerd Font";
        font_size = 14;
        default_height = 9999;
      };
      format_on_save = "on";
    };
    extensions = [
      "nix"
      "toml"
      "rust"
      "lua"
      "python"
      "terraform"
      "bash"
      "dockerfile"
      "yaml"
      "go"
      "html"
      "json"
    ];
  };

  xdg.configFile."zed/keymap.json".source = ./keymap.json;
  xdg.configFile."zed/tasks.json".source = ./tasks.json;
}
