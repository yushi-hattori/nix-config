# tesseract — OCR engine.
#
# The `ocr` script (grim + slurp screenshot) pipes into it to extract text.
{ pkgs, ... }:
{
  home.packages = [ pkgs.tesseract ];
}
