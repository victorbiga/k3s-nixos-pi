{
  description = "NixOS Raspberry Pi configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, nixos-hardware, raspberry-pi-nix }: {
    # Helper function to generate NixOS configurations for nodes
    mkNode4 = nodeConfig: nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";  # Architecture defined once
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        "${nixpkgs}/nixos/modules/profiles/minimal.nix"
        ./shared/common.nix  # Common configurations for all nodes
        ./shared/rpi4.nix  # Common configurations for all nodes
        nodeConfig  # Specific node configuration
      ];
    };
    mkNode5 = nodeConfig: nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";  # Architecture defined once
      modules = [
        raspberry-pi-nix.nixosModules.raspberry-pi
        "${nixpkgs}/nixos/modules/profiles/minimal.nix"
        ./shared/common.nix  # Common configurations for all nodes
        ./shared/rpi5.nix
        nodeConfig  # Specific node configuration
      ];
    };

    nixosConfigurations = {
      # Node configurations using the mkNode helper function
      kube-node-1 = self.mkNode4 ./nodes/kube-node-1.nix;
      kube-node-2 = self.mkNode4 ./nodes/kube-node-2.nix;
      kube-node-3 = self.mkNode4 ./nodes/kube-node-3.nix;
      kube-node-4 = self.mkNode4 ./nodes/kube-node-4.nix;
      kube-node-5 = self.mkNode5 ./nodes/kube-node-5.nix;
      kube-node-6 = self.mkNode5 ./nodes/kube-node-6.nix;
    };
  };
}
