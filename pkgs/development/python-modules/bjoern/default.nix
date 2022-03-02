{ lib, buildPythonPackage, fetchPypi, libev, python }:

buildPythonPackage rec {
  pname = "bjoern";
  version = "3.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Gd+BjgWcx/+HyjW4JYaYnkSafsRiiGavtAsjvlqbDIs=";
  };

  buildInputs = [ libev ];

  checkPhase = ''
    ${python.interpreter} tests/keep-alive-behaviour.py 2>/dev/null
    ${python.interpreter} tests/test_wsgi_compliance.py
  '';

  meta = with lib; {
    homepage = "https://github.com/jonashaag/bjoern";
    description = "A screamingly fast Python 2/3 WSGI server written in C";
    license = licenses.bsd2;
    maintainers = with maintainers; [ cmcdragonkai ];
  };
}
