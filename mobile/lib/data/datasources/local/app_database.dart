import 'package:drift/drift.dart';
import 'package:drift/native.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await customStatement('''
            CREATE TABLE messages (
              id TEXT PRIMARY KEY,
              conversation_id TEXT NOT NULL,
              sender_id TEXT NOT NULL,
              content TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
        },
      );

  Future<List<Map<String, dynamic>>> messages() async {
    final rows = await customSelect(
      'SELECT * FROM messages ORDER BY created_at ASC',
    ).get();
    return rows.map((row) => row.data).toList();
  }
}
