{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/_internal/ci-outputs.nix
        ./flake-modules/_internal/commands.nix
        ./flake-modules/_internal/meta.nix
        ./flake-modules/_internal/modules-test-nixos-config.nix
        ./flake-modules/_internal/package-meta.nix
        ./flake-modules/commands.nix
        ./flake-modules/lantian-pre-commit-hooks.nix
        ./flake-modules/lantian-treefmt.nix
        ./flake-modules/nixpkgs-options.nix
      ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = {
        overlay = self.overlays.default;
        overlays = {
          default = _final: prev:
            import ./pkgs null {
              pkgs = prev;
              inherit inputs;
            };
        };

        flakeModules = {
          auto-apps-shell = import ./flake-modules/auto-apps-shell.nix;
          auto-colmena-hive = import ./flake-modules/auto-colmena-hive.nix;
          commands = import ./flake-modules/commands.nix;
          lantian-pre-commit-hooks =
            import ./flake-modules/lantian-pre-commit-hooks.nix;
          lantian-treefmt = import ./flake-modules/lantian-treefmt.nix;
          nixpkgs-options = import ./flake-modules/nixpkgs-options.nix;
        };

        nixosModules = {
          setupOverlay = _: { nixpkgs.overlays = [ self.overlays.default ]; };
          kata-containers = import ./modules/kata-containers.nix;
          lyrica = import ./modules/lyrica.nix;
          nix-cache-attic = import ./modules/nix-cache-attic.nix;
          nix-cache-cachix = import ./modules/nix-cache-cachix.nix;
          nix-cache-garnix = import ./modules/nix-cache-garnix.nix;
          openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
          plasma-desktop-lyrics = import ./modules/lyrica.nix;
          qemu-user-static-binfmt =
            import ./modules/qemu-user-static-binfmt.nix;
          wireguard-remove-lingering-links =
            import ./modules/wireguard-remove-lingering-links.nix;
        };
      };

      nixpkgs-options = {
        permittedInsecurePackages = [
          "electron-11.5.0"
          "electron-19.1.9"
          "openssl-1.1.1w"
          "python-2.7.18.7"
        ];
        overlays = [ self.overlays.default ];
      };

      perSystem = { pkgs, ... }: {
        packages = import ./pkgs null { inherit inputs pkgs; };
        legacyPackages = import ./pkgs "legacy" { inherit inputs pkgs; };
      };
    };
}
