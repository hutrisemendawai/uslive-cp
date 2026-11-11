import 'package:flutter/material.dart';

import '../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return ListView.builder(
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return ListTile(
                title: Text(message.senderId),
                subtitle: Text(message.content),
              );
            },
          );
        },
      ),
    );
  }
}
