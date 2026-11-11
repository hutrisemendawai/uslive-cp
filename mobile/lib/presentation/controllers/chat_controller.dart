import 'package:flutter/foundation.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/stream_messages.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required SendMessage sendMessage,
    required StreamMessages streamMessages,
  })  : _sendMessage = sendMessage,
        _streamMessages = streamMessages;

  final SendMessage _sendMessage;
  final StreamMessages _streamMessages;

  List<Message> messages = [];

  void listen(String conversationId) {
    _streamMessages.call(conversationId).listen((items) {
      messages = items;
      notifyListeners();
    });
  }

  Future<void> send(Message message) {
    return _sendMessage.call(message);
  }
}
