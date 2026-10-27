{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bleeding-edge packages; used for mesa_git (RADV from Mesa main).
    # Tracks nixos-unstable, matching nixpkgs above.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # SteamOS session stack (gaming mode, Switch to Desktop, HDMI-CEC). Only
    # enabled inside the `console` specialisation (modules/system/console-mode.nix).
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stylix, home-manager, chaotic, jovian, ... }: {

    nixosConfigurations.fragbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }

        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        chaotic.nixosModules.default
        jovian.nixosModules.default

        ./configuration.nix
      ];
    };
  };
}
