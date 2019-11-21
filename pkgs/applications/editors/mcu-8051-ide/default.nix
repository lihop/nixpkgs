{ stdenv
, bwidget
, cmake
, fetchurl
, fltk13
, libjpeg
, lispPackages
, pkgconfig
, tcl
, tk
, tkimg
, tdom
, makeWrapper
}:

stdenv.mkDerivation rec {
  version = "1.4.9";
  pname = "mcu8051ide";

  src = fetchurl {
    url = "mirror://sourceforge/mcu8051ide/${pname}-${version}.tar.gz";
    sha256 = "00pxnk2k75g5mcsv1dzwnwqd6jcyn43g3vs71gpili1sahl9x53b";
  };

  buildInputs = [
    bwidget
    (lispPackages.md5)
    tcl
    tk
    tkimg
    tdom
    makeWrapper
  ];

  nativeBuildInputs = [
    cmake
    pkgconfig
  ];

  buildPhase = ''
    cmake ./
  '';

  postInstall = ''
    export TCLLIBPATH="${tkimg}/lib/Img${tkimg.version} ${tk}/lib/tk8.6 ${tdom}/lib/tdom0.9.1"
    echo "TCLLIBPATH >>>> $TCLLIBPATH"
    wrapProgram $out/bin/${pname} \
      --set TCLLIBPATH "$TCLLIBPATH"
  '';

  meta = {
    description = "Digital modem rig control program";
    homepage = https://sourceforge.net/projects/fldigi/;
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = with stdenv.lib.maintainers; [ dysinger ];
    platforms = stdenv.lib.platforms.linux;
  };
}
