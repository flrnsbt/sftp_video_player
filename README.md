<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Simple video player built on the official Flutter package "video_player" which implements some capabilities to play a video from an SFTP file using an HTTP server.

The main reason I decided to create this package is firstly to practice and secondly because when I tried to stream videos from a server using SFTP protocol I had some difficulties to play them properly using the default Flutter video_player, hoping that a package like this will make life easier for some people.

## Features

Play a video from an SFTP file via the DartSSH2 package. Basic functionality built on top of the video_player package, so it can also be used with Chewie.
## Getting started

The requirements are the same as for the video_player package, making sure that for Android, internet permissions are given in the AndroidManifest file, and also that cleartext traffic is allowed, unless you choose to use an secure connection with an SSL certificate. The package uses shelf to create the HTTP server, and by using the SecurityContext class you can get around this. 

For iOS, you need to add entries to the Info.plist file regarding the NSAppTransportSecurity key, adding dictionary entries (NSAllowsLocalNetworking and NSAllowsArbitraryLoads).

For the Web, the limitations are those of the dartssh2 package which uses native sockets.

To help you with the prerequisites just follow the test version of the package in the example folder.

## Usage

Use the SftpVideoPlayerController to instantiate a video_player from an SftpFile source. As the class extends VideoPlayerController, you can use it with the VideoPlayer widget or the ChewieController.

```dart
    final SftpFile file;
    SftpVideoPlayerController? _controller;
    
    @override
    void initState(){
        super.initState();
        _controller = SftpVideoPlayerController(file,
        videoFormat: StreamVideoFormat.mp4,
        serverConfig:     VideoServerConfig(hostname: '127.0.0.1', port: 8080, ssl: false));
        _controller!.initialize().then((value) {
            _initialized = true;
            _controller!.play();
            setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        return VideoPlayer(_controller!));
    }

    
```

