import 'dart:io';

const kHostname = "127.0.0.1";
const kPort = 8080;

class VideoServerConfig {
  final String hostname;
  final int port;
  final bool ssl;
  final SecurityContext? securityContext;

  const VideoServerConfig(
      {this.hostname = kHostname,
      this.port = kPort,
      this.ssl = false,
      this.securityContext});

  String url() {
    var url = "http";
    if (ssl) {
      url += "s";
    }
    return "$url://$hostname:$port";
  }

  @override
  String toString() =>
      'VideoServerConfig(hostname: $hostname, port: $port, ssl: $ssl)';

  @override
  int get hashCode => hostname.hashCode ^ port.hashCode ^ ssl.hashCode;

  @override
  bool operator ==(covariant VideoServerConfig other) {
    return other.ssl == ssl && other.hostname == hostname && other.port == port;
  }
}
