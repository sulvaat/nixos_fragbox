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
  };

  outputs = { self, nixpkgs, stylix, home-manager, chaotic, ... }: {

    nixosConfigurations.fragbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }

        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        chaotic.nixosModules.default

        ./configuration.nix
      ];
    };
  };
}
