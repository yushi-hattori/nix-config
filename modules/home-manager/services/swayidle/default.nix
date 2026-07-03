{ pkgs, ... }:
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 900; # 15 minutes
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
