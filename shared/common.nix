{ config, pkgs, ... }:

{
  # Localization
  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users configuration
  users = {
    defaultUserShell = pkgs.zsh;

    # Victor user
    users.victor = {
      hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
      ];
    };

    # Root user
    users.root = {
      hashedPassword = "$6$1x45qQgJwmCXXhbh$RQrnocus1l1NbKMbL17/9HyQ8RBarb.W33JBAQMjXZWBSs0YGsJBGljzHDJGMrs0KRp7gjiE8rgKbJfbYZlS50";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBq97CF4uE2oCUpEG4XNvwyGh8JUZnoNTHLTxnp6ZyDZyYs/sKqbmV9yCVXE4FGgWodVSZMDXN+Gi8x6wXt8D9E3AMCXecD1oGEwneYKaEb1FmOn9TySUpdo5nC4RATbEEbVWBtjPLuqm9LssHtzvw7i61AvrQpzgYjRPKrwakPHhtGFKZc9PjbGe0NmH0z4JDOEUvfzcK8uZkTPjvaSSF5zVtpa/1mMs2QApwZBmmSusJNmDgftZl5y/FInPUwnzs+5NPJCNwzywFKkrDYWuIHfygMDpuIcKPuyAOE3MOBmpw5V5JVmRQ/YaDUV1xhKrsn70WPsN3sSCNiaqe9UVdzv2uMZ34wweWJrWhBB0rZAXXhm7X1JsK+s5QdAYGAkiLAm5fJu5tv7vSWmdaQwhl/4FjebzE80+nLNn00zQmTSeMjEA29+4GN+QtunclshFWarc/Uwi12e1zGsHgv1T/UXI7aIXOgr5Q+LFVmyKIn7+9wh85MmZA3X25w19l+Zc= victor@Victors-MacBook-Pro.local"
      ];
    };
  };

  # Services
  services = {
    openssh.enable = true;
    journald.console = "/dev/tty6";
    openiscsi = {
      enable = true;
      name = "${config.networking.hostName}";
    };
    rpcbind.enable = true;
    k3s = {
      enable = true;
      tokenFile = "/etc/k3s/token";
    };
  };

  # Security
  security.sudo.wheelNeedsPassword = false;

  # System settings
  system = {
    stateVersion = "24.05";
    autoUpgrade = {
      enable = true;
      flake = "github:victorbiga/k3s-nixos-pi";
      dates = "11:00";
    };
  };

  # Networking
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 6443 10250 10251 9100 ];
      allowedUDPPorts = [ 8472 ];
    };
    useDHCP = false;
    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.0.1" ];
    interfaces.end0.useDHCP = false;
  };

  # Boot settings
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true; # Enables the generation of /boot/extlinux/extlinux.conf
    };
    kernelPackages = pkgs.linuxPackages_rpi4;
    initrd = {
      availableKernelModules = pkgs.lib.mkForce [ "sdhci_pci" "xhci-pci-renesas" "reset-raspberrypi" "ext2" "ext4" ];
      supportedFilesystems = pkgs.lib.mkForce [ "ext4" ];
    };
    supportedFilesystems = pkgs.lib.mkForce [ "ext4" "nfs" ];
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];
    kernelModules = [ "rbd" ];
  };

  # Environment settings
  environment = {
    systemPackages = with pkgs; [
      git
      nfs-utils
      libraspberrypi
      htop
      fzf
    ];

    variables.PATH = [
      "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    ];
  };

  # Programs configuration
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "fzf" ];
      };
    };
    neovim = {
      defaultEditor = true;
      enable = true;
      vimAlias = true;
      viAlias = true;
    };
  };

  # Nix configuration
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Systemd settings
  systemd.services.k3s.path = [ pkgs.ipset ];
}
