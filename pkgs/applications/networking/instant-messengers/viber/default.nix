{fetchurl, stdenv, dpkg, makeWrapper,
 alsaLib, cups, curl, dbus, expat, fontconfig, freetype, glib, gst_all_1, harfbuzz, libcap,
 libpulseaudio, libxml2, libxslt, libGLU_combined, nspr, nss, openssl, systemd, wayland, xorg, zlib,
 pciutils,
 ...
}:

stdenv.mkDerivation rec {
  name = "viber-${version}";
  version = "10.3.0";

  src = fetchurl {
    url = "https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb";
    sha256 = "0z7ykrhj3iq4y319c614yh2whkwwfaj54c9rs51nc64czjddkmx5";
  };

  buildInputs = [ dpkg makeWrapper ];

  unpackPhase = "true";

  libPath = stdenv.lib.makeLibraryPath [
      alsaLib
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      glib
      gst_all_1.gst-plugins-base
      gst_all_1.gstreamer
      harfbuzz
      libcap
      libpulseaudio
      libxml2
      libxslt
      libGLU_combined
      nspr
      nss
      openssl
      pciutils
      stdenv.cc.cc
      systemd
      wayland
      zlib

      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libxcb
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
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
  ]
  ;

  installPhase = ''
    dpkg-deb -x $src $out
    mkdir -p $out/bin

    # Soothe nix-build "suspicions"
    chmod -R g-w $out

    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath $libPath:$out/opt/viber/lib $file || true
    done

    # qt.conf is not working, so override everything using environment variables
    wrapProgram $out/opt/viber/Viber \
      --set QT_PLUGIN_PATH "$out/opt/viber/plugins" \
      --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb" \
      --set QTCOMPOSE "${xorg.libX11.out}/share/X11/locale" \
      --set QTWEBENGINEPROCESS_PATH "$out/opt/viber/libexec/QtWebEngineProcess"
    ln -s $out/opt/viber/Viber $out/bin/viber

    mkdir -p $out/opt/viber/libexec
    cp -ar $out/opt/viber/translations/qtwebengine_locales $out/opt/viber/libexec
    cp -ar $out/opt/viber/translations/qtwebengine_locales $out/opt/viber
    cp -ar $out/opt/viber/resources/* $out/opt/viber/libexec
    cp -ar $out/opt/viber/resources/* $out/opt/viber/

    # Copy qml resources
    cp -ar $out/opt/viber/qml/* $out/opt/viber/libexec
    cp -ar $out/opt/viber/qml/* $out/opt/viber/

    mv $out/usr/share $out/share
    rm -rf $out/usr

    # Fix the desktop link
    substituteInPlace $out/share/applications/viber.desktop \
      --replace /opt/viber/Viber $out/opt/viber/Viber \
      --replace /usr/share/ $out/share/
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = {
    homepage = http://www.viber.com;
    description = "An instant messaging and Voice over IP (VoIP) app";
    license = stdenv.lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with stdenv.lib.maintainers; [ jagajaga ];
  };

}
