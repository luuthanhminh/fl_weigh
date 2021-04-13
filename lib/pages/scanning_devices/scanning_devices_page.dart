import 'package:flutter/material.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/pages/scanning_devices/scanning_devices_provider.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/services/local/local_storage_key.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:n7bluetooth/utils/app_asset.dart';
import 'package:n7bluetooth/utils/app_color.dart';
import 'package:n7bluetooth/utils/app_constant.dart';
import 'package:n7bluetooth/utils/app_route.dart';
import 'package:n7bluetooth/utils/app_style.dart';
import 'package:n7bluetooth/utils/app_extension.dart';
import 'package:provider/provider.dart';

class ScanningDevicesPage extends StatefulWidget {
  @override
  _ScanningDevicesPageState createState() => _ScanningDevicesPageState();
}

class _ScanningDevicesPageState extends State<ScanningDevicesPage>
    with DynamicSize {

  //#region Privates properties
  //-----------------

  //#region Life cycles
  //----------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Start scan BLE devices
      Provider.of<ScanningDevicesProvider>(context, listen: false).scanBLEDevices();
    });
  }

  //#region methods
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
            SizedBox(
              height: 40.H,
            ),
            Stack(
              children: <Widget>[
                Positioned(
                  left: 30.W,
                  child: InkWell(
                    child: Container(
                      width: 30.W,
                      height: 30.W,
                      child: Image.asset(AppImages.icBack),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 5.H,),
                      Text(
                        'Bluetooth',
                        style: boldTextStyle(20.SP, Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.H,
            ),
            Center(
              child: Text(
                'Choose your connected bluetooth  ',
                style: normalTextStyle(14.SP, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 40.H,
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 40.W, vertical: 20.H),
                    itemCount: context.watch<ScanningDevicesProvider>().bluetoothDevices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () async {
                          //Push to detail info of BLE device
                          context.read<DetailInfoProvider>().bluetoothDevice = context.read<ScanningDevicesProvider>().bluetoothDevices[index];
                          context.read<Storage>().saveData(LocalStorageKey.bluetoothNameKey, context.read<DetailInfoProvider>().bluetoothDevice.name);
                          context.navigator().pushNamed(AppConstant.detailInfoPageRoute);
                        },
                        child: Container(
                          height: 40.H,
                          child: Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(context.watch<ScanningDevicesProvider>().bluetoothDevices[index].name, style: normalTextStyle(14.SP, color: Colors.white),)
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 0.5,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
