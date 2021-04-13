
import 'package:flutter/cupertino.dart';
import 'package:n7bluetooth/models/local/weight.dart';
import 'package:uuid/uuid.dart';

class LogWeightProvider with ChangeNotifier {

  //#region Properties
  //-----------------------
  /// Check showing calendar
  bool _isShowCalendar = false;

  bool get isShowCalendar => _isShowCalendar;

  set isShowCalendar(bool value) {
    _isShowCalendar = value;
    notifyListeners();
  }

  /// Current weight
  Weight currentWeight = Weight(time: DateTime.now());

  /// Edit weight
  Weight editWeight;

  /// Log weight type
 ///0: create new | 1: Update
  int logWeightType = 0;

}