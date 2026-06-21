{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rmpc
  ];

  home.file.".config/rmpc".source =
    ../../dotfiles/rmpc;
}
