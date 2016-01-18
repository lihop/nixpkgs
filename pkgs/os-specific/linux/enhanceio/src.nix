fetchFromGitHub: 

rec {
  version = "2015-10-30";

  src = fetchFromGitHub {
    owner = "stec-inc";
    repo = "EnhanceIO";
    rev = "104d4287f32da28f51efc5a451e62e4071322480";
    sha256 = "1j3zx4wli26yb0rbgzhxa1m5vma2dp1naw6b8g7wr9ifhwrfdi20";
  };
}
