{
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  lib,
  fetchurl,
  # Dependencies
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  gdk-pixbuf,
  glib,
  gnome,
  gnome2,
  gtk2,
  libjpeg8,
  libpulseaudio,
  libvlc,
  nspr,
  nss,
  openssl_1_1,
  pango,
  pciutils,
  libqcef,
  qt5,
  taglib,
  udev,
  xorg,
  ...
} @ args:
# Modified from:
# - https://github.com/NixOS-CN/flakes/blob/main/packages/netease-cloud-music/default.nix
# - https://github.com/Freed-Wu/nur-packages/blob/main/pkgs/applications/audio/netease-cloud-music/default.nix
let
  libraries = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    gdk-pixbuf
    glib
    gnome.gnome-themes-extra
    gnome2.GConf
    gtk2
    libjpeg8
    libpulseaudio
    libvlc
    nspr
    nss
    openssl_1_1
    pango
    pciutils
    libqcef
    qt5.qtbase
    qt5.qtwebengine
    qt5.qtx11extras
    taglib
    udev
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
  ];
in
  stdenv.mkDerivation rec {
    pname = "netease-cloud-music";
    version = "1.2.1";
    src = fetchurl {
      url = "http://d1.music.126.net/dmusic/netease-cloud-music_${version}_amd64_ubuntu_20190428.deb";
      sha256 = "1fzc5xb3h17jcdg8w8xliqx2372g0wrfkcj8kk3wihp688lg1s8y";
      curlOpts = "-A 'Mozilla/5.0'";
    };

    unpackPhase = ''
      ar x ${src}
      tar xf data.tar.xz
    '';

    nativeBuildInputs = [qt5.wrapQtAppsHook makeWrapper autoPatchelfHook];
    buildInputs = libraries;

    installPhase = ''
      mkdir -p $out/bin
      cp -r opt/netease/netease-cloud-music/netease-cloud-music $out/bin/

      mkdir -p $out/share
      cp -r usr/share/* $out/share/

      wrapProgram $out/bin/netease-cloud-music \
        --set QCEF_INSTALL_PATH "${libqcef}/lib/qcef" \
        --set QT_QPA_PLATFORM xcb \
        --set XDG_SESSION_TYPE x11 \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
        --add-flags "--ignore-certificate-errors"
    '';

    meta = {
      description = "NetEase Cloud Music Linux Client (package script adapted from NixOS-CN and Freed-Wu)";
      homepage = "https://music.163.com";
      platforms = ["x86_64-linux"];
      license = lib.licenses.unfree;
    };
  }
