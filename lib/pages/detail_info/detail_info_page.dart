import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:n7bluetooth/pages/log_weight/log_weight_provider.dart';
import 'package:n7bluetooth/pages/scanning_devices/scanning_devices_provider.dart';
import 'package:n7bluetooth/pages/weight_detail/weight_detail_page.dart';
import 'package:n7bluetooth/services/app_loading.dart';
import 'package:n7bluetooth/services/local/local_storage_key.dart';
import 'package:n7bluetooth/services/local/sqlite/store.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:n7bluetooth/utils/app_constant.dart';
import 'package:n7bluetooth/utils/app_helper.dart';
import 'package:n7bluetooth/utils/app_log.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/utils/app_asset.dart';
import 'package:n7bluetooth/utils/app_color.dart';
import 'package:n7bluetooth/utils/app_extension.dart';
import 'package:n7bluetooth/utils/app_style.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart' as intl;

class DetailInfoPage extends StatefulWidget {

  final List<Color> availableColors = <Color>[
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  _DetailInfoPageState createState() => _DetailInfoPageState();
}

class _DetailInfoPageState extends State<DetailInfoPage> with DynamicSize {

  //#region public properties
  //-----------------
  DetailInfoProvider _detailInfoProvider;  
  
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex;
  bool isPlaying = false;

  bool isShowEditDeleteButton = false;

  //#region Life cycles
  //-----------------
  @override
  void initState() {
    super.initState();

    _detailInfoProvider = Provider.of<DetailInfoProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async{


      AppLoadingProvider.show(context);
      context.read<DetailInfoProvider>().selectedBottomChartMode = 0;
      AppLoadingProvider.hide(context);

      final String _connectedDeviceName = await context.read<Storage>().getData(LocalStorageKey.bluetoothNameKey);
      if (_connectedDeviceName != null) {
        await _autoConnectBLE();
      }

      await _detailInfoProvider.readInfoFromBLEDevice();

      _listenWeightSignal();
    });
  }

  @override
  void dispose() {
    _detailInfoProvider.weightStreamController.close();
    super.dispose();
  }

