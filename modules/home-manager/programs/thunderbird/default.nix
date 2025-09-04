{ userConfig, ... }:
{
  programs.thunderbird = {
    enable = true;
    profiles.${userConfig.name} = {
      isDefault = true;
    };
  };
}
