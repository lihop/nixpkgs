{ stdenv, lib, fetchFromGitHub, kernel }:

if lib.versionAtLeast kernel.version "4.3"
then throw ''
  EnhanceIO is not supported for kernels 4.3+.
  See https://github.com/stec-inc/EnhanceIO/issues/110.
''
else stdenv.mkDerivation rec {
  name = "enhanceio-${version}-${kernel.version}";
  inherit (import ./src.nix fetchFromGitHub) version src;

  postUnpack = "sourceRoot=\${sourceRoot}/Driver/enhanceio";

  postPatch = ''
    substituteInPlace Makefile \
      --replace "\$(shell uname -r)" "${kernel.modDirVersion}" \
      --replace "/lib/modules" "${kernel.dev}/lib/modules" \
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/misc
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/misc
  '';

  meta = with stdenv.lib; {
    description = "SSD caching software";
    homepage = https://github.com/stec-inc/EnhanceIO;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihop ];
  };
}
