{ pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../pkgs/mouseless.nix {})
  ];
}
