{
  description = "A simple NixOS flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.arce = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/arce/configuration.nix ];
    };
  };
}
