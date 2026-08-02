# Desktop: Niri (Wayland), portals, fonts. No display manager — boot to TTY,
# run `frag` to start the session.
{ config, lib, pkgs, ... }:
let
  # Launch script: starts a full Niri Wayland session from the TTY.
  frag = pkgs.writeShellScriptBin "frag" ''
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
