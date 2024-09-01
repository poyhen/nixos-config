update:
    @sudo -v && echo "Sudo authenticated."
    nix flake update
    just boot

switch:
    sudo nixos-rebuild switch --flake .#arce

boot:
    sudo nixos-rebuild boot --flake .#arce
