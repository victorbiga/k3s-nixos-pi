{ pkgs, lib, ... }:

let
  k3sConfig = import ../shared/k3s-config.nix {
    inherit pkgs;
    role = "agent";
  };
in
{
  imports = [ k3sConfig ];

  config = {

    networking = {
      hostName = "kube-node-5";
      interfaces.end0.ipv4.addresses = [{
        address = "10.0.0.25";
        prefixLength = 24;
      }];
    };
  };
}
