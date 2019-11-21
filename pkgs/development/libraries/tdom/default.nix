{ stdenv, fetchurl, tcllib, tcl, tk, fetchpatch } :

stdenv.mkDerivation rec {
  version = "0.9.1";
  pname = "tdom";
  src = fetchurl {
     url = "http://tdom.org/downloads/${pname}-${version}-src.tgz";
     sha256 = "0b14k2rwybdafi36z9mzksg9v28an2f71jx8z95gwcvmy16687rv";
  };

  buildInputs = [ tcllib tcl tk ];

  # the configure script expects to find the location of the sources of
  # tcl and tk in {tcl,tk}Config.sh
  # In fact, it only needs some private headers. We copy them in 
  # the private_headers folders and trick the configure script into believing
  # the sources are here.
  preConfigure = ''
    mkdir -p private_headers/generic
    < ${tcl}/lib/tclConfig.sh sed "s@TCL_SRC_DIR=.*@TCL_SRC_DIR=private_headers@" > tclConfig.sh
    < ${tk}/lib/tkConfig.sh sed "s@TK_SRC_DIR=.*@TK_SRC_DIR=private_headers@" > tkConfig.sh
    for i in ${tcl}/include/* ${tk.dev}/include/*; do
      ln -s $i private_headers/generic;
    done;
  '';

  configureFlags = [
    "--with-tclinclude=${tcl}/include"
    "--with-tclconfig=."
    "--with-tkinclude=${tk.dev}/include"
    "--with-tkconfig=."
    "--libdir=\${prefix}/lib"
  ];

  meta = with stdenv.lib; {
    description = "TODO Fix all metadata!!! A widget library for Tcl/Tk";
    homepage    = http://tix.sourceforge.net/;
    platforms   = platforms.all;
    license     = with licenses; [
      bsd2 # tix
      gpl2 # patches from portage
    ];
  };
}

