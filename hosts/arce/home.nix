{ pkgs, ... }:

{
  home.username = "frkn";
  home.homeDirectory = "/home/frkn";
  home.packages = with pkgs; [
    fastfetch
  ];
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
