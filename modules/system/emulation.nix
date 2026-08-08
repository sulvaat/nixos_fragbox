# Emulation: Dolphin (GC/Wii), RetroArch + cores, Pegasus Frontend.
# ROMs live in ~/ROMs — configure the path in Pegasus on first launch.
{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    # --- Standalone emulators ---
    dolphin-emu   # GameCube / Wii

    # --- RetroArch with a broad core set ---
    (retroarch.override {
      cores = with libretro; [
        # Nintendo
        nestopia         # NES (accuracy)
        fceumm           # NES (wide compatibility)
        snes9x           # SNES
        mupen64plus      # N64
        parallel-n64     # N64 (parallel renderer / HLE)
        mgba             # GBA / GBC / GB
        gambatte         # GB / GBC (cycle-accurate)
        melonds          # Nintendo DS

        # Sony
        beetle-psx-hw    # PS1 (Vulkan HW renderer)
        pcsx-rearmed     # PS1 (software; lower-end fallback)
        ppsspp           # PSP
        pcsx2            # PS2

        # Sega
        genesis-plus-gx  # Genesis / Mega Drive / SMS / Game Gear
        flycast          # Dreamcast
        beetle-saturn    # Saturn

        # Arcade
        fbneo            # FinalBurn Neo (CPS1/2/3, Neo Geo, etc.)
        mame2003-plus    # MAME 2003+ (broad arcade catalogue)

        # Other
        dosbox-pure      # DOS
      ];
    })

    # --- Frontend ---
    pegasus-frontend  # ES-DE was removed from nixpkgs (freeimage CVEs);
                      # Pegasus is the Nix-managed alternative.
  ];
}
