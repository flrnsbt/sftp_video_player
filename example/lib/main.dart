import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:sftp_video_player/sftp_video_player.dart';
import 'test_conf.dart' as test_config;

Future<void> main() async {
  final file = await test_config.getTestFile();
  runApp(MyApp(file: file));
}

class MyApp extends StatefulWidget {
  final SftpFile file;
  const MyApp({super.key, required this.file});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SftpVideoPlayerController? _controller;
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    debugPrint('Started playing: ${widget.file}');
    () async {
      final fileStat = await widget.file.stat();
      debugPrint(fileStat.toString());
    }();
    _controller = SftpVideoPlayerController(widget.file,
        videoFormat: test_config.videoFormat,
        serverConfig: test_config.serverConfig);
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.initialize().then((value) {
      _initialized = true;
      _controller!.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
              child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                    aspectRatio: 16 / 9, child: VideoPlayer(_controller!)),
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }

                          setState(() {});
                        },
                        color: Colors.white,
                        icon: Icon(_controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow)),
                    IconButton(
                        color: Colors.white,
                        onPressed: () {
                          _controller!.seekTo(const Duration(seconds: 0));

                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                )
              ],
            ),
          )),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
