{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zathura
    zathuraPkgs.zathura_pdf_mupdf
    zathuraPkgs.zathura_cb
    zathuraPkgs.zathura_djvu
  ];
  home.file.".config/zathura".source =
    ../../dotfiles/zathura;
}
