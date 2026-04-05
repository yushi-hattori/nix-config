{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Map Alt + Shift + Left Click to Middle Click
            # This keeps Alt and Shift working normally for everything else
            "alt+shift+leftmouse" = "middlemouse";
          };
        };
      };
    };
  };
}
