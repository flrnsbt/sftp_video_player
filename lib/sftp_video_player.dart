library sftp_video_player;

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/rendering.dart';
import 'package:sftp_video_player/src/http_server.dart';
import 'package:sftp_video_player/sftp_video_player.dart';

export 'src/data/models/http_server_config.dart';
export 'src/data/models/stream_video_format.dart';
export 'package:video_player/video_player.dart';

class SftpVideoPlayerController extends VideoPlayerController {
  final SftpVideoHttpBinder _videoHttpBinder;
  final SftpFile file;
  final StreamVideoFormat? videoFormat;

  SftpVideoPlayerController(this.file,
      {VideoServerConfig serverConfig = const VideoServerConfig(),
      super.videoPlayerOptions,
      this.videoFormat,
      super.formatHint,
      super.closedCaptionFile})
      : _videoHttpBinder = SftpVideoHttpBinder(serverConfig),
        super.network(serverConfig.url());

  @override
  Future<void> initialize() async {
    await _videoHttpBinder.bind(file: file, videoFormat: videoFormat);
    return super.initialize();
  }

  @override
  Future<void> dispose() {
    _videoHttpBinder.close(true);
    debugPrint('Http server disposed');
    return super.dispose();
  }
}
