{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # When alt is held, it switches to the 'alt_layer'
            alt = "layer(alt_layer)";
          };
          alt_layer = {
            # In this layer, left mouse button becomes middle mouse button
            leftmouse = "middlemouse";
          };
        };
      };
    };
  };
}
