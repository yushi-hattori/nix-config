{ inputs, ... }:
let
  # Define the stable-packages overlay
  stablePackagesOverlay = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # nmtui-go — modern NetworkManager TUI (Bubbletea), maintained since 2025.
  # Not packaged in nixpkgs, so build it from the pinned upstream commit. It
  # drives `nmcli` only, so it stays fully compatible with our NetworkManager
  # (iwd backend) setup — unlike iwd-native TUIs (e.g. impala) which fight
  # NetworkManager for the device.
  # To bump: update `rev`/`version`, refresh the two hashes below.
  nmtuiGoOverlay = final: prev: {
    nmtui-go = prev.buildGoModule rec {
      pname = "nmtui-go";
      version = "2026-03-17";
      src = final.fetchFromGitHub {
        owner = "doeixd";
        repo = "nmtui-go";
        rev = "ca92f5645ca6362a8399558e9cb71d930ce2588e";
        hash = "sha256-ti/EHR6ld3nvS69Oywx59yYJgBSfU1uLROkNHTNMg/0=";
      };
      subPackages = [ "cmd" ];
      vendorHash = "sha256-FYrLLZHd7C98LzmIUuEpJxLEqT2j/7GWHTcjNRRV4xY=";
      postInstall = ''
        mv "$out/bin/cmd" "$out/bin/nmtui-go"
      '';
      meta = {
        description = "Modern TUI for managing NetworkManager Wi-Fi, built with Bubbletea";
        homepage = "https://github.com/doeixd/nmtui-go";
        license = final.lib.licenses.mit;
        platforms = final.lib.platforms.linux;
        mainProgram = "nmtui-go";
      };
    };
  };

  # dan-online/opencode-nix lags behind upstream anomalyco/opencode releases.
  # Override to the latest release until the upstream flake catches up.
  # To bump: update `version` and refresh the hash with
  #   nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url --type sha256 <url>)"
  opencodeLatestOverlay = final: prev: {
    opencode = prev.opencode.overrideAttrs (old: rec {
      version = "1.18.29";
      src = final.fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
        hash = "sha256-6oALf/ViJrcJUhJsn8HiUXykxLVoL9nT+eh0SWl6EZQ=";
      };
    });
  };

  # zellij 0.45.0 added support for the Kitty graphics protocol (image previews
  # in yazi/neovim etc.). The pinned nixpkgs still ships 0.44.3, so rebuild the
  # unwrapped package at 0.45.1 (hashes match upstream nixpkgs).
  # To bump: update `version` + the two hashes from the matching nixpkgs rev.
  zellijLatestOverlay = final: prev: {
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
  };

  # yazi 26.9.1 — newer than the pinned nixpkgs' 26.5.6 (better terminal /
  # image-protocol handling). Hashes match upstream nixpkgs.
  # To bump: update `version` + cargoHash + code_src hash from the matching rev.
  yaziLatestOverlay = final: prev: {
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
  };

in
{
  # Return an attribute set of overlays
  # Each attribute here will be an overlay
  stable-packages = stablePackagesOverlay;
  opencode-latest = opencodeLatestOverlay;
  nmtui-go = nmtuiGoOverlay;
  zellij-latest = zellijLatestOverlay;
  yazi-latest = yaziLatestOverlay;
}
