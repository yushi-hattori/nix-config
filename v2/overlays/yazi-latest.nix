# yazi-latest — newer yazi for better terminal / image-protocol handling.
#
# 26.9.1 vs the pinned nixpkgs' 26.5.6. Hashes match upstream nixpkgs.
#
# To bump: update `version` + cargoHash + code_src hash from the matching rev.
final: prev: {
  yazi-unwrapped = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "yazi";
    version = "26.9.1";

    srcs = builtins.attrValues finalAttrs.passthru.srcs;
    sourceRoot = finalAttrs.passthru.srcs.code_src.name;

    cargoHash = "sha256-V69VxhMiTY1Tgo4aW06AjwBIoXjK0Ov6oIahxk0NzGg=";

    env.YAZI_GEN_COMPLETIONS = true;
    env.VERGEN_GIT_SHA = "Nixpkgs";
    env.VERGEN_BUILD_DATE = "2026-09-1";

    nativeBuildInputs = [ final.installShellFiles ];
    buildInputs = [ final.rust-jemalloc-sys ];

    postInstall = ''
      installShellCompletion --cmd yazi \
        --nushell ./yazi-boot/completions/yazi.nu \
        --bash    ./yazi-boot/completions/yazi.bash \
        --fish    ./yazi-boot/completions/yazi.fish \
        --zsh     ./yazi-boot/completions/_yazi

      installShellCompletion --cmd ya \
        --nushell ./yazi-cli/completions/ya.nu \
        --bash    ./yazi-cli/completions/ya.bash \
        --fish    ./yazi-cli/completions/ya.fish \
        --zsh     ./yazi-cli/completions/_ya

      installManPage ../${finalAttrs.passthru.srcs.man_src.name}/yazi{.1,-config.5}

      install -Dm444 assets/yazi.desktop -t $out/share/applications
      install -Dm444 assets/logo.png $out/share/pixmaps/yazi.png
    '';

    passthru.srcs = {
      code_src = final.fetchFromGitHub {
        owner = "sxyazi";
        repo = "yazi";
        tag = "v${finalAttrs.version}";
        hash = "sha256-/8j4bEbT8DR/xlWtt62FXVyeHyWtBlvV8Rq0VbtY6ms=";
      };

      man_src = final.fetchFromGitHub {
        name = "manpages";
        owner = "yazi-rs";
        repo = "manpages";
        rev = "8950e968f4a1ad0b83d5836ec54a070855068dbf";
        hash = "sha256-kEVXejDg4ChFoMNBvKlwdFEyUuTcY2VuK9j0PdafKus=";
      };
    };

    meta = {
      description = "Blazing fast terminal file manager written in Rust, based on async I/O";
      homepage = "https://github.com/sxyazi/yazi";
      changelog = "https://github.com/sxyazi/yazi/blob/${finalAttrs.passthru.srcs.code_src.rev}/CHANGELOG.md";
      license = final.lib.licenses.mit;
      platforms = final.lib.platforms.linux;
      mainProgram = "yazi";
    };
  });
}
