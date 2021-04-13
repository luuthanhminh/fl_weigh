/*
 int id;
  String abbreviation;
  String name;
*/

import 'package:n7bluetooth/models/local/weight.dart';
import 'package:n7bluetooth/services/local/sqlite/repo/base_repo.dart';
import 'package:sqflite/sqflite.dart';

class WeightRepo extends BaseRepo<Weight> {
  static const String repoName = 'weight_repo';

  @override
  Future<bool> create(Batch batch) async {
    // ignore: leading_newlines_in_multiline_strings
    batch.execute('''CREATE TABLE $repoName ( 
                                id TEXT PRIMARY KEY,
                                weight DOUBLE,
                                time TEXT
                                )''');
    return true;
  }

  @override
  String getRepoName() {
    return repoName;
  }

  @override
  Map<String, dynamic> toMap(Weight item) {
    return item.toJson();
  }

  @override
  Weight fromMap(Map<String, dynamic> map) {
    return Weight.fromJson(map);
  }

}