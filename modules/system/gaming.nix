# Gaming: GameMode, declarative Proton-GE, and AMD GPU control/monitoring.
# GPU is AMD; the Vulkan driver is RADV from Mesa (do NOT add amdvlk — RADV is
# the better path for gaming). Steam itself is enabled in ./programs.nix; the
# option below merges into that config.
{ config, lib, pkgs, ... }:
let
  # Force the AMD GPU to its high performance level for the lifetime of a game,
  # restoring `auto` on exit. amdgpu's `auto` governor can stop boosting
  # mid-session and park the card at reduced clocks. `high` pins max clocks and
  # overrides the governor so the stall can't happen.
  #
  # This runs entirely as the user: the udev rule below makes the sysfs knob
  # group-writable, so no root/polkit is involved.
  #
  # GPU PCI slot on fragbox: 0000:0e:00.0 (verify with: lspci | grep -i vga)
  # Wrap the WHOLE launch command in Steam options, e.g.:
  #   gpu-perf gamescope -W 1920 -H 1080 -r 144 -f --force-grab-cursor --mangoapp -- %command%
  gpuPerf = pkgs.writeShellScriptBin "gpu-perf" ''
    ppl=/sys/bus/pci/devices/0000:0e:00.0/power_dpm_force_performance_level
    restore() { echo auto > "$ppl" 2>/dev/null || true; }
    trap restore EXIT INT TERM
    echo high > "$ppl" 2>/dev/null || true
    "$@"
  '';
in
{
  # Feral GameMode: pins the CPU governor / renices while a game runs. Opt in
  # per game with `gamemoderun %command%`.
  programs.gamemode.enable = true;

  # Make /sys/.../power_dpm_force_performance_level group-writable by `users` so
  # the gpu-perf wrapper (above) can set `high`/`auto` without root.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="amdgpu", RUN+="${pkgs.coreutils}/bin/chgrp users %S%p/device/power_dpm_force_performance_level", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/device/power_dpm_force_performance_level"
  '';

  # Manage Proton-GE through the flake instead of protonup-ng.
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # Gamescope: a nested Wayland/Xwayland micro-compositor.
  programs.gamescope.enable = true;

  # RADV from Mesa main (via chaotic-nyx).
  chaotic.mesa-git.enable = true;

  # LACT: AMD GPU control (fan curves, power/clock limits) and monitoring.
  services.lact.enable = true;

  # Overlay + tooling: mangohud and goverlay.
  environment.systemPackages = with pkgs; [
    mangohud
    goverlay
    gpuPerf
  ];
}
