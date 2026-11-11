import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  final Room room = Room();

  Future<void> connect(String url, String token) {
    return room.connect(url, token);
  }

  Future<void> disconnect() {
    return room.disconnect();
  }
}
