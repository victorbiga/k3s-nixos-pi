{ pkgs, ... }:

let
  k3sConfig = import ../shared/k3s-config.nix {
    inherit pkgs;
    role = "server";  # Set the role for kube-node-1
  };
in
{
  imports = [ k3sConfig ];  # Import the K3s config for the server

  config = {
    hardware.raspberry-pi."4".i2c1.enable = true;
    environment = {
      systemPackages = with pkgs; [
        go
        i2c-tools
      ];
    };
    networking = {
      hostName = "kube-node-1";
      interfaces.end0.ipv4.addresses = [{
        address = "10.0.0.21";
        prefixLength = 24;
      }];
    };
  };
}
