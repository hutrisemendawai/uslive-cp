import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  WebSocketClient(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  final WebSocketChannel _channel;

  Stream<Map<String, dynamic>> messages() {
    return _channel.stream
        .map((event) => jsonDecode(event as String) as Map<String, dynamic>);
  }

  void send(Map<String, dynamic> payload) {
    _channel.sink.add(jsonEncode(payload));
  }

  void close() {
    _channel.sink.close();
  }
}
