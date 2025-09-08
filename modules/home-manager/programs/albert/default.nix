{
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (!pkgs.stdenv.isDarwin) {
    # Albert package
    home.packages = [ pkgs.albert ];

    # Source albert configuration from the home-manager store
    xdg.configFile."albert/config".text = ''
      [General]
      telemetry=false

      [application]
      enabled=true

      [applications]
      enabled=true

      [caffeine]
      enabled=false

      [calculator_qalculate]
      enabled=true

      [chromium]
      enabled=false

      [clipboard]
      enabled=true
      history_length=25
      persistent=false

      [datetime]
      enabled=true
      show_date_on_empty_query=true

      [files]
      enabled=true

      [github]
      enabled=false

      [hash]
      enabled=false

      [mediaremote]
      enabled=true

      [path]
      enabled=true

      [snippets]
      enabled=false

      [spotify]
      enabled=true

      [ssh]
      enabled=false

      [system]
      enabled=true

      [timer]
      enabled=true

      [timezones]
      enabled=false

      [vpn]
      enabled=false

      [websearch]
      enabled=true

      [widgetsboxmodel]
      alwaysOnTop=true
      clearOnHide=true
      clientShadow=true
      displayScrollbar=false
      followCursor=true
      hideOnFocusLoss=true
      historySearch=true
      itemCount=5
      quitOnClose=false
      showCentered=true
      systemShadow=true

      [widgetsboxmodel-ng]
      alwaysOnTop=true
      clearOnHide=false
      displayScrollbar=false
      followCursor=true
      hideOnFocusLoss=true
      historySearch=true
      itemCount=10
      quitOnClose=false
      showCentered=true
    '';
  };
}
