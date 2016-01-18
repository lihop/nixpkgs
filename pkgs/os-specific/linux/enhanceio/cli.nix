{ stdenv, fetchFromGitHub, python

# By default eio_cli will write udev rules to /etc/udev/rules.d which is read-only
# on NixOS. Therefore we provide an option to set where eio_cli should write rules.
, ruleDir ? null

}:

stdenv.mkDerivation rec {
  name = "eio_cli-${version}";
  inherit (import ./src.nix fetchFromGitHub) version src;

  postUnpack = "sourceRoot=\${sourceRoot}/CLI";

  buildInputs = [ python ];

  postPatch =
    if ruleDir == null
    then ""
    else ''
      substituteInPlace eio_cli --replace "/etc/udev/rules.d/" "${ruleDir}/"
    '';

  installPhase = ''
    mkdir -p $out/bin && cp ./eio_cli $out/bin 
    mkdir -p $out/man/man8 && cp ./eio_cli.8 $out/man/man8
  '';

  meta = with stdenv.lib; {
    description = "EnhanceIO command line interface";
    homepage = https://github.com/stec-inc/EnhanceIO;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lihop ];
  };
}
