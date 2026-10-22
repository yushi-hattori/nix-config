# Zen Browser — Firefox-based browser.
#
# Primary browser. Twilight build via the zen-browser flake; hardened with
# tracking-protection + telemetry/pocket disabled, plus firefoxpwa for
# installed web apps (e.g. sunshine-ui).
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };

  programs.zsh.shellAliases.sunshine-ui = "zen https://localhost:47990 &>/dev/null &";
}
