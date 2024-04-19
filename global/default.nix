# This is a NixOS module, you cannot use this as a standalone file.
# Other files may be though, but things that starts with {...}: most definitely aren't.
{inputs, ...}: {
  imports = [
    ./core.nix
    ./programs
    ../users

    inputs.sops-nix.nixosModules.sops
  ];
}
