# Two boot modes, toggled with `fragmode console|quakecon`:
#
#   quakecon (base system): boot to TTY, password login, `frag` starts Niri.
#   console (specialisation): Steam Machine behaviour for the living-room TV.
#     Autologin straight into Steam's gaming mode (Jovian-NixOS), "Switch to
#     Desktop" drops into Niri, and quitting Niri returns to gaming mode.
#     HDMI-CEC through a Pulse-Eight USB-CEC adapter (AMD GPUs don't wire CEC):
#     TV remote drives Steam as a keyboard, and the TV and PC wake each other.
#
# Both modes are in the boot menu; `fragmode` just picks the default entry.
{ config, lib, pkgs, ... }:
let
  stateFile = "/var/lib/fragbox/mode";

  pulse8-cec = config.boot.kernelPackages.callPackage ../../pkgs/pulse8-cec.nix { };

  fragmode = pkgs.writeShellScriptBin "fragmode" ''
    set -euo pipefail
    profile=/nix/var/nix/profiles/system
    running=$(cat /etc/fragbox-mode)
    next=$(cat ${stateFile} 2>/dev/null || echo quakecon)

    set_boot_default() {
      case "$1" in
        console)  sudo "$profile/specialisation/console/bin/switch-to-configuration" boot ;;
        quakecon) sudo "$profile/bin/switch-to-configuration" boot ;;
      esac
    }

    case "''${1:-status}" in
      status)
        echo "running:   $running"
        echo "next boot: $next"
        ;;
      console|quakecon)
        echo "$1" | sudo tee ${stateFile} >/dev/null
        set_boot_default "$1"
        echo "next boot: $1"
        if [ "$1" != "$running" ]; then
          read -rp "Reboot now? [y/N] " answer
          [[ $answer == [yY]* ]] && systemctl reboot
        fi
        ;;
      # Re-point the boot menu default at the chosen mode (after gc prunes).
      boot)
        set_boot_default "$next"
        ;;
      # rb/rbu: rebuild without losing the chosen mode. Switch live only when
      # already running that mode; otherwise stage it for the next boot.
      rebuild)
        shift
        if [ "$next" = "$running" ]; then
          spec=()
          [ "$next" = console ] && spec=(--specialisation console)
          exec nixos-rebuild switch --flake /etc/nixos --sudo "''${spec[@]}" "$@"
        fi
        nixos-rebuild boot --flake /etc/nixos --sudo "$@"
        set_boot_default "$next"
        ;;
      *)
        echo "usage: fragmode [status|console|quakecon]" >&2
        exit 1
        ;;
    esac
  '';
in
{
  environment.etc."fragbox-mode".text = "quakecon";
  environment.systemPackages = [ fragmode ];
  systemd.tmpfiles.rules = [ "d /var/lib/fragbox 0755 root root -" ];

  specialisation.console.configuration = {
    system.nixos.tags = [ "console" ];
    environment.etc."fragbox-mode".text = lib.mkForce "console";

    jovian.steam = {
      enable = true;
      autoStart = true;
      user = "sul";
      desktopSession = "niri";
    };
    jovian.hardware.has.amd.gpu = true;
    # Valve's Steam Deck kernel cmdline (amd_iommu=off, audit=0, ...) is tuned
    # for the Deck APU, not a desktop.
    jovian.steamos.enableDefaultCmdlineConfig = false;
    # udiskie (home/services.nix) already automounts USB drives.
    jovian.steamos.enableAutoMountUdevRules = false;

    # HDMI-CEC: kernel driver + SteamOS's cecd (enabled by Jovian's SteamOS
    # config). persistent_config stores the CEC setup in the adapter's EEPROM so
    # it keeps answering the TV while the PC sleeps, and wakes the PC over USB.
    boot.extraModulePackages = [ pulse8-cec ];
    boot.extraModprobeConfig = "options pulse8-cec persistent_config=1";
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2548", ATTR{idProduct}=="100[12]", ATTR{power/wakeup}="enabled"
    '';
    # Defaults; Steam's own HDMI-CEC setting can override them per user.
    environment.etc."cecd/config.toml".text = ''
      osd_name = "fragbox"
      wake_tv = true
    '';
  };
}
