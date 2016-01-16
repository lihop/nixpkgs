{ stdenv, fetchFromGitHub, kernel, python }:

stdenv.mkDerivation rec {
  name = "enhanceio-${version}-${kernel.version}";
  version = "2015-10-30";

  src = fetchFromGitHub {
    owner = "stec-inc";
    repo = "EnhanceIO";
    rev = "104d4287f32da28f51efc5a451e62e4071322480";
    sha256 = "1j3zx4wli26yb0rbgzhxa1m5vma2dp1naw6b8g7wr9ifhwrfdi20";
  };

  postUnpack = "sourceRoot=\${sourceRoot}/Driver/enhanceio";

  preBuild = ''
    substituteInPlace Makefile \
      --replace "\$shell uname -r)" "${kernel.modDirVersion}" \
      --replace "/lib/modules" "${kernel.dev}/lib/modules" \
  '';

  installPhase = ''
    # Utilities
    mkdir -p $out/bin && cp $src/CLI/eio_cli $out/bin 
    mkdir -p $out/man/man8 && cp $src/CLI/eio_cli.8 $out/man/man8

    # Kernel modules
    dest=$out/lib/modules/${kernel.modDirVersion}/misc
    mkdir -p $dest
    cp *.ko $dest
  '';
}
