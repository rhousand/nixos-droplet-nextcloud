{ config, pkgs, inputs, ... }:

{
  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    flake = inputs.self.outPath;
    flags = {
      "--update-input"
      "nixpkgs"
      "-L"
    };
    randomizedDelaySec = "30min";
  };
}
