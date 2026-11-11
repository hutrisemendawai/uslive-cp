import 'package:livekit_client/livekit_client.dart';

class LiveKitManager {
  Room? _room;

  Room? get room => _room;

  Future<void> connect({required String url, required String token}) async {
    await disconnect();

    final room = Room(
      roomOptions: const RoomOptions(
        dynacast: true,
        defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
      ),
    );
    await room.connect(url, token);
    _room = room;
  }

  Future<void> setShareScreenEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('Not connected to a LiveKit room');
    }
    await participant.setScreenShareEnabled(enabled);
  }

  Future<void> toggleMicrophone() async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('Not connected to a LiveKit room');
    }
    await participant.setMicrophoneEnabled(!participant.isMicrophoneEnabled());
  }

  Future<void> toggleCamera() async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('Not connected to a LiveKit room');
    }
    await participant.setCameraEnabled(!participant.isCameraEnabled());
  }

  Future<void> disconnect() async {
    final room = _room;
    _room = null;
    if (room == null) {
      return;
    }
    await room.disconnect();
    await room.dispose();
  }
}
