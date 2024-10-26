update:
    nix --no-warn-dirty flake update
    just boot

switch:
    sudo nixos-rebuild switch --option warn-dirty false --flake .#arce

boot:
    sudo nixos-rebuild boot --option warn-dirty false --flake .#arce
