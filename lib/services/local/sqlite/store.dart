import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:n7bluetooth/models/local/weight.dart';
import 'package:n7bluetooth/services/local/sqlite/repo/weight_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'local_provider.dart';
import 'local_storage_key.dart';

abstract class Store {
  Future<void> init();

  // Table Preference

  /// Weight
  Future<void> saveListWeight(List<Weight> listWeight);
  Future<void> saveWeight(Weight value);
  Future<void> updateWeight(Weight value);
  Future<void> deleteWeight(Weight value);

  Future<List<Weight>> getListWeight();

  // Clear all database as logout function
  Future<void> clearAll();
  Future<void> clearRepo({String repoName});

}

class DefaultStore implements Store {

  DefaultStore._private();

  static final DefaultStore instance = DefaultStore._private();

  /// Database
  Database database;


  @override
  Future<void> init({String databaseName = 'erg_central_database.db'}) async {
    database = await LocalProvider.instance.init(databaseName: databaseName);
    debugPrint('Database version ${await database.getVersion()}');
  }

  @override
  Future<void> clearAll() async {
    await database.delete(WeightRepo.repoName);

  }


  @override
  Future<void> clearRepo({String repoName}) async {
    await database.delete(repoName);
  }


  /// For test only
  Future<void> runTest() async {
    debugPrint('RUN TEST');

    // // Clear database
    // await clearAll();
    //
    // debugPrint('TEST DONE');
  }


  @override
  Future<List<Weight>> getListWeight() async {
    final List<Weight> listWeight =  await WeightRepo().find();
    return listWeight;
  }

  @override
  Future<void> saveListWeight(List<Weight> listWeight) async {
    await WeightRepo().insertAll(listWeight);
  }

  @override
  Future<void> saveWeight(Weight value) async {
    await WeightRepo().insert(value);
  }

  @override
  Future<void> updateWeight(Weight value) async {
    await WeightRepo().update(value);
  }

  @override
  Future<void> deleteWeight(Weight value) async {
    await WeightRepo().delete(value.id);
  }

}
