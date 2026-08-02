# GTK theming (icons, cursor, dark preference).
# GTK theme itself is handled by Stylix (stylix.polarity = "dark" in
# modules/system/stylix.nix) — no manual theme package needed here.
{ config, pkgs, lib, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Advertise a dark color-scheme through the freedesktop appearance portal
  # (served by xdg-desktop-portal-gtk). This is what Electron/Chromium, Qt6 and
  # libadwaita apps query to decide dark vs light — gtk-application-prefer-dark
  # alone doesn't reach them. Merges into the interface block the gtk module
  # already populates.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