  //#region METHOD
  //-----------------
  void showConfirmDeleteDialog(BuildContext context) {
    if (context.read<DetailInfoProvider>().selectedWeight == null) {
      AppHelper.showToast('Please long-tap to select weight.');
      return;
    }
    // set up the buttons
    final Widget cancelButton = FlatButton(
      child: const Text('Cancel'),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    final Widget continueButton = FlatButton(
      child: const Text('OK'),
      onPressed:  () {
        Navigator.pop(context);
        DefaultStore.instance.deleteWeight(context.read<DetailInfoProvider>().selectedWeight);

        _detailInfoProvider.filterWeightChartData(_detailInfoProvider.selectedBottomChartMode);
      },
    );

    // set up the AlertDialog
    final AlertDialog alert = AlertDialog(
      title: const Text(''),
      content: const Text('Do you want to delete this weight?'),
      actions: <Widget>[
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _listenWeightSignal() {
    final Stream<double> stream = _detailInfoProvider.weightStreamController.stream;
    stream.listen((double data) {
      logger.d('Weight data from stream: $data');
      if (!_detailInfoProvider.isShowingWeightDetail) {
        _detailInfoProvider.isShowingWeightDetail = true;
        showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext buildContext) {
          return WeightDetailPage();
        });
      }
    }, onDone: () {
      
    }, onError: (dynamic error) {
      
    });
    
  }

  Future<void> _autoConnectBLE() async {
    final Tuple2<bool, BluetoothDevice> result = await context.read<ScanningDevicesProvider>().autoConnectBLEDevice();
    if (result.item1) {
      context.read<DetailInfoProvider>().bluetoothDevice = result.item2;
    }
  }

  Widget _topChart(BuildContext context) {

    if (_detailInfoProvider.dayChartData.isEmpty) {
      return Container(
        child: Center(
          child: Text(
              'Empty chart data', style: normalTextStyle(16.SP, color: Colors.white)),
        ),
      );
    }

    final List<double> _xAxisDayChart = <double>[];
    for (int i = 0; i < _detailInfoProvider.dayChartData?.length; i++) {
      _xAxisDayChart.add(i.toDouble());
    }

    final List<DataPoint> _dataPointsDayChart = <DataPoint>[];
    for (int i = 0; i < _detailInfoProvider.dayChartData?.length; i++) {
      final DataPoint _dataPoint = DataPoint<double>(value: _detailInfoProvider.dayChartData[i].weight, xAxis: _xAxisDayChart[i]);
      _dataPointsDayChart.add(_dataPoint);
    }

    final fromDate = DateTime(2019, 09, 1);
    final toDate = DateTime(2019, 09, 30);

    return Consumer<DetailInfoProvider>(
      builder: (BuildContext context, DetailInfoProvider provider, _) {
        return (provider.dayChartData?.isNotEmpty) ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0C46B2).withOpacity(0),
                const Color(0xFF0C46B2).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Container(
                      height: 250.H,
                      width: MediaQuery.of(context).size.width,
                      child: BezierChart(
                        onValueSelected: (double value) {
                          final int _selectedIndex = value.toInt();
                          provider.selectedWeight = provider.dayChartData[_selectedIndex];
                          print('kn7: $value');
                        },
                        bezierChartScale: BezierChartScale.CUSTOM,
                        bubbleLabelDateTimeBuilder: (DateTime dateTime, BezierChartScale benzier) {
                          return '';
                        },
                        bubbleLabelValueBuilder: (double value) {
                          return '';
                        },
                        xAxisCustomValues: _xAxisDayChart,
                        series: <BezierLine>[
                          BezierLine(
                            dataPointFillColor: Colors.transparent,
                            lineStrokeWidth: 1.0,
                            label: 'kg',
                            data: _dataPointsDayChart,
                          ),
                        ],
                        config: BezierChartConfig(
                          startYAxisFromNonZeroValue: false,
                          bubbleIndicatorColor: Colors.white.withOpacity(0.9),
                          footerHeight: 0,
                          verticalIndicatorStrokeWidth: 0.2,
                          verticalIndicatorColor: Colors.black26,
                          showVerticalIndicator: true,
                          verticalIndicatorFixedPosition: false,
                          displayYAxis: false,
                          stepsYAxis: 10,
                          // backgroundColor: AppColors.mainBackgroundColor,
                          snap: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 40.H,
                  right: 30.W,
                  child:  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          showConfirmDeleteDialog(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.all(Radius.circular(18.SP))
                          ),
                          width: 50.W,
                          height: 30.H,
                          child: Center(
                            child: Text('Delete', style: boldTextStyle(12.SP, Colors.white),),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.W,),
                      InkWell(
                        onTap: () {
                          if (context.read<DetailInfoProvider>().selectedWeight == null) {
                            AppHelper.showToast('Please long-tap to select weight.');
                            return;
                          }
                          context.read<LogWeightProvider>().editWeight = _detailInfoProvider.selectedWeight;
                          context.read<LogWeightProvider>().logWeightType = 1;
                          Navigator.of(context).pushNamed(AppConstant.logWeightPageRoute);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.all(Radius.circular(18.SP))
                          ),
                          width: 50.W,
                          height: 30.H,
                          child: Center(
                            child: Text('Edit', style: boldTextStyle(12.SP, Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        ) :
        Container(
          child: Center(
            child: Text(
              'Empty chart data', style: normalTextStyle(16.SP, color: Colors.white)),
            ),
        );
      }
    );
  }

  Widget _bottomChart(BuildContext context) {

    if (_detailInfoProvider.summaryChartData.isEmpty) {
      return Container(
        child: Center(
          child: Text(
              'Empty chart data', style: normalTextStyle(16.SP, color: Colors.black)),
        ),
      );
    }

    List<double> _xAxisSummaryChart = <double>[];

    for (int i = 0; i < _detailInfoProvider.summaryChartData.length; i++) {
      _xAxisSummaryChart.add(i.toDouble());
    }

    List<DataPoint> _dataPointsSummaryChart = <DataPoint>[];
    for (int i = 0; i < _detailInfoProvider.summaryChartData.length; i++) {
      final DataPoint _dataPoint = DataPoint<double>(value: _detailInfoProvider.summaryChartData[i].weight, xAxis: _xAxisSummaryChart[i]);
      _dataPointsSummaryChart.add(_dataPoint);
    }


    return Consumer<DetailInfoProvider>(
      builder: (BuildContext context, DetailInfoProvider provider, _) {
        return provider.summaryChartData.isNotEmpty ? Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.mainBackgroundColor.withOpacity(0),
                AppColors.mainBackgroundColor.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 150.H,
                  width: MediaQuery.of(context).size.width,
                  child: BezierChart(
                    bezierChartScale: BezierChartScale.CUSTOM,
                    xAxisCustomValues: _xAxisSummaryChart ?? [],
                    footerValueBuilder: (double value) {
                      return '';
                    },
                    series: [
                      BezierLine(
                        lineColor: AppColors.mainBackgroundColor,
                        dataPointFillColor: Colors.transparent,
                        dataPointStrokeColor: Colors.transparent,
                        lineStrokeWidth: 1.0,
                        label: 'kg',
                        data: _dataPointsSummaryChart ?? [],
                      ),
                    ],
                    config: BezierChartConfig(
                      startYAxisFromNonZeroValue: false,
                      bubbleIndicatorColor: Colors.white.withOpacity(0.9),
                      footerHeight: 0,
                      verticalIndicatorStrokeWidth: 0.2,
                      verticalIndicatorColor: Colors.black26,
                      showVerticalIndicator: true,
                      verticalIndicatorFixedPosition: false,
                      displayYAxis: false,
                      stepsYAxis: 10,
                      // backgroundColor: AppColors.mainBackgroundColor,
                      snap: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) : Container(
          child: Center(
            child: Text(
                'Empty chart data', style: normalTextStyle(16.SP, color: Colors.black)),
          ),
        );
      }
    );
  }

  //#region BUILD
  //-----------------
  @override
  Widget build(BuildContext context) {
    //Init screen dynamic size
    initDynamicSize(context);
    return Consumer<DetailInfoProvider>(
      builder: (BuildContext context, DetailInfoProvider provider, _) {
        return Material(
          child: Container(
            color: AppColors.mainBackgroundColor,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 30.H,),
                    Stack(
                      children: <Widget>[
                        Positioned(
                          left: 17.W,
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
                        Positioned(
                          right: 20.W,
                          child: InkWell(
                            child: Container(
                              width: 30.W,
                              height: 30.W,
                              child: Image.asset(AppImages.icUnPair),
                            ),
                            onTap: () {
                              context.read<Storage>().saveData(LocalStorageKey.bluetoothNameKey, null);
                              Navigator.of(context).popAndPushNamed(AppConstant.selectDevicePageRoute);
                            },
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Center(
                              child: Text('MINH LUU', style: boldTextStyle(15.SP, Colors.white),),
                            ),
                            SizedBox(height: 5.H,),
                            Center(
                              child: Text((provider.selectedWeight == null) ?
                              '${DateFormat.yMMMd().format(DateTime.now())} ${DateFormat.Hm().format(DateTime.now())}' :
                              '${DateFormat.yMMMd().format(provider.selectedWeight.time)} ${DateFormat.Hm().format(provider.selectedWeight.time)}'
                                , style: normalTextStyle(12.SP, color: Colors.white.withOpacity(0.5)),),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.H,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                              Text(provider.averageWeightOnTop.toStringAsFixed(2), style: boldTextStyle(48.SP, Colors.white),),
                            SizedBox(width: 5.W,),
                            Text('kg', style: normalTextStyle(14.SP, color: Colors.white.withOpacity(0.7)),),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('BMI 28.0 | Overweight', style: normalTextStyle(12.SP, color: Colors.white),)
                      ],
                    ),
                    SizedBox(height: 10.H,),
                    Container(
                      height: 250.H,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              child: _topChart(context)),
                          Positioned(
                            top: 10.H,
                              left: 0,
                              right: 20.W,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Center(
                                    child: InkWell(
                                      onTap: () {
                                        context.read<LogWeightProvider>().logWeightType = 0;
                                        Navigator.of(context).pushNamed(AppConstant.logWeightPageRoute);
                                      },
                                      child: Container(
                                        width: 100.W,
                                        height: 30.H,
                                        decoration: BoxDecoration(
                                          color: AppColors.blueTextColor,
                                          borderRadius: BorderRadius.all(Radius.circular(20.SP))
                                        ),
                                        child: Center(
                                          child: Text('LOG WEIGHT', style: boldTextStyle(10.SP, Colors.white),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.H,),
                  ],
                ),
                Positioned(
                  left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300.H,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.SP), topRight: Radius.circular(25.SP))
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 30.W, right: 30.W, top: 5.H, bottom: 30.H),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 30.H,
                              child: Row(
                                children: <Widget>[
                                  Flexible(child: InkWell(
                                    onTap: () {
                                      provider.selectedBottomChartMode = 0;
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Text('DAY', style: normalTextStyle(12.SP, color: (provider.selectedBottomChartMode == 0) ? AppColors.blueTextColor : Colors.black.withOpacity(0.5)),),
                                        ),
                                        if (provider.selectedBottomChartMode == 0) Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 2,
                                            color: AppColors.blueTextColor,
                                          ),
                                        ) else Container()
                                      ],
                                    ),
                                  )),
                                  Flexible(child: InkWell(
                                    onTap: () {
                                      provider.selectedBottomChartMode = 1;
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Text('WEEK', style: normalTextStyle(12.SP, color: (provider.selectedBottomChartMode == 1) ? AppColors.blueTextColor : Colors.black.withOpacity(0.5)),),
                                        ),
                                        if (provider.selectedBottomChartMode == 1) Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 2,
                                            color: AppColors.blueTextColor,
                                          ),
                                        ) else Container()
                                      ],
                                    ),
                                  )),
                                  Flexible(child: InkWell(
                                    onTap: () {
                                      provider.selectedBottomChartMode = 2;
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Text('MONTH', style: normalTextStyle(12.SP, color: (provider.selectedBottomChartMode == 2) ? AppColors.blueTextColor : Colors.black.withOpacity(0.5)),),
                                        ),
                                        if (provider.selectedBottomChartMode == 2) Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 2,
                                            color: AppColors.blueTextColor,
                                          ),
                                        ) else Container()
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.5,
                              color: Colors.black.withOpacity(0.1),
                            ),
                            SizedBox(height: 10.H,),
                            Center(
                              child: Text('TODAY - ${DateFormat.yMMMd().format(DateTime.now())}', style: boldTextStyle(12.SP, AppColors.blueTextColor),),
                            ),
                            SizedBox(height: 10.H,),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(provider.averageWeightOnBottom.toStringAsFixed(2), style: boldTextStyle(24.SP, AppColors.mainBackgroundColor),),
                                  SizedBox(width: 3.W,),
                                  Text('KG/ AVG', style: normalTextStyle(14.SP, color: AppColors.mainBackgroundColor),),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _bottomChart(context),
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      }
    );
  }
}

