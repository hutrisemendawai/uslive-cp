import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> messages(String conversationId);

  Future<void> sendMessage(Message message);
}
