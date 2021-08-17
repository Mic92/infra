{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../roles/common.nix
  ];

  # we use grub because systemd-boot sometimes fail on aarch64/EFI
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.version = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-community-build04";
  networking.hostId = "8daf74c0";

  networking.usePredictableInterfaceNames = false;
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    networks."ethernet".extraConfig = ''
      [Match]
      Type = ether
      [Network]
      DHCP = both
    '';
  };

  system.stateVersion = "21.11";
}

# partition guide
# sgdisk -n 1:0:+800M -N 2 -t 1:ef00 -t 2:8304 /dev/sda
# mkfs.vfat -b32 /dev/sda1
# zpool create zroot -O acltype=posixacl -O xattr=sa -O compression=lz4 /dev/sda2
# zfs create -o mountpoint=none zroot/root
# zfs create -o mountpoint=legacy zroot/root/nixos
# zfs create -o mountpoint=legacy zroot/root/home
# mount -t zfs zroot/root/nixos /mnt
# mkdir /mnt/{home,boot}
# mount -t zfs zroot/root/home /mnt/home
# mount /dev/sda1 /mnt/boot
