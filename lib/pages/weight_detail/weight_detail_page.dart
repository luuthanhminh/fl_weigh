import 'package:n7bluetooth/models/local/weight.dart';
import 'package:n7bluetooth/services/local/sqlite/store.dart';
import 'package:n7bluetooth/utils/app_log.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/utils/app_asset.dart';
import 'package:n7bluetooth/utils/app_color.dart';
import 'package:n7bluetooth/utils/app_extension.dart';
import 'package:n7bluetooth/utils/app_style.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WeightDetailPage extends StatefulWidget {

  @override
  _WeightDetailPageState createState() => _WeightDetailPageState();
}

class _WeightDetailPageState extends State<WeightDetailPage> with DynamicSize {

  //#region public properties
  //-----------------
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex;
  bool isPlaying = false;

  DetailInfoProvider _detailInfoProvider;

  //#region Life cycles
  //-----------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _detailInfoProvider = Provider.of<DetailInfoProvider>(context, listen: false);
      _listenWeightSignal();
    });
  }

  //#region METHOD
  //-----------------
  Future<void> _listenWeightSignal() async {
    final Stream<bool> stream = _detailInfoProvider.saveWeightDataStreamController.stream;
    stream.listen((bool data) async {
      logger.d(data);
      if (data == true) {
        logger.d('on true');
        //Save data and draw on chart
        if (_detailInfoProvider.weightValue == 0) {
          return;
        }
        final Weight _weight = Weight(weight: _detailInfoProvider.weightValue, time: DateTime.now());
        _detailInfoProvider.addDayChartDataOnTop(_weight);
        await DefaultStore.instance.saveWeight(_weight);
        _detailInfoProvider.isShowingWeightDetail = false;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }, onDone: () {

    }, onError: (dynamic error) {

    });

  }

  //#region BUILD
  //-----------------
  @override
  Widget build(BuildContext context) {
    //Init screen dynamic size
    initDynamicSize(context);

    return Material(
      child: Container(
        color: AppColors.mainBackgroundColor,
        child: Column(
          children: <Widget>[
            SizedBox(height: 40.H,),
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
                      context.read<DetailInfoProvider>().isShowingWeightDetail = false;
                    },
                  ),
                ),
                Center(
                  child: Text('Weight', style: normalTextStyle(30.SP, color: Colors.white),),
                ),
              ],
            ),
            SizedBox(height: 10.H,),
            Center(
              child: Text('', style: normalTextStyle(14.SP, color: const Color(0xFF6E737E)),),
            ),
            SizedBox(height: 40.H,),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 320.W,
                      height: 320.W,
                      child: SfRadialGauge(
                          enableLoadingAnimation: true,

                          axes: <RadialAxis>[
                            RadialAxis(minimum: 0, maximum: 150,
                                showLabels: true,
                                axisLabelStyle: GaugeTextStyle(color: Colors.white),
                                showTicks: false,
                                showFirstLabel: true,
                                showLastLabel: true,

                                ranges: <GaugeRange>[
                                  GaugeRange(

                                      sizeUnit: GaugeSizeUnit.logicalPixel,
                                      startValue: 0,
                                      endValue: 150,
                                      color: const Color(0xFF69C3E2),
                                      startWidth: 10,
                                      endWidth: 10),
                              GaugeRange(

                                  sizeUnit: GaugeSizeUnit.logicalPixel,
                                  startValue: 0,
                                  endValue: context.watch<DetailInfoProvider>().weightValue,
                                  color: Colors.white,
                                  startWidth: 10,
                                  endWidth: 10),

                            ], pointers: <GaugePointer>[

                            ], annotations: <GaugeAnnotation>[

                            ])
                          ]),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Selector<DetailInfoProvider, double>(
                            selector: (_, DetailInfoProvider provider) => provider.weightValue,
                            builder: (_, double weightValue ,__) {
                              return Text('$weightValue', style: normalTextStyle(70.SP, color: Colors.white),);
                            }
                        ),
                        SizedBox(height: 8.H,),
                        Text('kg', style: normalTextStyle(18.SP, color: Colors.white),)
                      ],

                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10.H,),
          ],
        ),
      ),
    );
  }




}
