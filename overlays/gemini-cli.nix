self: super: {
  gemini-cli = super.gemini-cli.overrideAttrs (oldAttrs: {
    version = "0.24.5";
    src = super.fetchurl {
      url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.24.5.tgz";
      sha256 = "1ly511vvn7jcs2rh2lkzxmi8crg0vb0vv12y3pfb89d0bmf0753f";
    };
  });
}
