{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "helm";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = "helm";
    rev = "v${version}";
    sha256 = "1453qkd9s4z4r0xzmv8ym7qfg33szf6gizfkb5zxj590fcbsgnd7";
  };
  vendorSha256 = "0j25m56cwzjd9b75v7xlb26q81bsmln77k23h9n8v2f2gqwwpkrl";

  doCheck = false;

  subPackages = [ "cmd/helm" ];
  buildFlagsArray = [ "-ldflags=-w -s -X helm.sh/helm/v3/internal/version.version=v${version}" ];

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    $out/bin/helm completion bash > helm.bash
    $out/bin/helm completion zsh > helm.zsh
    installShellCompletion helm.{bash,zsh}
  '';

  meta = with lib; {
    homepage = "https://github.com/kubernetes/helm";
    description = "A package manager for kubernetes";
    license = licenses.asl20;
    maintainers = with maintainers; [ rlupton20 edude03 saschagrunert Frostman ];
  };
}
