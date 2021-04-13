
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:n7bluetooth/services/local/local_storage_key.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:n7bluetooth/utils/app_log.dart';
import 'package:tuple/tuple.dart';

class ScanningDevicesProvider with ChangeNotifier {

  ScanningDevicesProvider(this._storage);

  //#region Privates properties
  //-----------------
  //Flutter blue instance
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  //Bluetooth devices name list
  final List<String> _bluetoothDevicesName = <String>[];

  //Storage
  final Storage _storage;

  //#region Public properties
  //-----------------
  //Bluetooth devices list
  List<BluetoothDevice> bluetoothDevices = <BluetoothDevice>[];

  //#region Methods
  //-----------------
  //Start scan BLE devices
  Future<void> scanBLEDevices() async {
    // Start scanning
    _flutterBlue.startScan(timeout: const Duration(seconds: 10));

    // Listen to scan results
    _flutterBlue.scanResults.listen((List<ScanResult> results) async {
      for (final ScanResult r in results) {
        logger.d('Ble name: ${r.device.name}');
        if (!_bluetoothDevicesName.contains(r.device.name)) {
          _bluetoothDevicesName.add(r.device.name);
          bluetoothDevices.add(r.device);
          notifyListeners();
        }
      }
    });

    if (bluetoothDevices.isNotEmpty) {
      logger.d('scanBLEDevices result: ${bluetoothDevices.length}');
      // Stop scanning

    }
    _flutterBlue.stopScan();

  }

  //Auto connect BLE device
  Future<Tuple2<bool, BluetoothDevice>> autoConnectBLEDevice() async {
    //Check if connected a bluetooth before -> auto connect
    final String _connectedBluetoothName = await _storage.getData(LocalStorageKey.bluetoothNameKey);
    for (final BluetoothDevice r in bluetoothDevices) {
      if (_connectedBluetoothName != null) {
        if (r.name == _connectedBluetoothName) {
          await r.connect();
          return Tuple2<bool, BluetoothDevice>(true, r);
        }
      }
    }
    return const Tuple2<bool, BluetoothDevice>(false, null);
  }



}