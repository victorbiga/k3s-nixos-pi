{ pkgs, ... }:

let
  k3sConfig = import ../shared/k3s-config.nix {
    inherit pkgs;
    role = "agent";  # Set the role for kube-node-4
  };
in
{
  imports = [ k3sConfig ];  # Import the K3s config for the agent

  config = {
    networking = {
      hostName = "kube-node-4";
      interfaces.end0.ipv4.addresses = [{
        address = "10.0.0.24";
        prefixLength = 24;
      }];
    };
  };
}
