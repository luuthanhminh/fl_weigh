
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/pages/log_weight/log_weight_provider.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/services/local/sqlite/store.dart';
import 'package:n7bluetooth/utils/app_asset.dart';
import 'package:n7bluetooth/utils/app_color.dart';
import 'package:n7bluetooth/utils/app_helper.dart';
import 'package:n7bluetooth/utils/app_log.dart';
import 'package:n7bluetooth/utils/app_style.dart';
import 'package:n7bluetooth/widgets/p_material.dart';
import 'package:n7bluetooth/utils/app_extension.dart';
import 'package:n7bluetooth/widgets/w_dismiss_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

class LogWeightPage extends StatefulWidget {
  @override
  _LogWeightPageState createState() => _LogWeightPageState();
}

class _LogWeightPageState extends State<LogWeightPage> with DynamicSize {

  /// Weight text edit controller
  final TextEditingController _weightTextController = TextEditingController(text: '');

  /// Calendar controller
  CalendarController _calendarController;

  /// Log weight provider
  LogWeightProvider _logWeightProvider;

  /// Log weight provider
  DetailInfoProvider _detailInfoProvider;

  /// Current selected date string
  String _selectDateString = 'Today';

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logWeightProvider = context.read<LogWeightProvider>();
      _detailInfoProvider = context.read<DetailInfoProvider>();

      if (_logWeightProvider.logWeightType == 1) {
        setState(() {
          _selectDateString = '${DateFormat.yMMMMd().format(_logWeightProvider.editWeight.time)}';
          _weightTextController.text = '${_logWeightProvider.editWeight.weight}';
        });
      }
    });

  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  //#region METHODS
  //------------------
  void _onDaySelected(DateTime day, List events, List holidays) {
    if (_logWeightProvider.logWeightType == 0) {
      _logWeightProvider.currentWeight.time = day;
    } else {
      _logWeightProvider.editWeight.time = day;
    }

    setState(() {
      if (day.isToday()) {
        _selectDateString = 'Today';
      } else {
        // ignore: unnecessary_string_interpolations
        _selectDateString = '${DateFormat.yMMMMd().format(day)}';
      }
    });
  }

  /// Handle when pressed save
  Future<void> _handleWhenPressSave() async {
    if (_logWeightProvider.currentWeight.weight == 0) {
      AppHelper.showToast('Please enter valid weight');
      return;
    }
    if (_logWeightProvider.logWeightType == 0) {
      final Uuid uuid = Uuid();
      _logWeightProvider.currentWeight.id = uuid.v1();
      await DefaultStore.instance.saveWeight(_logWeightProvider.currentWeight);
    } else {
      await DefaultStore.instance.saveWeight(_logWeightProvider.editWeight);
    }

    await _detailInfoProvider.updateWeightChartData();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  //#region BUILD
  //----------------
  @override
  Widget build(BuildContext context) {

    //Init dynamic size
    initDynamicSize(context);

    return Consumer<LogWeightProvider>(
      builder: (BuildContext context, LogWeightProvider provider, _) {
        return PMaterial(
            child: WDismissKeyboard(
              child: Container(
                color: AppColors.mainBackgroundColor,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 110.H,
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 20.W,),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: 30.W,
                                      height: 30.H,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle
                                      ),
                                      child: Image.asset(AppImages.icBack),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('LOG WEIGHT', style: normalTextStyle(16.SP, color: Colors.white),)
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.zero,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 40.H,),
                              Container(
                                margin: EdgeInsets.only(left: 30.W, right: 30.W),
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.W, right: 10.W),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text('DATE', style: boldTextStyle(13.SP, AppColors.blueTextColor),),
                                        ],
                                      ),
                                      SizedBox(height: 15.H,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(_selectDateString, style: normalTextStyle(13.SP, color: const Color(0xFF2D2828)),),
                                          InkWell(
                                            onTap: () {
                                              provider.isShowCalendar = !provider.isShowCalendar;
                                            },
                                            child: Container(
                                              width: 24.W,
                                              height: 24.H,
                                              child: Image.asset(AppImages.icCalendar),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10.H,),
                                      Container(
                                        height: 1,
                                        color: Colors.black.withOpacity(0.1),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (provider.isShowCalendar) Container(
                                height: 250.H,
                                child: Column(
                                  children: <Widget>[
                                    TableCalendar(
                                      initialSelectedDay: (provider.logWeightType == 1) ? provider.editWeight.time : DateTime.now(),
                                      rowHeight: 30.H,
                                      calendarController: _calendarController,
                                      events: null,
                                      holidays: null,
                                      startingDayOfWeek: StartingDayOfWeek.monday,
                                      calendarStyle: CalendarStyle(
                                        selectedColor: AppColors.mainBackgroundColor,
                                        todayColor: Colors.deepOrange[200],
                                        markersColor: Colors.transparent,
                                        outsideDaysVisible: false,
                                      ),
                                      headerStyle: HeaderStyle(
                                        formatButtonTextStyle:
                                        const TextStyle().copyWith(color: Colors.white, fontSize: 10.0),
                                        formatButtonDecoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                      ),
                                      onDaySelected: _onDaySelected,
                                      onVisibleDaysChanged: null,
                                      onCalendarCreated: null,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 30.H,),
                              Container(
                                margin: EdgeInsets.only(left: 30.W, right: 30.W),
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.W, right: 10.W),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text('WEIGHT', style: boldTextStyle(13.SP, AppColors.blueTextColor),),
                                        ],
                                      ),
                                      SizedBox(height: 15.H,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextField(
                                              onTap: () {
                                                provider.isShowCalendar = false;
                                              },
                                              textAlign: TextAlign.start,
                                              style: normalTextStyle(13.SP, color: const Color(0xFF2D2828)),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              controller: _weightTextController,
                                              keyboardType: TextInputType.number,
                                              onChanged: (String text) {
                                                //This part handle display wrong cursor position on Android
                                                _weightTextController.value =
                                                    _weightTextController.value.copyWith(
                                                        text: text,
                                                        selection: TextSelection(
                                                            baseOffset: _weightTextController
                                                                .selection.baseOffset <
                                                                text.length
                                                                ? _weightTextController
                                                                .selection.baseOffset
                                                                : text.length,
                                                            extentOffset: _weightTextController
                                                                .selection.extentOffset <
                                                                text.length
                                                                ? _weightTextController
                                                                .selection.extentOffset
                                                                : text.length));

                                                if (_logWeightProvider.logWeightType == 0) {
                                                  provider.currentWeight.weight = double.parse(text);
                                                } else {
                                                  provider.editWeight.weight = double.parse(text);
                                                }

                                              },
                                            ),
                                          ),
                                          Container(
                                            child: Text('KG', style: normalTextStyle(13.SP, color: const Color(0xFF2D2828)),),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 1,
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      SizedBox(height: 30.H,),
                                      InkWell(
                                        onTap: () async {
                                          await _handleWhenPressSave();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 20.W, right: 20.W),
                                          height: 50.H,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(25.SP)),
                                            color: AppColors.blueTextColor,
                                          ),
                                          child: Center(
                                            child: Text('SAVE', style: boldTextStyle(16.SP, Colors.white),),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    )
                  ],
                ),
              ),
            )
        );
      }
    );
  }
}
