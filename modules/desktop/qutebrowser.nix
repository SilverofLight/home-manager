{ pkgs, ... }:

{
  home.packages = with pkgs; [
    qutebrowser
  ];
    # 系统安装 qutebrowser
  home.file.".config/qutebrowser/catppuccin".source =
    ../../dotfiles/qutebrowser/catppuccin;

  home.file.".config/qutebrowser/greasemonkey".source =
    ../../dotfiles/qutebrowser/greasemonkey;

  home.file.".config/qutebrowser/styles".source =
    ../../dotfiles/qutebrowser/styles;

  home.file.".config/qutebrowser/userscripts".source =
    ../../dotfiles/qutebrowser/userscripts;

  home.file.".config/qutebrowser/bindings.py".source =
    ../../dotfiles/qutebrowser/bindings.py;

  home.file.".config/qutebrowser/config.py".source =
    ../../dotfiles/qutebrowser/config.py;

  home.file.".config/qutebrowser/dracula.py".source =
    ../../dotfiles/qutebrowser/dracula.py;
}
