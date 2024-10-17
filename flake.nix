{
  description = "My Systems Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    custom-packages.url = "github:poyhen/custom-packages";
  };
  outputs =
    {
      nixpkgs,
      chaotic,
      nix-flatpak,
      nixos-cosmic,
      custom-packages,
      ...
    }:
    {
      nixosConfigurations.arce = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          ./hosts/arce/configuration.nix
          chaotic.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  code-cursor = custom-packages.packages.${pkgs.system}.code-cursor;
                })
              ];
            }
          )
        ];
      };
    };
}
