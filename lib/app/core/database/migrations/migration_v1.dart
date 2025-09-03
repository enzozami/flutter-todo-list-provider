import 'package:sqflite_common/sqlite_api.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV1 extends Migration {
  @override
  void create(Batch batch) {
    batch.execute('''
      create table todo(
        id Integer primary key autoincrement,
        descricao varchar(500) not null, 
        data_hora datetime, 
        finalizando integer,
        user_id varchar(100) not null
      )
''');
  }

  @override
  void upgrade(Batch batch) {}
}
