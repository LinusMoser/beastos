# Office Notebook
{ config, lib, pkgs, pkgs-unstable, home-manager, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../configuration.nix
      ../../modules/notebook.nix
    ];

  networking.hostName = "beast-notebook-01";

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot"; # requires the root device to be mapped on cryptroot
    fsType = "ext4";
    neededForBoot = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/home"
      "/root"
      "/var"
      "/etc"
    ];
  };

  programs.bash.shellAliases = {
    snleash = "sudo nixos-rebuild switch --flake path:/etc/nixos#notebook-01";
  };
}
