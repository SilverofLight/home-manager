{ pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../pkgs/mouseless.nix {})
  ];

  home.file.".config/mouseless".source =
    ../../dotfiles/mouseless;
}
