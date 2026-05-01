{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
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

  xdg.configFile."zed/settings.json".source = ./settings.json;
  xdg.configFile."zed/keymap.json".source = ./keymap.json;
  xdg.configFile."zed/tasks.json".source = ./tasks.json;
}
