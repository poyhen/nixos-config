{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations.arce = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/arce/configuration.nix
        {
          nixpkgs.overlays = [
            (self: super: {
              unstable = inputs.nixpkgs-unstable.legacyPackages.${super.system};
            })
          ];
        }
      ];
    };
  };
}
