# Bootloader and kernel.
{ config, lib, pkgs, ... }:
{
  # systemd-boot (EFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Load the AMD GPU module early.
  boot.initrd.kernelModules = [ "amdgpu" ];
}
