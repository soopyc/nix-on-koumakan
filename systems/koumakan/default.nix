{
  lib,
  _utils,
  inputs,
  ...
}:
lib.nixosSystem {
  system = "x86_64-linux";

  # see docs/tips_n_tricks.md#extra_opts for syntax
  # see docs/utils.md for functions
  specialArgs = {
    inherit inputs _utils;
  };

  modules = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.attic.nixosModules.atticd

    ./configuration.nix
  ];
}