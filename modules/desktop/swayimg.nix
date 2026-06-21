{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayimg
  ];
  home.file.".config/swayimg".source =
    ../../dotfiles/swayimg;
}
