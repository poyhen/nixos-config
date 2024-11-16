update:
    nix --no-warn-dirty flake update
    just boot

switch:
    sudo nixos-rebuild switch -L --option warn-dirty false --flake .#arce

boot:
    sudo nixos-rebuild boot -L --option warn-dirty false --flake .#arce
