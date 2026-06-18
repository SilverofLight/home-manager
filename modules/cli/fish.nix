{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fish
  ];

  home.file.".config/fish/config.fish".source =
    ../../dotfiles/fish/config.fish;

  home.file.".config/fish/conf.d".source =
    ../../dotfiles/fish/conf.d;

  home.file.".config/fish/functions".source =
    ../../dotfiles/fish/functions;
}
