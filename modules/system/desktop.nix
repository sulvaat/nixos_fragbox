# Desktop: Niri (Wayland), portals, fonts. No display manager — boot to TTY,
# run `frag` to start the session.
{ config, lib, pkgs, ... }:
let
  # Launch script: splashes bloody QUAKE ASCII art then starts a Niri session.
  frag = pkgs.writeShellScriptBin "frag" ''
    R=$'\033[1;31m'
    D=$'\033[0;31m'
    F=$'\033[2;31m'
    N=$'\033[0m'

    clear
    printf "$R"
    cat << 'QUAKE'

      ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗███████╗
     ██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝██╔════╝
     ██║   ██║██║   ██║███████║█████╔╝ █████╗
     ██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ ██╔══╝
     ╚██████╔╝╚██████╔╝██║  ██║██║  ██╗███████╗
      ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
QUAKE
    printf "$D"
    cat << 'DRIP'
          ▓▓            ▓▓        ▓    ▓        ▓▓
           ▓             ▓       ▓▓    ▓▓         ▓
           ▓▓            ▓▓            ▓
                                       ▓▓
DRIP
    printf "$F"
    echo "                     FRAG OR BE FRAGGED"
    printf "$N\n"

    sleep 1
    exec niri-session
  '';
in
{
  # Niri (Wayland compositor). User config lives in modules/home/niri.nix.
  programs.niri.enable = true;
  programs.dconf.enable = true;

  # XDG desktop portals.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Remove nano (enabled by default in NixOS); nvim is the editor.
  programs.nano.enable = false;

  # System fonts.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    ipafont
  ];

  environment.systemPackages = [ frag ];
}
