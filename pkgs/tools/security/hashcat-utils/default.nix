{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "hashcat-utils-${version}";
  version = "1.9";

  src = fetchFromGitHub {
    owner = "hashcat";
    repo = "hashcat-utils";
    sha256 = "0wgc6wv7i6cs95rgzzx3zqm14xxbjyajvcqylz8w97d8kk4x4wjr";
    rev = "v${version}";
  };

  sourceRoot = "source/src"; 

  installPhase = ''
    mkdir -p $out/bin
    for f in *.bin; do mv $f $out/bin/`basename $f .bin`; done;
  '';

  meta = with stdenv.lib; {
    description = "A set of small utilities that are useful in advanced password cracking";
    homepage = "https://github.com/hashcat/hashcat-utils";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihop ];
  };
}
