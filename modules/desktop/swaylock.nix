{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swaylock
  ];
  home.file.".config/swaylock".source =
    ../../dotfiles/swaylock;
}
