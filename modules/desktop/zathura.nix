{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zathura
    zathura_pdf_mupdf
    zathura_cb
    zathura_djvu
  ];
  home.file.".config/zathura".source =
    ../../dotfiles/zathura;
}
