{
  inputs,
  sopsDir,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../global/core.nix
    ../../global/users
    ../../global/programs

    ./networking
    ./certificates
    ./security
    ./services

    ./administration
  ];

  nixpkgs.overlays = import ../../global/overlays inputs;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot = {
      enable = true;
      graceful = true;
      netbootxyz.enable = true;
    };
    grub.enable = false;
  };

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.defaultSopsFile = sopsDir + "/default.yaml";

  # Just don't change this :p
  system.stateVersion = "23.05"; # Did you read the comment?
}
