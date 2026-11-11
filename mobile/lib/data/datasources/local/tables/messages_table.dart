import 'package:drift/drift.dart';

@DataClassName('LocalMessage')
@TableIndex(name: 'messages_conversation_created', columns: {#conversationId, #createdAt})
class LocalMessages extends Table {
  @override
  String get tableName => 'messages';

  TextColumn get id => text()();
  TextColumn get conversationId => text().named('conversation_id')();
  TextColumn get senderId => text().named('sender_id')();
  TextColumn get content => text()();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
