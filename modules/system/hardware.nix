# Hardware: GPU, peripherals, controllers.
{ config, lib, pkgs, ... }:
{
  # Graphics (AMD), with 32-bit support for games. The Vulkan driver is RADV
  # (shipped with Mesa) — no extraPackages needed. Intentionally NOT using
  # amdvlk: RADV is the faster, better-supported path for gaming.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Steam hardware udev rules (Steam Controller 2015 + 2026 receiver, PS5
  # DualSense, Nintendo Switch Pro, etc.).
  hardware.steam-hardware.enable = true;

  # uinput: lets sc-controller expose the Steam Controller as a standard
  # gamepad to emulators (RetroArch, Dolphin, Pegasus) when Steam isn't
  # running. Also needed by any tool that creates virtual input devices.
  hardware.uinput.enable = true;

  # udisks2: D-Bus daemon that lets unprivileged users mount/unmount removable
  # media. udiskie (home/services.nix) watches udisks2 events and auto-mounts
  # USB drives under /run/media/$USER/ on insertion.
  services.udisks2.enable = true;
}
