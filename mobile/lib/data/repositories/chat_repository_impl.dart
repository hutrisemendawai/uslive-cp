import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/websocket_client.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._websocketClient);

  final WebSocketClient _websocketClient;

  @override
  Stream<List<Message>> messages(String conversationId) {
    return _websocketClient
        .messages()
        .where((payload) => payload['conversation_id'] == conversationId)
        .map((payload) => [MessageModel.fromJson(payload).toEntity()]);
  }

  @override
  Future<void> sendMessage(Message message) {
    _websocketClient.send(MessageModel.fromEntity(message).toJson());
    return Future.value();
  }
}
