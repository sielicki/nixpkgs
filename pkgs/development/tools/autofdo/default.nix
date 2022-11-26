{ lib, stdenv, fetchFromGitHub, cmake, ninja, llvm, pkgconfig, gflags, gtest, libelf, openssl, protobuf }:

stdenv.mkDerivation rec {
  pname = "autofdo";
  version = "0.19.${src.rev}";

  src = fetchFromGitHub {
    owner = "google";
    repo = pname;
    rev = "2c1e143d2a7c8545d5f1b7c625d9cde7fcb0db65";
    sha256 = "sha256-r4Or4nDQtLBDpSj3P7oaj7zH61lFJdxVuMZO7+rHOqY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ninja pkgconfig ];
  propagatedBuildInputs = [
     gflags
     gtest
     libelf
     openssl
     llvm
     protobuf
  ];

  configurePhase = ''
    mkdir build && cd build
    # upstream bug, we have to set install prefix to build/
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. -DCMAKE_PREFIX_PATH=${llvm}/lib/cmake/llvm/ ../
  '';

  buildPhase = ''
    ninja
  '';

  meta = with lib; {
    homepage = "https://github.com/google/autofdo";
    license = with licenses; [
      asl20
      bsd3
    ];
    maintainers = with maintainers; [ sielicki ];
    platforms = platforms.linux;
  };
}
