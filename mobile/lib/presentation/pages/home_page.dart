import 'package:flutter/material.dart';

import '../../data/datasources/remote/websocket_client.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/stream_messages.dart';
import '../controllers/chat_controller.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRepository = ChatRepositoryImpl(
      WebSocketClient('wss://example.com/ws'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Uslive')),
      body: Center(
        child: TextButton(
          onPressed: () {
            final controller = ChatController(
              sendMessage: SendMessage(chatRepository),
              streamMessages: StreamMessages(chatRepository),
            );
            controller.listen('general');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(controller: controller),
              ),
            );
          },
          child: const Text('Open Chat'),
        ),
      ),
    );
  }
}
