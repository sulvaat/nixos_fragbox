# nixos_fragbox

NixOS flake configuration for **fragbox** — an AMD-based desktop running NixOS unstable with the Niri Wayland compositor.

## System

| | |
|---|---|
| Hostname | `fragbox` |
| CPU | AMD |
| GPU | AMD (RDNA, `0000:0e:00.0`) |
| Kernel | `linuxPackages_latest` |
| Compositor | [Niri](https://github.com/YaaSh/niri) (Wayland scrolling compositor) |
| Shell | Fish + Starship |
| Theme | Tokyo City Dark (via Stylix) |
| Fonts | JetBrainsMono Nerd Font / DejaVu |

## Structure

```
/etc/nixos/
├── flake.nix                   # Inputs: nixpkgs-unstable, home-manager, stylix, chaotic-nyx
├── configuration.nix           # System entrypoint — wires modules + Home Manager
├── home.nix                    # Home Manager entrypoint
├── hardware-configuration.nix  # Generated — do not edit
├── pano.jpg                    # Wallpaper (Stylix source image)
└── modules/
    ├── system/
    │   ├── audio.nix           # PipeWire
    │   ├── boot.nix            # systemd-boot, latest kernel, amdgpu early load
    │   ├── desktop.nix         # Xorg/amdgpu, Niri, picom, XDG portals, fonts
    │   ├── gaming.nix          # GameMode, Proton-GE, Gamescope, LACT, MangoHud, gpu-perf
    │   ├── hardware.nix        # OpenRazer, graphics (32-bit), Steam hardware
    │   ├── input-method.nix    # fcitx5 + Mozc (Japanese input)
    │   ├── networking.nix      # NetworkManager, firewall, Avahi, SSH
    │   ├── packages.nix        # System-wide packages
    │   ├── programs.nix        # Fish, Steam, AppImage, Flatpak
    │   ├── stylix.nix          # System theme, wallpaper, fonts
    │   ├── users.nix           # User accounts and groups
    │   └── virtualisation.nix  # libvirtd / virt-manager
    └── home/
        ├── input-method.nix    # fcitx5 profile seed (Mozc on first launch)
        ├── niri.nix            # Niri config (template substitution for Stylix colors)
        ├── niri/
        │   └── config.kdl.tmpl # Niri KDL config template
        ├── packages.nix        # Per-user packages
        ├── programs.nix        # Fuzzel, Ghostty, Kitty, Git, Yazi, Zoxide
        ├── services.nix        # SwayNC, swayidle, KDE Connect
        ├── shells.nix          # Fish, Bash, Starship; shell aliases
        ├── theming.nix         # GTK theme, icons, cursor (Tokyonight-Dark / Papirus)
        ├── waybar.nix          # Waybar status bar (template substitution)
        └── waybar/
            ├── config.json     # Waybar config template
            └── style.css.tmpl  # Waybar CSS template
```

## Usage

```fish
# Rebuild after config changes
rb     # nixos-rebuild switch --flake .#fragbox --sudo

# Update all flake inputs then rebuild
rbu    # nix flake update && nixos-rebuild switch --flake .#fragbox --sudo

# Garbage collect (keep last 3 generations)
gc
```

## Flake inputs

| Input | Channel |
|---|---|
| nixpkgs | `nixos-unstable` |
| home-manager | follows nixpkgs |
| stylix | follows nixpkgs |
| chaotic-nyx | `nyxpkgs-unstable` (provides `mesa-git`) |

---

## Changelog

### 2026-08-02 — Initial setup

**Migration from Sakuya**

Migrated the NixOS configuration from a separate Intel/AMD desktop (`Sakuya`) to this new AMD/AMD system (`fragbox`). The source repo is [sulvaat/nixOS_Sakuya](https://github.com/sulvaat/nixOS_Sakuya).

Adapted the following from the source config:

- **Hostname** changed from `Sakuya` → `fragbox`
- **`system.stateVersion`** updated from `25.05` → `26.05` to match this installation
- **GPU PCI slot** in `gaming.nix` updated from `0000:03:00.0` → `0000:0e:00.0` (confirmed via sysfs)
- **`modules/system/filesystems.nix` excluded** — source mount points (NFS share, game drives) do not exist on this machine
- **`hardware-configuration.nix` kept as generated** — AMD CPU (`kvm-amd`), btrfs root, different disk UUIDs
- **`users.nix`** added `networkmanager` group (was implicit in the old monolithic config)
- Replaced the stock KDE Plasma install config with the full modular flake structure from Sakuya

**Git and GitHub setup**

- Generated SSH key and added to GitHub account
- Transferred `/etc/nixos` ownership to user `sul` (standard pattern for user-managed flake configs — allows `nix flake update` and git to run without root)
- Initialized git repo, created [sulvaat/nixos_fragbox](https://github.com/sulvaat/nixos_fragbox) on GitHub, and pushed initial commit
