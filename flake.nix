{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations.arce = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/arce/configuration.nix chaotic.nixosModules.default ];
    };
  };
}
