import 'package:n7bluetooth/services/local/sqlite/migrate/migrate.dart';
import 'package:n7bluetooth/services/local/sqlite/migrate/migrate_v1.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// https://pub.dev/packages/sqflite
class LocalProvider {
  ///Create api instance
  LocalProvider._private();

  static final LocalProvider instance = LocalProvider._private();

  ///Database instance
  Database database;

  ///Init database connection
  Future<Database> init({String databaseName}) async {
    if (database != null && database.isOpen) {
      database.close();
    }
    return database = await openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: (Database db, int version) async {
        // Data types: https://www.sqlite.org/datatype3.html
        Migrate migrate;
        switch (version) {
          case 1:
            migrate = MigrateV1();
            break;
          // case 2:
          //   migrate = MigrateV2();
          //   break;
          // case 3:
          //   migrate = MigrateV3();
        }

        // Create as new installation
        if (migrate != null) {
          final Batch batch = db.batch();
          await migrate.create(batch);
          await batch.commit();
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        Migrate migrate;
        switch (newVersion) {
          case 1:
            migrate = MigrateV1();
            break;
          // case 2:
          //   migrate = MigrateV2();
          //   break;
          // case 3:
          //   migrate = MigrateV3();
          //   break;
        }

        // Upgrade as a upgrade from old database
        if (migrate != null) {
          final Batch batch = db.batch();
          await migrate.upgrade(batch);
          await batch.commit();
        }
      },
      onDowngrade: onDatabaseDowngradeDelete,
      version: 1,
    );
  }
}
