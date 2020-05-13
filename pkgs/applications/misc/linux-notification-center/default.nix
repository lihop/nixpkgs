{ stdenv, lib, fetchurl, libxml2, gtk3-x11, zlib, gnome2, harfbuzz
, atk, cairo, gdk_pixbuf, glib, gobjectIntrospection, gmpxx
}:

stdenv.mkDerivation rec {
  pname = "deadd-notification-center";
  version = "1.7.2";

  src = fetchurl {
    url = "https://github.com/phuhl/linux_notification_center/releases/download/${version}/deadd-notification-center";
    sha256 = "13f15slkjiw2n5dnqj13dprhqm3nf1k11jqaqda379yhgygyp9zm";
  };

  phases = [ "installPhase" "patchPhase" "fixupPhase" ];

  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  preFixup = let
    libPath = lib.makeLibraryPath [
      libxml2
      gtk3-x11
      zlib
      gnome2.pango
      harfbuzz
      atk
      cairo
      gdk_pixbuf
      glib
      gobjectIntrospection
      gmpxx
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/${pname}
  '';

  meta = with lib; {
    description = "A notification daemon/center for linux";
    homepage = "https://github.com/phuhl/linux_notification_center";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihop ];
  };
}
