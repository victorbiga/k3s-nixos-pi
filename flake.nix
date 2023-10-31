{
  description = "NixOS Raspberry Pi configuration flake";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.kube-node-1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        (nixpkgs + "/nixos/modules/profiles/minimal.nix")
        ({ pkgs, ... }: {
          config = {
            # Time, keyboard language, etc
            time.timeZone = "Europe/Vilnius";
            i18n.defaultLocale = "en_US.UTF-8";

            # User
            users.users.victor = {
              hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
              isNormalUser = true;
              extraGroups = [
                "wheel"
              ];
              openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
            };
            users.users.root = {
              hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
              openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
            };

            security = {
              sudo.wheelNeedsPassword = false;
            };

            services = {
              openssh.enable = true;
              journald.console = "/dev/tty6";
              k3s = {
                enable = true;
                role = "server";
              };
            };

            system = {
              stateVersion = "23.05";
            };

            networking = {
              hostName = "kube-node-1"; # Define your hostname.
              useDHCP = false;
              defaultGateway = "192.168.50.1";
              nameservers = [ "192.168.50.215" ];
              interfaces.end0.useDHCP = false;
              interfaces.end0.ipv4.addresses = [{
                address = "192.168.50.177";
                prefixLength = 24;
              }];
            };

            boot = {
              loader.grub.enable = false;
              # Enables the generation of /boot/extlinux/extlinux.conf
              loader.generic-extlinux-compatible.enable = true;
              kernelPackages = pkgs.linuxPackages_rpi4;
              initrd.availableKernelModules = nixpkgs.lib.mkForce [ "sdhci_pci" "xhci-pci-renesas" "reset-raspberrypi" "ext2" "ext4" ];
              initrd.supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
              supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
              kernelParams = [
                "cgroup_enable=cpuset" "cgroup_memory=1" "cgroup_enable=memory"
              ];
            };
            environment.systemPackages = [ pkgs.git ];
            nix = {
              package = pkgs.nixFlakes;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
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
        ({ pkgs, ... }: {
          config = {
            # Time, keyboard language, etc
            time.timeZone = "Europe/Vilnius";
            i18n.defaultLocale = "en_US.UTF-8";

            # User
            users.users.victor = {
              hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
              isNormalUser = true;
              extraGroups = [
                "wheel"
              ];
              openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
            };
            users.users.root = {
              hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
              openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
            };

            security = {
              sudo.wheelNeedsPassword = false;
            };

            services = {
              openssh.enable = true;
              journald.console = "/dev/tty6";
              k3s = {
                enable = true;
                role = "agent";
                serverAddr = "192.168.50.177";
              };
            };

            system = {
              stateVersion = "23.05";
            };

            networking = {
              hostName = "kube-node-2"; # Define your hostname.
              useDHCP = false;
              defaultGateway = "192.168.50.1";
              nameservers = [ "192.168.50.215" ];
              interfaces.end0.useDHCP = false;
              interfaces.end0.ipv4.addresses = [{
                address = "192.168.50.178";
                prefixLength = 24;
              }];
            };

            boot = {
              loader.grub.enable = false;
              # Enables the generation of /boot/extlinux/extlinux.conf
              loader.generic-extlinux-compatible.enable = true;
              kernelPackages = pkgs.linuxPackages_rpi4;
              initrd.availableKernelModules = nixpkgs.lib.mkForce [ "sdhci_pci" "xhci-pci-renesas" "reset-raspberrypi" "ext2" "ext4" ];
              initrd.supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
              supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
              kernelParams = [
                "cgroup_enable=cpuset" "cgroup_memory=1" "cgroup_enable=memory"
              ];
            };
            environment.systemPackages = [ pkgs.git ];
            nix = {
              package = pkgs.nixFlakes;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };
          };
        })
      ];
    };
  };
}

