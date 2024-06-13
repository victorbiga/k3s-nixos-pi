{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Vilnius";
  i18n.defaultLocale = "en_US.UTF-8";

  # User
  users.users.victor = {
    hashedPassword = builtins.readFile ./victor-password.txt; # Externalize password
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = builtins.readFile ./victor-ssh-key.txt; # Externalize SSH key
  };
  users.users.root = {
    hashedPassword = builtins.readFile ./root-password.txt; # Externalize password
    openssh.authorizedKeys.keys = builtins.readFile ./root-ssh-key.txt; # Externalize SSH key
  };

  services.openssh.enable = true;
  journald.console = "/dev/tty6";

  security.sudo.wheelNeedsPassword = false;

  systemd.services.k3s.path = [ pkgs.ipset ];

  system.stateVersion = "23.05";

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 6443 10250 10251 ];
      allowedUDPPorts = [ 8472 ];
    };
    useDHCP = false;
    defaultGateway = "192.168.50.1";
    nameservers = [ "192.168.50.215" ];
    interfaces.end0.useDHCP = false;
  };

  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    kernelPackages = pkgs.linuxPackages_rpi4;
    initrd.availableKernelModules = pkgs.lib.mkForce [ "sdhci_pci" "xhci-pci-renesas" "reset-raspberrypi" "ext2" "ext4" ];
    initrd.supportedFilesystems = pkgs.lib.mkForce [ "ext4" ];
    supportedFilesystems = pkgs.lib.mkForce [ "ext4" ];
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];
    kernelModules = [ "ceph" "rbd" ];
  };

  environment.systemPackages = [ pkgs.git ];
  
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
