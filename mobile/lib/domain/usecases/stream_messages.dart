import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class StreamMessages {
  const StreamMessages(this._repository);

  final ChatRepository _repository;

  Stream<List<Message>> call(String conversationId) {
    return _repository.messages(conversationId);
  }
}
