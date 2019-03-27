{ stdenv, requireFile, makeWrapper, which, zlib, libGL, glib, xdg_utils
, openssl, libgcrypt, dbus, qtwebsockets, qtbase, qtquickcontrols2, qtdeclarative, full
# For glewinfo
, libXmu, libXi, libglvnd, linuxPackages, libXext, xorg, hiredis, freetype, fontconfig, libxkbcommon, xkeyboard_config }:

let
  packages = [
    dbus.lib
    freetype
    fontconfig
    full
    glib
    hiredis
    libgcrypt
    libxkbcommon
    libGL
    libglvnd
    libXmu
    libXi
    libXext
    linuxPackages.nvidia_x11
    openssl
    #qtbase
    #qtdeclarative
    #qtquickcontrols2
    #qtwebsockets
    stdenv.cc.cc
    xorg.libxcb
    xorg.libX11
    zlib
  ];
  libPath = "${stdenv.lib.makeLibraryPath packages}";
in
stdenv.mkDerivation rec {
  name = "genymotion-${version}";
  version = "3.0.1";
  src = requireFile {
    url = https://dl.genymotion.com/releases/genymotion-3.0.1/genymotion-3.0.1-linux_x64.bin;
    name = "genymotion-${version}-linux_x64.bin";
    sha256 = "1k11syi1k2x8mf03gg946dlgz75p5m3282mrln6k7mmb5x9p4dh2";
  };

  buildInputs = [ makeWrapper which xdg_utils ];

  unpackPhase = ''
    mkdir -p phony-home $out/share/applications
    export HOME=$TMP/phony-home

    mkdir ${name}
    echo "y" | sh $src -d ${name}
    sourceRoot=${name}

    substitute phony-home/.local/share/applications/genymobile-genymotion.desktop \
      $out/share/applications/genymobile-genymotion.desktop --replace "$TMP/${name}" "$out/libexec"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/libexec
    mv genymotion $out/libexec/
    ln -s $out/libexec/genymotion/{genymotion,player} $out/bin
  '';

  fixupPhase = ''
    patchInterpreter() {
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        "$out/libexec/genymotion/$1"
    }

    patchExecutable() {
      patchInterpreter "$1"
      wrapProgram "$out/libexec/genymotion/$1" \
        --set "LD_LIBRARY_PATH" "${libPath}" \
        --set "QT_XKB_CONFIG_ROOT" "${xkeyboard_config}/share/X11/xkb" \
        --set "QT_PLUGIN_PATH" "$out/libexec/genymotion/plugins"
        #--set "QT_PLUGIN_PATH" "${qtbase.bin}/${qtbase.qtPluginPrefix}:$out/libexec/genymotion/plugins"
    }

    patchTool() {
      patchInterpreter "tools/$1"
      wrapProgram "$out/libexec/genymotion/tools/$1" \
        --set "LD_LIBRARY_PATH" "${libPath}"
    }

    patchExecutable genymotion
    patchExecutable player

    patchTool adb
    patchTool aapt
    patchTool glewinfo

    # Remove libraries that are installed by NixOS
    #rm $out/libexec/genymotion/*.so
    #rm $out/libexec/genymotion/*.so.*

    #rm $out/libexec/genymotion/libc*
    #rm $out/libexec/genymotion/libE*
    #rm $out/libexec/genymotion/libG*
    #rm $out/libexec/genymotion/libg*
    #rm $out/libexec/genymotion/liba*
    #rm $out/libexec/genymotion/libd*

    #rm $out/libexec/genymotion/libO*
    #rm $out/libexec/genymotion/libx*
    #rm $out/libexec/genymotion/libX*
    #rm $out/libexec/genymotion/libr*
    #rm $out/libexec/genymotion/libsw*

    #rm $out/libexec/genymotion/libl*
    #rm $out/libexec/genymotion/libs*
    #rm $out/libexec/genymotion/libx*
    #rm $out/libexec/genymotion/libQt*
    #rm $out/libexec/genymotion/libp*

    #rm $out/libexec/genymotion/*Qt*.so*
    #rm $out/libexec/genymotion/libssl*
    #rm $out/libexec/genymotion/libcrypto*

    #find $out/libexec/genymotion -type f -name '*libqt*' -delete
    #find $out/libexec/genymotion -type f -name '*libQt*' -delete

    #cat $out/libexec/genymotion/qt.conf 

    #rm $out/libexec/genymotion/qt.conf
    
    #ln -s ${hiredis}/lib/libhiredis.so $out/libexec/genymotion/libhiredis.so.0.13
  '';

  meta = with stdenv.lib; {
    description = "Fast and easy Android emulation";
    longDescription = ''
      Genymotion is a relatively fast Android emulator which comes with
      pre-configured Android (x86 with OpenGL hardware acceleration) images,
      suitable for application testing.
     '';
    homepage = https://www.genymotion.com/;
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [ puffnfresh lihop ];
  };
}
