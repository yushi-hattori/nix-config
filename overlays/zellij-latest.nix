# zellij-latest — newer zellij for kitty graphics protocol support.
#
# zellij 0.45.0 added the Kitty graphics protocol (image previews in
# yazi/neovim). The pinned nixpkgs still ships 0.44.3, so rebuild the unwrapped
# package at 0.45.1.
#
# To bump: update `version` + the two hashes from the matching nixpkgs rev.
final: prev: {
  zellij-unwrapped = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "zellij-unwrapped";
    version = "0.45.1";
    __structuredAttrs = true;

    src = final.fetchFromGitHub {
      owner = "zellij-org";
      repo = "zellij";
      tag = "v${finalAttrs.version}";
      hash = "sha256-pp++8CTIM4PuAYOjM7GnzU4TXTaw8XuDMow5k/7KQgY=";
    };

    postPatch = ''
      substituteInPlace Cargo.toml \
        --replace-fail ', "vendored_curl"' ""
    '';

    cargoHash = "sha256-rCK7FyAUIjUq6dxEw9YBaGm29xYvlYjX0b1xHU03XVU=";

    env.OPENSSL_NO_VENDOR = 1;

    nativeBuildInputs = [
      final.installShellFiles
      final.pkg-config
      (final.lib.getDev final.curl)
    ];

    buildInputs = [
      final.curl
      final.openssl
    ];

    nativeCheckInputs = [ final.writableTmpDirAsHomeHook ];
    nativeInstallCheckInputs = [ final.versionCheckHook ];
    doInstallCheck = true;

    installCheckPhase = ''
      runHook preInstallCheck
      ldd "$out/bin/zellij" | grep libcurl.so
      runHook postInstallCheck
    '';

    postInstall = ''
      installShellCompletion --cmd zellij \
        --bash <($out/bin/zellij setup --generate-completion bash) \
        --fish <($out/bin/zellij setup --generate-completion fish) \
        --zsh <($out/bin/zellij setup --generate-completion zsh)
    '';

    meta = {
      description = "Terminal workspace with batteries included";
      homepage = "https://zellij.dev/";
      changelog = "https://github.com/zellij-org/zellij/blob/v${finalAttrs.version}/CHANGELOG.md";
      license = final.lib.licenses.mit;
      platforms = final.lib.platforms.linux;
      mainProgram = "zellij";
    };
  });
}
