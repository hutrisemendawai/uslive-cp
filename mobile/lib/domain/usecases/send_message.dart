import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  const SendMessage(this._repository);

  final ChatRepository _repository;

  Future<void> call(Message message) {
    return _repository.sendMessage(message);
  }
}
