import 'package:drift/drift.dart';

import '../../../models/message_model.dart';
import '../app_database.dart';
import '../tables/messages_table.dart';

part 'messages_dao.g.dart';

@DriftAccessors(tables: [LocalMessages])
class MessagesDao extends DatabaseAccessor<AppDatabase> with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Future<void> insertMessage(MessageModel message) {
    return into(localMessages).insert(
      LocalMessagesCompanion.insert(
        id: message.id,
        conversationId: message.conversationId,
        senderId: message.senderId,
        content: message.content,
        createdAt: message.createdAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> insertFromWebSocket(Stream<Map<String, dynamic>> payloads) async {
    await for (final payload in payloads) {
      await insertMessage(MessageModel.fromJson(payload));
    }
  }

  Future<List<MessageModel>> getMessagesPage({
    required String conversationId,
    required int limit,
    required int offset,
  }) async {
    final rows = await (select(localMessages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([
            (m) => OrderingTerm.desc(m.createdAt),
            (m) => OrderingTerm.desc(m.id),
          ])
          ..limit(limit, offset: offset))
        .get();

    return rows
        .map(
          (row) => MessageModel(
            id: row.id,
            conversationId: row.conversationId,
            senderId: row.senderId,
            content: row.content,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }
}
