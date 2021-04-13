
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqlite_api.dart';

import '../local_provider.dart';

abstract class IWrite<T> {
  Future<bool> create(Batch batch);

  Future<int> insert(T item);

  Future<List<dynamic>> insertAll(List<T> items);

  Future<int> update(T item);

  Future<int> delete(String id);

}

abstract class IRead<T> {
  // ignore: always_specify_types
  Future<List<T>> find({String where, List whereArgs});

  Future<T> findOne(String id);
}

abstract class BaseRepo<T> implements IWrite<T>, IRead<T> {
  Database database = LocalProvider.instance.database;

  String getRepoName();

  Map toMap(T item);

  T fromMap(Map<String, dynamic> map);

  @override
  Future<int> insert(T item) async {
    // ignore: unnecessary_await_in_return
    return await database.insert(getRepoName(), toMap(item) as Map<String, dynamic>,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<dynamic>> insertAll(List<T> items) async {
    final Batch batch = database.batch();

    for (final T item in items) {
      batch.insert(getRepoName(), toMap(item) as Map<String, dynamic>,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final List<dynamic> res = (await batch.commit(continueOnError: true)).map<dynamic>((dynamic d) {
      if (d is DatabaseException) {
        debugPrint(d.toString());
        return null;
      }
      return d;
    }).toList();
    return res;
  }

  @override
  Future<int> update(T item) async {
    return database.update(getRepoName(), toMap(item) as Map<String, dynamic>);
  }

  @override
  Future<int> delete(String id) async {
    return database
        .delete(getRepoName(), where: 'id = ?', whereArgs: <String>[id]);
  }


  @override
  Future<List<T>> find({String where, List<dynamic> whereArgs}) async {
    final List<Map<String, dynamic>> results =
    await database.query(getRepoName(), where: where, whereArgs: whereArgs);
    // Convert the List<Map<String, dynamic> into a List<T>.
    return List<T>.generate(results.length, (int i) => fromMap(results[i]));
  }

  @override
  Future<T> findOne(String id) async {
    final List<Map<String, dynamic>> results =
    await database.query(getRepoName(), where: 'id = ?', whereArgs: <dynamic>[id]);
    if (results.isEmpty) {
      return null;
    }
    final List<T> data = List<T>.generate(results.length, (int i) => fromMap(results[i]));
    return data[0];
  }
}
