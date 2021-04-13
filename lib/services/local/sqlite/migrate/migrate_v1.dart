
import 'package:n7bluetooth/services/local/sqlite/repo/weight_repo.dart';
import 'package:sqflite/sqlite_api.dart';
import 'migrate.dart';

class MigrateV1 implements Migrate {
  @override
  Future<void> create(Batch batch) async {
    await WeightRepo().create(batch);

  }

  @override
  Future<void> upgrade(Batch batch) async {
    // With the first version (v1) no need to upgrade anything
    // do nothing here
  }
}
