{ stdenv, fetchurl, autoPatchelfHook, makeWrapper, qtbase, qtsvg, dpkg, libglvnd, freeimage, freetype, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "TrenchBroom";
  version = "2020.2";

  src = fetchurl {
    url = "https://github.com/TrenchBroom/TrenchBroom/releases/download/v${version}/TrenchBroom-Linux-v${version}-Release.x86_64.deb";
    sha256 = "1rdqh0za32k0a9jvppslych8g5iwv512fa4mlvv93j7ss00iwziy";
  };

  dontUnpack = true;

  nativeBuildInputs = [ wrapQtAppsHook ];
  buildInputs = [ dpkg ];

  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    cp -av $out/usr/* $out
    rm -rf $out/usr
  '';

  postFixup =
    let
      rpath = stdenv.lib.makeLibraryPath [
        freeimage
        freetype
        libglvnd
        qtbase
        qtsvg
      ] + ":${stdenv.cc.cc.lib}/lib64";
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath ${rpath} \
        $out/bin/.trenchbroom-wrapped
    '';

  postInstall = ''
    mkdir $out/share/applications
    cp ../TrenchBroom/trenchbroom.desktop $out/share/applications
  '';

  meta = {
    description = "A modern cross-platform level editor for Quake-engine based games";
    homepage = "http://kristianduske.com/trenchbroom";
    license = stdenv.lib.licenses.gpl3;
    maintainers = with stdenv.lib.maintainers; [ lihop ];
    platforms = stdenv.lib.platforms.linux;

    broken = builtins.compareVersions qtbase.version "5.9.0" < 0;
  };
}
