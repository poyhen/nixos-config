{
  description = "My Systems Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    custom-packages.url = "github:poyhen/custom-packages";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
  };
  outputs =
    {
      nixpkgs,
      chaotic,
      nix-flatpak,
      custom-packages,
      determinate,
      ...
    }:
    {
      nixosConfigurations.arce = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          determinate.nixosModules.default
          ./hosts/arce/configuration.nix
          chaotic.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  code-cursor = custom-packages.packages.${pkgs.system}.code-cursor;
                  #remove later
                  mitmproxy = prev.mitmproxy.overridePythonAttrs (old: {
                    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
                      "passlib"
                      "protobuf"
                      "urwid"
                    ];
                  });
                })
              ];
            }
          )
        ];
      };
    };
}
