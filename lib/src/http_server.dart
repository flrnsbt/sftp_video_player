import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';

import '../sftp_video_player.dart';

@protected
class SftpVideoHttpBinder {
  final VideoServerConfig videoServerConfig;

  HttpServer? _server;

  SftpVideoHttpBinder(this.videoServerConfig);

  Future<void> close([bool force = false]) async {
    await _server?.close(force: force);
    _server = null;
  }

  FutureOr<void> bind(
      {required SftpFile file, StreamVideoFormat? videoFormat}) async {
    if (_server == null) {
      try {
        final fileSize = (await file.stat()).size ?? 0;
        final mimeType = videoFormat?.mimeType ?? 'video';
        _server = await shelf_io.serve((request) async {
          final responseHeader = <String, Object>{};
          int? start;
          int? end;
          final range = request.headers['range'];
          if (range != null) {
            const bytesPrefix = "bytes=";
            if (range.startsWith(bytesPrefix)) {
              final bytesRange = range.substring(bytesPrefix.length);
              final parts = bytesRange.split("-");
              if (parts.length == 2) {
                final rangeStart = parts[0].trim();
                if (rangeStart.isNotEmpty) {
                  start = int.parse(rangeStart);
                }
                final rangeEnd = parts[1].trim();
                if (rangeEnd.isNotEmpty) {
                  end = int.parse(rangeEnd);
                }
              }
            }
          }
          responseHeader.putIfAbsent(
              HttpHeaders.contentTypeHeader, () => mimeType);
          try {
            if (request.method == "HEAD") {
              responseHeader.putIfAbsent(
                  HttpHeaders.acceptRangesHeader, () => 'bytes');
              responseHeader.putIfAbsent(
                  HttpHeaders.contentLengthHeader, () => fileSize.toString());
              return Response.ok(null, headers: responseHeader);
            } else {
              int retrievedLength;
              if (start != null && end != null) {
                retrievedLength = (end + 1) - start;
              } else if (start != null) {
                retrievedLength = fileSize - start;
              } else if (end != null) {
                retrievedLength = (end + 1);
              } else {
                retrievedLength = fileSize;
              }

              final int statusCode = (start != null || end != null) ? 206 : 200;
              start = start ?? 0;
              end = end ?? fileSize - 1;
              responseHeader.putIfAbsent(HttpHeaders.contentLengthHeader,
                  () => retrievedLength.toString());

              if (range != null) {
                responseHeader.putIfAbsent(HttpHeaders.contentRangeHeader,
                    () => 'bytes $start-$end/$fileSize');
                responseHeader.putIfAbsent(
                    HttpHeaders.acceptRangesHeader, () => 'bytes');
              }

              final stream = file
                  .read(offset: start, length: retrievedLength)
                  .handleError((e) {
                throw e;
              });
              return Response(statusCode,
                  body: stream,
                  headers: responseHeader,
                  context: {"shelf.io.buffer_output": false});
            }
          } catch (e) {
            return Response.internalServerError();
          }
        }, videoServerConfig.hostname, videoServerConfig.port);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('Video file already binded on this local http server');
    }
  }

  @override
  int get hashCode => videoServerConfig.hashCode;

  @override
  bool operator ==(covariant SftpVideoHttpBinder other) {
    return videoServerConfig == other.videoServerConfig;
  }
}
