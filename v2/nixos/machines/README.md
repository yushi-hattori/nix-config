# machines/

One folder per host. Each machine's `default.nix` imports the shared modules it uses plus its own machine-specific files (hardware, boot, power, networking). Adding a machine means adding a folder here — no copying.
