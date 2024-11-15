{ config, pkgs, ... }:

{
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
}
