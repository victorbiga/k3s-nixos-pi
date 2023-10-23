{
  description = "NixOS Raspberry Pi configuration flake";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        nixos-hardware.nixosModules.raspberry-pi-4
        (nixpkgs + "/nixos/modules/profiles/minimal.nix")
        ({ pkgs, ... }: {
          config = {
            # Time, keyboard language, etc
            time.timeZone = "Europe/Amsterdam";
            i18n.defaultLocale = "en_US.UTF-8";

            # Programs
            programs.zsh = {
              enable = true;
              ohMyZsh = {
                enable = true;
                theme = "bira";
              };
            };
  
            # Users
            users.users.victor = {
              isNormalUser = true;
              extraGroups = [
                "wheel"
              ];
              openssh.authorizedKeys.keys = [
	      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
              password = "redacted";
            };
            users.users.root = {
              openssh.authorizedKeys.keys = [
	      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
              ];
            };

            # Allow ssh in
            services = {
              openssh.enable = true;
              k3s.enable = true;
              k3s.role = "server";
            };

            system = {
              stateVersion = "23.05";
              disableInstallerTools = true;
            };

            security = {
              sudo.wheelNeedsPassword = false;
            };

            boot.loader = {
              grub.enable = false;
              # Enables the generation of /boot/extlinux/extlinux.conf
              generic-extlinux-compatible.enable = true;
            };

            networking = {
              hostName = "master";
              useDHCP = false;
              defaultGateway = "192.168.50.1";
              nameservers = [ "192.168.50.215" ];
              interfaces = {
                eth0.useDHCP = false;
                eth0.ipv4.addresses = [{
                  address = "192.168.50.177";
                  prefixLength = 24;
             }];
             
            environment.defaultPackages = [];

              hardware.enableRedistributableFirmware = true;
            #boot.kernelPackages = pkgs.linuxKernel.kernels.linux_rpi4;
              # Fix missing modules
  # https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
          };
        });
      ];
    };
  };
}
