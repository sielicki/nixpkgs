{ lib, rustPlatform, fetchFromGitHub, sqlite, pkgconfig, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname = "zsh-histdb-skim";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "m42e";
    repo = pname;
    rev = "2b7e80820e84ebef1a0085bfafae7051215ec18f";
    sha256 = "sha256-pcXSGjOKhN2nrRErggb8JAjw/3/bvTy1rvFhClta1Vs=";
  };
  cargoSha256 = "sha256-a5a0JdVVkWrMw3F9mpgkj2US3mS9YHzpdkjgMlep9xw=";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ sqlite ];

  # fixme: this is very brittle. The zsh script from upstream supports
  # autoupdating into ~/.local/share, which is less than ideal when you're
  # managing this with nix, and it's not straightforward to disable this
  # functionality. Work around this for now by taking the last 40 lines, which
  # contains the actual critical function, and remove the call to the
  # entry-point for this update/download ensuration. potential fix:
  # https://github.com/m42e/zsh-histdb-skim/pull/10
  postInstall = ''
    install -d $out/share/zsh/plugins/zsh-histdb-skim/
    tail -n 40 zsh-histdb-skim.zsh > $out/share/zsh/plugins/zsh-histdb-skim/zsh-histdb-skim.zsh
    chmod +x $out/share/zsh/plugins/zsh-histdb-skim/zsh-histdb-skim.zsh
    substituteInPlace $out/share/zsh/plugins/zsh-histdb-skim/zsh-histdb-skim.zsh \
      --replace histdb-skim-ensure '#'
    wrapProgram $out/share/zsh/plugins/zsh-histdb-skim/zsh-histdb-skim.zsh \
      --set BIN_PATH $out/bin/zsh-histdb-skim
  '';

  meta = with lib; {
    description = "A zsh histdb browser using skim.";
    homepage = "https://github.com/m42e/zsh-histdb-skim";
    license = licenses.mit;
    maintainers = with maintainers; [ sielicki ];
  };
}
