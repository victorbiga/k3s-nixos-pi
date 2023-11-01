{
  description = "NixOS Raspberry Pi configuration flake";
  inputs.nixos-hardware.url = "github:NixOS/nixpkgs/d82801fc943ca518efb7a913d89b4d2d8ee224ae";
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.kube-node-1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        (nixpkgs + "/nixos/modules/profiles/minimal.nix")
        ./common.nix
        ({ pkgs, ... }: {
          config = {
            services = {
              k3s = {
                role = "server";
              };
            };

            networking = {
              firewall = {
                allowedTCPPorts = [ 6443 ];
              };
              hostName = "kube-node-1"; # Define your hostname.
              interfaces.end0.ipv4.addresses = [{
                address = "192.168.50.177";
                prefixLength = 24;
              }];
            };
          };
        })
      ];
    };

    nixosConfigurations.kube-node-2 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        (nixpkgs + "/nixos/modules/profiles/minimal.nix")
        ./common.nix
        ({ pkgs, ... }: {
          config = {
            services = {
              k3s = {
                role = "agent";
                serverAddr = "https://192.168.50.177:6443";
              };
            };
            networking = {
              hostName = "kube-node-2"; # Define your hostname.
              interfaces.end0.ipv4.addresses = [{
                address = "192.168.50.178";
                prefixLength = 24;
              }];
            };
          };
        })
      ];
    };
    nixosConfigurations.kube-node-3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        (nixpkgs + "/nixos/modules/profiles/minimal.nix")
        ./common.nix
        ({ pkgs, ... }: {
          config = {
            services = {
              k3s = {
                role = "agent";
                serverAddr = "https://192.168.50.177:6443";
              };
            };
            networking = {
              hostName = "kube-node-3"; # Define your hostname.
              interfaces.end0.ipv4.addresses = [{
                address = "192.168.50.179";
                prefixLength = 24;
              }];
            };
          };
        })
      ];
    };
  };
}
