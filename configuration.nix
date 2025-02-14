{ config, lib, pkgs, pkgs-unstable, home-manager, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    efiInstallAsRemovable = true;
    splashImage = "/etc/nixos/boot-splash-image.jpg";
  };

  networking.hostName = "beast";
  networking.useDHCP = false;
  networking.bridges.br0.interfaces = [ "eth0" ];
  networking.interfaces.br0.useDHCP = true;
  

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb.layout = "ch";
  console.useXkbConfig = true;

  services.gnome.gnome-keyring.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  fileSystems."/" = {
    neededForBoot = true;
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=10G" "mode=755" ];
  };

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

  users.users.linus = {
    initialPassword = "letmecook";
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  home-manager.users.linus = {
    home.stateVersion = "24.11";
    home.file.".emacs".source = ./emacs.el;
    home.file.".config/hypr/" = {
      source = ./config/hypr;
      recursive = true;
    };
    home.file.".config/waybar/" = {
      source = ./config/waybar;
      recursive = true;
    };
    home.file.".config/sys64/menu/" = {
      source = ./config/sysmenu;
      recursive = true;
    };
    home.file.".config/rofi/config.rasi".source = ./config/rofi/config.rasi;
    home.file.".config/starship.toml".source = ./config/starship/config.toml;

    home.shellAliases = {
      ll = "ls -al";
      s = "sudo";
      sc = "grim -g \"$(slurp)\" - | wl-copy";
      sysmacs = "emacsclient -c -a '' -nw /sudo::/etc/nixos/configuration.nix";
      unleash-desktop = "sudo nixos-rebuild switch --flake /etc/nixos#desktop";
      unleash-notebook = "sudo nixos-rebuild switch --flake /etc/nixos#notebook";
      unleash-glitches = "sudo nixos-rebuild switch --flake /etc/nixos#desktop-nvidia";
    };

    programs.bash.enable = true; # required to make shellAliases work.
    programs.starship.enable = true; # required to fix bash, visually.

    xdg.desktopEntries.emacs = {
      name = "Emacs";
      comment = "Unleash raw power";
      exec = "emacsclient -c -a \"\" %F";
      icon = "emacs";
      terminal = false;
      type = "Application";
      categories = [ "Development" "TextEditor" ];
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-go"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
        "x-scheme-handler/org-protocol"
      ];
    };

    xdg.desktopEntries.emacsclient = {
      name = "Emacs (Client)";
      noDisplay = true;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/english" = [ "emacs.desktop" ];
        "text/x-go" = [ "emacs.desktop" ];
        "text/plain" = [ "emacs.desktop" ];
        "text/x-makefile" = [ "emacs.desktop" ];
        "text/x-c++hdr" = [ "emacs.desktop" ];
        "text/x-c++src" = [ "emacs.desktop" ];
        "text/x-chdr" = [ "emacs.desktop" ];
        "text/x-csrc" = [ "emacs.desktop" ];
        "text/x-java" = [ "emacs.desktop" ];
        "text/x-moc" = [ "emacs.desktop" ];
        "text/x-pascal" = [ "emacs.desktop" ];
        "text/x-tcl" = [ "emacs.desktop" ];
        "text/x-tex" = [ "emacs.desktop" ];
        "application/x-shellscript" = [ "emacs.desktop" ];
        "text/x-c" = [ "emacs.desktop" ];
        "text/x-c++" = [ "emacs.desktop" ];
        "x-scheme-handler/org-protocol" = [ "emacs.desktop" ];
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Yaru-dark";
        package = pkgs.yaru-theme;
      };
    
      iconTheme = {
        name = "WhiteSur-dark";
	      package = pkgs.whitesur-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "qt5ct";
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          })
        ];
      };
    };
  };

  fonts.packages = with pkgs; [
    iosevka
    nerdfonts
    font-awesome
    inter
  ];

  environment.systemPackages = with pkgs; [
    emacs
    go
    gopls
    git
    brave
    steam
    wget
    curl
    vscode
    nautilus
    kitty
    gh
    go
    gopls
    fastfetch
    starship
    cmake
    gnumake
    gtkmm3
    pkg-config
    gcc14
    clang-tools
    gtkmm4
    jq
    remmina
    _1password-gui
    mission-center
    python39

    libvterm # required for vterm in emacs
    libtool # required for vterm compilation in emacs
    
    pavucontrol
    mako
    libnotify
    hyprpaper
    slurp
    grim
    wl-clipboard
    sysmenu
    waybar
    playerctl
    pamixer
    pkgs-unstable.hyprlock
  ];

  programs.hyprland.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  system.stateVersion = "24.11"; # If you change this, I will find you...
}

