import 'package:sqflite_common/sqlite_api.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV2 extends Migration {
  @override
  void create(Batch batch) {
    batch.execute('create table teste (id integer)');
  }

  @override
  void upgrade(Batch batch) {
    batch.execute('create table teste (id integer)');
  }
}
