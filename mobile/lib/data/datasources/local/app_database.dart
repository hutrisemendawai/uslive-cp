import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'daos/messages_dao.dart';
import 'tables/messages_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalMessages], daos: [MessagesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}
