# Vendored fonts

Fonts not packaged in nixpkgs, vendored as TTF files and installed by
`nixos/shared/system.nix` (`fonts.packages`).

| File | Family | Source | License |
| --- | --- | --- | --- |
| `brittany-signature.ttf` | Brittany Signature | Creatype Studio (dafont) | Free for personal use |
| `amsterdam-two.ttf` | Amsterdam (Two) | Lettersiro (dafont) | Free for personal use |
| `amsterdam-four.ttf` | Amsterdam (Four) | Lettersiro (dafont) | Free for personal use |
| `sacramento.ttf` | Sacramento | Google Fonts | OFL |
| `alex-brush.ttf` | Alex Brush | Google Fonts | OFL |
| `playfair-display.ttf` | Playfair Display (variable) | Google Fonts | OFL |
| `playfair-display-italic.ttf` | Playfair Display Italic (variable) | Google Fonts | OFL |

The Google Fonts files are pinned to the `google/fonts` repo revision used by
nixpkgs at the time of vendoring (`5174b3…`). The Brittany Signature and
Amsterdam fonts are free for **personal use only** — buy a commercial license
from the author (see dafont page / lettersiro.com) before using them
commercially.
