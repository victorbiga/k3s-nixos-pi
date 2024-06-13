{
  description = "NixOS Raspberry Pi configuration flake";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  outputs = { self, nixpkgs, nixos-hardware }: {
    # Function to create a k3s node configuration
    let
      createK3sNode = name: role: address: extraConfig: nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./common.nix
          ({ pkgs, ... }: {
            config = {
              networking = {
                hostName = name; # Define your hostname.
                interfaces.end0.ipv4.addresses = [{
                  address = address;
                  prefixLength = 24;
                }];
              };
              services.k3s = {
                enable = true;
                role = role;
                serverAddr = if role == "agent" then "https://192.168.50.177:6443" else null;
                extraFlags = if role == "server" then toString [ "--disable=traefik" ] else [];
              };
              extraConfig;
            };
          })
        ];
      };
    in
    {
      nixosConfigurations.kube-node-1 = createK3sNode "kube-node-1" "server" "192.168.50.177" {};
      nixosConfigurations.kube-node-2 = createK3sNode "kube-node-2" "agent" "192.168.50.178" {};
      nixosConfigurations.kube-node-3 = createK3sNode "kube-node-3" "agent" "192.168.50.179" {};
    };
  };
}
