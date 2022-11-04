enum StreamVideoFormat with _StreamVideoFormat {
  webm('webm'),
  ogg('ogg'),
  mp4('mp4'),
  m4v('x-m4v'),
  mov('quicktime'),
  mpg('mpeg'),
  flv('x-flv'),
  f4v('x-f4v'),
  mkv('x-matroska'),
  h264('h264'),
  wmv('x-ms-wmv');

  @override
  final String _mimeType;

  static custom(String fileExtension, String mimeType) {
    return CustomStreamVideoFormat(fileExtension, mimeType);
  }

  static from(String fileExtension) {
    return StreamVideoFormat.values.singleWhere((e) => e.name == fileExtension);
  }

  const StreamVideoFormat(this._mimeType);
}

class CustomStreamVideoFormat with _StreamVideoFormat {
  final String fileExtension;

  const CustomStreamVideoFormat(this.fileExtension, String mimeType)
      : _mimeType = mimeType;

  @override
  final String _mimeType;
}

abstract class _StreamVideoFormat {
  String get mimeType => "video/$_mimeType";

  String get _mimeType;
}
