{
  # Flake description
  description = "NixOS Raspberry Pi configuration flake";

  # Inputs (dependencies)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";  # Fetch Nixpkgs from GitHub
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";  # Fetch hardware support for Raspberry Pi
  };

  # Outputs section defines the NixOS configurations for multiple nodes
  outputs = { self, nixpkgs, nixos-hardware }: {
    # NixOS configurations for different kube-nodes
    nixosConfigurations = {
      # Configuration for kube-node-1
      kube-node-1 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";  # Target architecture (Raspberry Pi)
        modules = [
          # Use the standard SD card image for Raspberry Pi
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          # Include Raspberry Pi 4 hardware support
          nixos-hardware.nixosModules.raspberry-pi-4
          # Minimal NixOS profile
          (nixpkgs + "/nixos/modules/profiles/minimal.nix")
          # Common configurations shared by all nodes
          ./common.nix
          # Node-specific configuration
          ({ pkgs, ... }: {
            config = {
              # K3s server configuration
              services.k3s = {
                role = "server";
                extraFlags = toString [
                  "--disable=traefik"  # Disable the default Traefik Ingress controller
                ];
              };
              # Networking configuration
              networking = {
                hostName = "kube-node-1";  # Hostname for the first node
                interfaces.end0.ipv4.addresses = [{
                  address = "10.0.0.21";  # Static IP for kube-node-1
                  prefixLength = 24;
                }];
              };
            };
          })
        ];
      };

      # Configuration for kube-node-2
      kube-node-2 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";  # Target architecture (Raspberry Pi)
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          (nixpkgs + "/nixos/modules/profiles/minimal.nix")
          ./common.nix
          ({ pkgs, ... }: {
            config = {
              # K3s agent configuration (connects to the server)
              services.k3s = {
                role = "agent";
                serverAddr = "https://10.0.0.21:6443";  # Point to the server (kube-node-1)
              };
              # Networking configuration
              networking = {
                hostName = "kube-node-2";  # Hostname for the second node
                interfaces.end0.ipv4.addresses = [{
                  address = "10.0.0.22";  # Static IP for kube-node-2
                  prefixLength = 24;
                }];
              };
            };
          })
        ];
      };

      # Configuration for kube-node-3
      kube-node-3 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";  # Target architecture (Raspberry Pi)
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          (nixpkgs + "/nixos/modules/profiles/minimal.nix")
          ./common.nix
          ({ pkgs, ... }: {
            config = {
              # K3s agent configuration (connects to the server)
              services.k3s = {
                role = "agent";
                serverAddr = "https://10.0.0.21:6443";  # Point to the server (kube-node-1)
              };
              # Networking configuration
              networking = {
                hostName = "kube-node-3";  # Hostname for the third node
                interfaces.end0.ipv4.addresses = [{
                  address = "10.0.0.23";  # Static IP for kube-node-3
                  prefixLength = 24;
                }];
              };
            };
          })
        ];
      };

      # Configuration for kube-node-4
      kube-node-4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";  # Target architecture (Raspberry Pi)
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          (nixpkgs + "/nixos/modules/profiles/minimal.nix")
          ./common.nix
          ({ pkgs, ... }: {
            config = {
              # K3s agent configuration (connects to the server)
              services.k3s = {
                role = "agent";
                serverAddr = "https://10.0.0.21:6443";  # Point to the server (kube-node-1)
              };
              # Networking configuration
              networking = {
                hostName = "kube-node-4";  # Hostname for the fourth node
                interfaces.end0.ipv4.addresses = [{
                  address = "10.0.0.24";  # Static IP for kube-node-4
                  prefixLength = 24;
                }];
              };
            };
          })
        ];
      };
    };
  };
}
