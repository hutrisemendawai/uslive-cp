import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:uslive_mobile/data/datasources/local/app_database.dart';
import 'package:uslive_mobile/data/models/message_model.dart';

MessageModel _message(String id, int createdAt, {String conversationId = 'c1'}) {
  return MessageModel(
    id: id,
    conversationId: conversationId,
    senderId: 'u1',
    content: 'content $id',
    createdAt: createdAt,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('getMessagesPage returns newest first and pages with limit/offset', () async {
    for (var i = 1; i <= 5; i++) {
      await db.messagesDao.insertMessage(_message('m$i', i * 1000));
    }

    final firstPage = await db.messagesDao.getMessagesPage(
      conversationId: 'c1',
      limit: 2,
      offset: 0,
    );
    final secondPage = await db.messagesDao.getMessagesPage(
      conversationId: 'c1',
      limit: 2,
      offset: 2,
    );

    expect(firstPage.map((m) => m.id), ['m5', 'm4']);
    expect(secondPage.map((m) => m.id), ['m3', 'm2']);
  });

  test('getMessagesPage only returns messages of the requested conversation', () async {
    await db.messagesDao.insertMessage(_message('a1', 1000));
    await db.messagesDao.insertMessage(_message('b1', 2000, conversationId: 'c2'));

    final page = await db.messagesDao.getMessagesPage(
      conversationId: 'c1',
      limit: 10,
      offset: 0,
    );

    expect(page.map((m) => m.id), ['a1']);
  });

  test('insertFromWebSocket persists every payload from the stream', () async {
    final controller = StreamController<Map<String, dynamic>>();
    final done = db.messagesDao.insertFromWebSocket(controller.stream);

    controller.add(_message('w1', 1000).toJson());
    controller.add(_message('w2', 2000).toJson());
    await controller.close();
    await done;

    final page = await db.messagesDao.getMessagesPage(
      conversationId: 'c1',
      limit: 10,
      offset: 0,
    );

    expect(page.map((m) => m.id), ['w2', 'w1']);
  });
}
