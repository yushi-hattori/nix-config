let
  user = {
    name = "yhattori";
    fullName = "Yushi Hattori";
    email = "yushi.t.hattori@gmail.com";
    gitKey = "0x6333B18ED1EDED4D";
    avatar = ./files/avatar/Apollo.jpg;
  };
in
{
  system = "x86_64-linux";
  stateVersion = "26.11";

  hostname = "framework13";
  user = user;

  # Repo root; the active flake lives here.
  nixConfigDir = "/home/${user.name}/nix-config";
}
