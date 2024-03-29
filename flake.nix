{
  description = "Gensokyo system configurations";

  nixConfig = {
    extra-substituters = [
      "https://nonbunary.soopy.moe/gensokyo-global"
      "https://nonbunary.soopy.moe/gensokyo-systems"
      "https://cache.garnix.io"
    ];

    extra-trusted-public-keys = [
      "gensokyo-global:XiCN0D2XeSxF4urFYTprR+1Nr/5hWyydcETwZtPG6Ec="
      "gensokyo-systems:r/Wx649dPuQrCN9Pgh3Jic526zQNk3oWMqYJHnob/Ok="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    allow-import-from-derivation = true;
    fallback = true;
  };

  inputs = {
    nixpkgs.follows = "mystia/nixpkgs";
    nixpkgs-wf.url = "github:soopyc/nixpkgs/wf-test";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic = {
      url = "github:zhaofengli/attic";
      # added back because it's gentoo either way
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mystia = {
      url = "github:soopyc/mystia";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    utils = import ./global/utils.nix;
    lib = nixpkgs.lib;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = fn: lib.genAttrs systems (s: fn nixpkgs.legacyPackages.${s});
  in {
    lib.x86_64-linux = import ./global/utils.nix {
      inherit inputs;
      system = "x86_64-linux";
    };

    nixosConfigurations = {
      koumakan = import ./systems/koumakan {
        inherit utils lib inputs;
        sopsDir = ./creds/sops/koumakan;
      };
    };

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = [
          (pkgs.python311.withPackages (p: [p.requests]))
          pkgs.nixos-rebuild
          pkgs.nix-output-monitor
        ];
      };
    });

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
