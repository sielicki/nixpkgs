{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, libjpeg_turbo
, numpy
, python
, substituteAll
}:

buildPythonPackage rec {
  pname = "pyturbojpeg";
  version = "1.6.5";
  format = "setuptools";

  src = fetchPypi {
    pname = "PyTurboJPEG";
    inherit version;
    sha256 = "97779e0ff5868aa550d84f7658157c79344f55db549cfef03f86eb13c3cf4e4c";
  };

  patches = [
    (substituteAll {
      src = ./lib-path.patch;
      libturbojpeg = "${libjpeg_turbo.out}/lib/libturbojpeg${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  propagatedBuildInputs = [
    numpy
  ];

  # upstream has no tests, but we want to test whether the library is found
  checkPhase = ''
    ${python.interpreter} -c 'from turbojpeg import TurboJPEG; TurboJPEG()'
  '';

  pythonImportsCheck = [
    "turbojpeg"
  ];

  meta = with lib; {
    description = "A Python wrapper of libjpeg-turbo for decoding and encoding JPEG image";
    homepage = "https://github.com/lilohuang/PyTurboJPEG";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
}
