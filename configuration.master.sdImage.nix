{
            # Time, keyboard language, etc
            time.timeZone = "Europe/Vilnius";
            i18n.defaultLocale = "en_US.UTF-8";

            # User
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

            security.sudo.wheelNeedsPassword = false;

            # Allow ssh in
            services.openssh.enable = true;

            system = {
              stateVersion = "23.05";
            };

            boot.loader.grub.enable = false;
            # Enables the generation of /boot/extlinux/extlinux.conf
            boot.loader.generic-extlinux-compatible.enable = true;

            networking.hostName = "kube-node-1"; # Define your hostname.
            networking.useDHCP = false;
            networking.defaultGateway = "192.168.50.1";
            networking.nameservers = [ "192.168.50.215" ];
            networking.interfaces.end0.useDHCP = false;
            networking.interfaces.end0.ipv4.addresses = [{
              address = "192.168.50.177";
              prefixLength = 24;
            }];
            appstream.enable = false;
            boot.bcache.enable = false;
            boot.initrd.availableKernelModules = nixpkgs.lib.mkForce [ "sdhci_pci" "xhci-pci-renesas" "reset-raspberrypi" "ext2" "ext4" ];
            boot.initrd.supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
            boot.kernelPackages = pkgs.linuxPackages_rpi4;
            boot.supportedFilesystems = nixpkgs.lib.mkForce [ "ext4" ];
            environment.defaultPackages = nixpkgs.lib.mkForce [ ];
            environment.systemPackages = nixpkgs.lib.mkForce [ ];
            hardware.enableRedistributableFirmware = true;
            security.pam.services.su.forwardXAuth = nixpkgs.lib.mkForce false;
            services.logrotate.enable = nixpkgs.lib.mkForce false;
            system.disableInstallerTools = true;
            system.nssModules = nixpkgs.lib.mkForce [ ];
            nix = {
              package = pkgs.nixFlakes;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

}
