{ config, lib, pkgs, ... }:
{
  networking.wireless.enable = false;
  services.libinput.enable = true;
  services.printing.enable = true;
}
