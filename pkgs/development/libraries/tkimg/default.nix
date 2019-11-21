{ stdenv, fetchurl, tcllib, tcl, tk, fetchpatch } :

stdenv.mkDerivation {
  version = "1.4.9";
  pname = "tkimg";
  src = fetchurl {
     url = "mirror://sourceforge/tkimg/tkimg/1.4/tkimg%201.4.9/Img-1.4.9-Source.tar.gz";
     sha256 = "0a9n3r6qjgp18xh2gvh7g6vz2lmg4xdwhyw5hg205pjjjffh5al9";
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

    cp t*Config.sh ./zlib
  '';

  configureFlags = [
    "--with-tclinclude=${tcl}/include"
    "--with-tclconfig=."
    "--with-tkinclude=${tk.dev}/include"
    "--with-tkconfig=."
    "--libdir=\${prefix}/lib"
  ];

  preBuild = ''
    export TCLLIBPATH=${tcllib}/lib/tcllib${tcllib.version}
  '';

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

