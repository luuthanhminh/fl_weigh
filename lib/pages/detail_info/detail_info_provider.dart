
import 'dart:async';
import 'dart:ffi';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:n7bluetooth/models/local/weight.dart';
import 'package:n7bluetooth/services/easy_debounce.dart';
import 'package:n7bluetooth/services/local/local_storage_key.dart';
import 'package:n7bluetooth/services/local/sqlite/store.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as protos;
import 'package:n7bluetooth/utils/app_helper.dart';
import 'package:n7bluetooth/utils/app_log.dart';
import 'package:tuple/tuple.dart';

class DetailInfoProvider with ChangeNotifier {

  DetailInfoProvider(this._storage);

  //#region DI services
  //-----------------
  final Storage _storage;

  //#region Privates properties
  //-----------------
  final String _weightCharacteristicsUUID = '00002a9c-0000-1000-8000-00805f9b34fb';

  //#region Public properties
  //-----------------
  //Bluetooth device
  BluetoothDevice bluetoothDevice;

  //Weight value for display on UI
  double weightValue = 0;

  //List weight chart data per day
  List<double> weightChartData = <double>[0, 0, 0, 0, 0, 0, 0];

  //Check is showing weight detail
  bool isShowingWeightDetail = false;

  /// Selection bottom chart mode
  /// 0: DAY, 1: WEEK, 2: MONTH
  int _selectedBottomChartMode = 0;

  int get selectedBottomChartMode => _selectedBottomChartMode;

  set selectedBottomChartMode(int value) {
    _selectedBottomChartMode = value;
    filterWeightChartData(_selectedBottomChartMode);
    notifyListeners();
  }

  bool isSaveData = false;

  StreamController<double> weightStreamController = StreamController<double>();
  StreamController<bool> saveWeightDataStreamController = StreamController<bool>();

  /// Day chart data on top
  List<Weight> dayChartData = <Weight>[];

  /// Summarize chart data on bottom
  List<Weight> summaryChartData = <Weight>[];

  /// Average weight value on top
  double _averageWeightOnTop = 0;

  double get averageWeightOnTop => _averageWeightOnTop;

  set averageWeightOnTop(double value) {
    _averageWeightOnTop = value;
    notifyListeners();
  }

  /// Average weight value on top
  double _averageWeightOnBottom = 0;

  double get averageWeightOnBottom => _averageWeightOnBottom;

  set averageWeightOnBottom(double value) {
    _averageWeightOnBottom = value;
    notifyListeners();
  }

  /// Selected weight
  Weight selectedWeight;

  /// Is showing Edit and Delete weight button
  bool _isShowDeleteAndEditButton = false;

  bool get isShowDeleteAndEditButton => _isShowDeleteAndEditButton;

