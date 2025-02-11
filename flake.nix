{
  description = "BeastOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, impermanence, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in {
        nixosConfigurations = {
          desktop = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
	            impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              ./configuration.nix
            ];
            specialArgs = { inherit pkgs-unstable; };
          };
          desktop-nvidia = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
	            impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              ./configuration.nix
              ./modules/nvidia.nix
            ];
            specialArgs = { inherit pkgs-unstable; };
          };
          notebook = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
	            impermanence.nixosModules.impermanence
              home-manager.nixosModules.home-manager
              ./configuration.nix
              ./modules/notebook.nix
            ];
            specialArgs = { inherit pkgs-unstable; };
          };
        };
      };
}
