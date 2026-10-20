# opencode-latest — pin opencode to the latest upstream release.
#
# dan-online/opencode-nix lags behind upstream anomalyco/opencode releases, so
# override to the newest. To bump: update `version` and refresh the hash with
#   nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url --type sha256 <url>)"
final: prev: {
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.19.3";
    src = final.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-E6j7KXgwIHG4b51+ANqciJX5zYRpeDecO9xqUzNTbJs=";
    };
  });
}