  set isShowDeleteAndEditButton(bool value) {
    _isShowDeleteAndEditButton = value;
    notifyListeners();
  }
  //#region Methods
  //-----------------
  //Read info from BLE device
  Future<void> readInfoFromBLEDevice() async {
    logger.d('Start readInfoFromBLEDevice');
    if (bluetoothDevice != null) {
      //Connect to device
      final String _connectedDevice = await _storage.getData(LocalStorageKey.bluetoothNameKey);
      if (_connectedDevice == null) {
        await bluetoothDevice.connect();
      }

      logger.d('Bluetooth connected');

      //Get all services of this BLE
      final List<BluetoothService> services = await bluetoothDevice.discoverServices();

      for (final BluetoothService service in services) {
        // Reads all characteristics
        final List<BluetoothCharacteristic> characteristics = service.characteristics;
        for(final BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _weightCharacteristicsUUID) {
            await c.setNotifyValue(true);
            // ignore: void_checks
            c.value.listen((List<int> value) async {
              weightValue = _calculateWeight(data: value);
              logger.d(weightValue);
              weightStreamController.add(weightValue);
              EasyDebounce.debounce('my-weigh-debounce',
                  const Duration(milliseconds: 3000), () { // ignore: void_checks
                        //Save data to local
                    isSaveData = true;
                        saveWeightDataStreamController.add(true);
                  }
              );
              notifyListeners();
            });
          }

        }
      }

    }
  }

  Future<double> getWeightValue() async {
    return weightValue;
  }

  Future<bool> getSaveChartDataStatusValue() async {
    return isSaveData;
  }

  //Calculate weight from list bytes data
  double _calculateWeight({List<int> data}) {
    if (data.length > 12) {
      return (((data[12] & 0xFF) << 8) | (data[11] & 0xFF)) / 200.0;
    }
    return 0;
  }



  ///Add weight to data
  void addDayChartDataOnTop(Weight weight) {
    dayChartData.add(weight);
    notifyListeners();
  }

  /// Load list day chart data local
  Future<void> loadListDayChart() async {
    final List<Weight> data = await DefaultStore.instance.getListWeight();
    if (data != null) {
      filterWeightChartData(0);
      // notifyListeners();
    }

  }

  bool _checkDateInThisWeek(DateTime date) {
    final DateTime currentDay = DateTime.now();
    final DateTime firstDateOfTheWeek = AppHelper.findFirstDateOfTheWeek(currentDay);
    final DateTime lastDateOfTheWeek = AppHelper.findLastDateOfTheWeek(currentDay);

    if (date.isSameDate(firstDateOfTheWeek) || date.isSameDate(lastDateOfTheWeek)) {
    return true;
    }

    if (date.isAfter(firstDateOfTheWeek) && date.isBefore(lastDateOfTheWeek)) {
      return true;
    }

    return false;
  }

  bool _checkDateInThisMonth(DateTime date) {
    final int currentMonth = DateTime.now().month;
    if (date.month == currentMonth) {
      return true;
    }
    return false;
  }



  /// Filter data chart
  /// type: 0: day, 1: week, 2: month
  Future<void> filterWeightChartData(int type) async {
    final List<Weight> allData = await DefaultStore.instance.getListWeight();

    if (allData == null) {
      return <Weight>[];
    }

    ///Handle all data on top
    final List<Weight> _allWeight = allData.where((Weight i) => i.weight != null).toList();
    _allWeight.sort( (Weight a, Weight b) {
      final DateTime aTime = a.time;
      final DateTime bTime = b.time;
      return aTime.compareTo(bTime);
    });
    dayChartData = _allWeight;
    double sumWeight = 0;
    for (final Weight i in _allWeight) {
      sumWeight += i.weight;
    }
    averageWeightOnTop = sumWeight / _allWeight.length;


    List<Weight> weightList = <Weight>[];
    if (type == 0) {
      weightList = allData.where((Weight i) => i.time.isToday()).toList();
      weightList.sort( (Weight a, Weight b) {
        final DateTime aTime = a.time;
        final DateTime bTime = b.time;
        return aTime.compareTo(bTime);
      });
      double sumWeight = 0;
      for (final Weight i in weightList) {
        sumWeight += i.weight;
      }
      averageWeightOnBottom = sumWeight / weightList.length;
      summaryChartData = weightList;
      logger.d('weightList lenght: ${weightList.length}');
    } else if (type == 1) {
      weightList = allData.where((Weight i) => _checkDateInThisWeek(i.time)).toList();
      weightList.sort( (Weight a, Weight b) {
        final DateTime aTime = a.time;
        final DateTime bTime = b.time;
        return aTime.compareTo(bTime);
      });
      double sumWeight = 0;
      for (final Weight i in weightList) {
        sumWeight += i.weight;
      }
      averageWeightOnBottom = sumWeight / weightList.length;

      summaryChartData = weightList;
    } else {
      weightList = allData.where((Weight i) => _checkDateInThisMonth(i.time)).toList();
      weightList.sort( (Weight a, Weight b) {
        final DateTime aTime = a.time;
        final DateTime bTime = b.time;
        return aTime.compareTo(bTime);
      });
      double sumWeight = 0;
      for (final Weight i in weightList) {
        sumWeight += i.weight;
      }
      averageWeightOnBottom = sumWeight / weightList.length;

      summaryChartData = weightList;
    }
    notifyListeners();
  }

  /// Update weight chart data
  Future<void> updateWeightChartData() async {
    filterWeightChartData(selectedBottomChartMode);
  }

}