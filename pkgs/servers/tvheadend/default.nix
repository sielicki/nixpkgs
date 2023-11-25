{ lib
, stdenv
, fetchFromGitHub
, fetchpatch

# buildtime
, makeWrapper
, pkg-config
, python3
, which

# runtime
, avahi
, bzip2
, dbus
, dtv-scan-tables
, ffmpeg_5
, gettext
, gnutar
, gzip
, libhdhomerun
, libiconv
, openssl
, uriparser
, zlib
}:

let
  version = "2023.11";
in stdenv.mkDerivation {
  pname = "tvheadend";
  inherit version;

  src = fetchFromGitHub {
    owner = "tvheadend";
    repo = "tvheadend";
    rev = "bc30a74de8ab5efc3605afd68eb6d01d08170316";
    sha256 = lib.fakeSha256;
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3
    which
  ];

  buildInputs = [
    avahi
    bzip2
    dbus
    ffmpeg_5
    gettext
    gzip
    libhdhomerun
    libiconv
    openssl
    uriparser
    zlib
  ];

  enableParallelBuilding = true;

  env.NIX_CFLAGS_COMPILE = toString ([
    "-Wno-error=format-truncation"
    "-Wno-error=stringop-truncation"
  ] ++ lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
    # Needed with GCC 12 but unrecognized with GCC 9
    "-Wno-error=use-after-free"
  ]);

  configureFlags = [
    # disable dvbscan, as having it enabled causes a network download which
    # cannot happen during build.  We now include the dtv-scan-tables ourselves
    "--disable-dvbscan"
    "--disable-bintray_cache"
    "--disable-ffmpeg_static"
    "--disable-libx264_static"
    "--disable-libx265_static"
    "--disable-libvpx_static"
    "--disable-libtheora_static"
    "--disable-libvorbis_static"
    "--disable-libfdkaac_static"
    "--disable-libmfx_static"
  ];

  preConfigure = ''
    patchShebangs ./configure

    substituteInPlace src/config.c \
      --replace /usr/bin/tar ${gnutar}/bin/tar

    substituteInPlace src/input/mpegts/scanfile.c \
      --replace /usr/share/dvb ${dtv-scan-tables}/share/dvbv5

    # the version detection script `support/version` reads this file if it
    # exists, so let's just use that
    echo ${version} > rpm/version
  '';

  postInstall = ''
    wrapProgram $out/bin/tvheadend \
      --prefix PATH : ${lib.makeBinPath [ bzip2 ]}
  '';

  meta = with lib; {
    description = "TV streaming server and digital video recorder";
    longDescription = ''
      Tvheadend is a TV streaming server for Linux supporting DVB-S,
      DVB-S2, DVB-C, DVB-T, ATSC, IPTV,SAT>IP and other formats
      through the unix pipe as input sources.
    '';
    homepage = "https://tvheadend.org";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ simonvandel sielicki ];
    mainProgram = "tvheadend";
  };
}
