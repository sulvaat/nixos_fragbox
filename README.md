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
    │   ├── boot.nix            # systemd-boot, latest kernel, amdgpu early load, TPM workaround
    │   ├── desktop.nix         # Niri, XDG portals, fonts, `frag` TTY launcher
    │   ├── gaming.nix          # GameMode, Proton-GE, Gamescope, LACT, MangoHud, gpu-perf
    │   ├── hardware.nix        # Graphics (32-bit), Steam hardware
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
        ├── theming.nix         # GTK icons, cursor (Papirus / Bibata); theme via Stylix
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

---

### 2026-08-02 — Post-migration fixes and tuning

**nixpkgs breakage: `tokyonight-gtk-theme` removed**

`tokyonight-gtk-theme` was removed from nixpkgs (depended on `gtk-engine-murrine`, itself removed due to GTK 2). Dropped the manual GTK theme from `modules/home/theming.nix` and let Stylix generate the GTK theme from the Tokyo City Dark base16 scheme instead. Icons (Papirus-Dark) and cursor (Bibata-Modern-Ice) are unchanged.

**Ghostty theme name fix**

Ghostty's bundled catppuccin theme is named `"Catppuccin Macchiato"` (capital letters, space-separated) not `"catppuccin-macchiato"`. Fixed in `modules/home/programs.nix`.

**Boot hang: 3-minute TPM timeout**

The motherboard exposes a TPM chip in ACPI (`MSFT0101`) but the `tpm_crb_acpi` kernel driver fails to probe it (firmware bug: ACPI memory region doesn't cover the full CRB buffer, `-EBUSY`). With no `/dev/tpm0` or `/dev/tpmrm0` ever appearing, systemd waited 90 seconds per device across two boot phases (~3 minutes total):

- *initrd phase*: suppressed with `boot.initrd.systemd.tpm2.enable = false`
- *main system phase*: `tpm2.target` unconditionally `Wants=` both TPM device nodes and sits before `sysinit.target`. Fixed by setting `systemd.targets.tpm2.enable = false` to mask the target entirely.

**TTY boot + `frag` launcher**

Removed LightDM (auto-enabled by `services.xserver.enable = true`) in favour of booting directly to TTY. Also removed `services.picom` (X11-only compositor) and `services.libinput` (X11 input config; Niri drives libinput directly). Running `frag` from the TTY starts a Niri Wayland session via `niri-session`.

The `frag` command displays a bloody red QUAKE ASCII art splash with blood drip characters and a 1-second pause before handing off to the compositor.

**Niri output scale keybinds**

Added three keybinds for live output scaling on the focused monitor. Scale changes are temporary — they reset on compositor restart (intentional; default is 1.0):

| Bind | Action |
|---|---|
| `Mod+Equal` (`=` key) | Scale up +0.25, max 3.0 |
| `Mod+Minus` (`-` key) | Scale down −0.25, min 0.5 |
| `Mod+Z` | Reset to 1.0 |

Implemented as shell scripts in `modules/home/niri.nix` using `niri msg --json focused-output` (`.logical.scale`) and `niri msg output <name> scale <value>`.

**`protonup-qt` added**

Added `protonup-qt` to system packages for GUI management of GE-Proton versions. Downloads releases from GitHub into `~/.steam/root/compatibilitytools.d/`. The declarative `proton-ge-bin` in `extraCompatPackages` is kept as a baseline.

**Razer utilities removed**

Removed all Razer-related configuration: `hardware.openrazer.enable` from `hardware.nix`, `polychromatic` from `packages.nix`, and `"openrazer"` from the user's `extraGroups` in `users.nix`.
