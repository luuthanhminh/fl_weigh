
import 'package:sqflite/sqlite_api.dart';

abstract class Migrate {
  // Handle the creation of a fresh database in onCreate
  Future<void> create(Batch batch);

  // Handle the schema migration in onUpgrade
  Future<void> upgrade(Batch batch);
}

