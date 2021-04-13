
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/pages/scanning_devices/scanning_devices_provider.dart';
import 'package:n7bluetooth/services/app_loading.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/services/local/local_storage_key.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:n7bluetooth/utils/app_asset.dart';
import 'package:n7bluetooth/utils/app_color.dart';
import 'package:n7bluetooth/utils/app_constant.dart';
import 'package:n7bluetooth/utils/app_extension.dart';
import 'package:n7bluetooth/utils/app_helper.dart';
import 'package:n7bluetooth/utils/app_style.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SelectDevicesPage extends StatefulWidget {
  @override
  _SelectDevicesPageState createState() => _SelectDevicesPageState();
}

class _SelectDevicesPageState extends State<SelectDevicesPage> with DynamicSize {


  @override
  void initState() {
    super.initState();

    // Load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String connectedBluetoothName =
      await context.read<Storage>().getData(LocalStorageKey.bluetoothNameKey);
      if (connectedBluetoothName != null) {
        await context.read<ScanningDevicesProvider>().scanBLEDevices();
      }
    });

  }

  //#region METHODS
  //----------------
  /// Handle when select MI-scale
  Future<void> _handleWhenSelectMiScale() async {
    final String _connectedDeviceName = await context.read<Storage>().getData(LocalStorageKey.bluetoothNameKey);
    if (_connectedDeviceName != null) {
      Navigator.of(context).pushNamed(AppConstant.detailInfoPageRoute);
    } else {
      Navigator.of(context).pushNamed(AppConstant.scanningDevicesPageRoute);
    }
    // Navigator.of(context).pushNamed(AppConstant.detailInfoPageRoute);
  }

  //#region BUILD
  //----------------
  @override
  Widget build(BuildContext context) {
    //Init screen dynamic size
    initDynamicSize(context);

    return Material(
      child: Container(
        color: AppColors.mainBackgroundColor,
        child: Column(
          children: <Widget>[
            SizedBox(height: 61.H,),
            Center(
              child: Text('Devices', style: normalTextStyle(50.SP, color: Colors.white),),
            ),
            SizedBox(height: 10.H,),
            Center(
              child: Text('Choose your Connected Devices', style: normalTextStyle(14.SP, color: Colors.white),),
            ),
            SizedBox(height: 40.H,),
            Container(
              margin: EdgeInsets.only(left: 30.W, right: 30.W),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    child: Container(
                      width: 150.W,
                      height: 150.W,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Image.asset(AppImages.icSmartScale),
                    ),
                      onTap: () async {
                        await _handleWhenSelectMiScale();
                      }
                  ),
                  Container(
                    width: 150.W,
                    height: 150.W,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                      child: Image.asset(AppImages.icSmartWatch),
                  )
                ],
              ),
            ),
            SizedBox(height: 20.H,),

          ],
        ),
      ),
    );
  }
}
