update:
    @sudo -v && echo "Sudo authenticated."
    nix flake update
    just switch

switch:
    sudo nixos-rebuild switch --flake .#arce
