{ stdenv, mkDerivation, fetchurl, autoPatchelfHook
, ffmpeg, openssl, qtbase, zlib, pkgconfig
}:

let
  version = "1.15.0";
  # Using two URLs as the first one will break as soon as a new version is released
  src_bin = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-bin-${version}.tar.gz"
    ];
    sha256 = "1zr63fqx4qcrnrbg1f97w9mp3yzzxf0dk8pw60y2d4436vanfba4";
  };
  src_oss = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-oss-${version}.tar.gz"
    ];
    sha256 = "01pdydll37inkq74874rqd5kk0maafnm1lqcv41jzgzjrfkky8d9";
  };
in mkDerivation {
  pname = "makemkv";
  inherit version;

  srcs = [ src_bin src_oss ];

  sourceRoot = "makemkv-oss-${version}";

  nativeBuildInputs = [ autoPatchelfHook pkgconfig ];

  buildInputs = [ ffmpeg openssl qtbase zlib ];

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin           out/makemkv ../makemkv-bin-${version}/bin/amd64/makemkvcon
    install -D     -t $out/lib           out/lib{driveio,makemkv,mmbd}.so.*
    install -D     -t $out/share/MakeMKV ../makemkv-bin-${version}/src/share/*

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Convert blu-ray and dvd to mkv";
    longDescription = ''
      makemkv is a one-click QT application that transcodes an encrypted
      blu-ray or DVD disc into a more portable set of mkv files, preserving
      subtitles, chapter marks, all video and audio tracks.

      Program is time-limited -- it will stop functioning after 60 days. You
      can always download the latest version from makemkv.com that will reset the
      expiration date.
    '';
    license = licenses.unfree;
    homepage = "http://makemkv.com";
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.titanous ];
  };
}
