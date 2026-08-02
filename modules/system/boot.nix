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

  # The motherboard exposes a TPM in ACPI (MSFT0101) but the tpm_crb_acpi
  # driver fails to probe it (firmware bug: ACPI region doesn't cover the full
  # CRB buffer, -EBUSY). The kernel reports "No TPM chip found" and never
  # creates /dev/tpm0 or /dev/tpmrm0.
  #
  # Two waits are involved:
  # 1. initrd systemd: suppressed by boot.initrd.systemd.tpm2.enable = false
  # 2. main systemd: tpm2.target unconditionally Wants= both TPM device nodes
  #    and sits before sysinit.target, so masking it cuts the 90s device wait.
  boot.initrd.systemd.tpm2.enable = false;
  systemd.targets.tpm2.enable = false;
}
