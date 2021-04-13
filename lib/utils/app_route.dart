import 'package:flutter/material.dart';
import 'package:n7bluetooth/pages/counter/counter_page.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_page.dart';
import 'package:n7bluetooth/pages/home/home_page.dart';
import 'package:n7bluetooth/pages/log_weight/log_weight_page.dart';
import 'package:n7bluetooth/pages/scanning_devices/scanning_devices_page.dart';
import 'package:n7bluetooth/pages/select_devices/select_devices_page.dart';
import 'package:n7bluetooth/pages/weight_detail/weight_detail_page.dart';
import 'package:n7bluetooth/utils/app_constant.dart';
import 'package:provider/provider.dart';

class AppRoute {
  /// App global navigator key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // App route observer
  final RouteObserver<Route<dynamic>> routeObserver =
      RouteObserver<Route<dynamic>>();

  // Get app context
  BuildContext get appContext => navigatorKey.currentContext;

  /// Generate route for app here
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstant.counterPageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (_) =>
                CounterPage(argument: settings.arguments as String));

      case AppConstant.homePageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => const HomePage());

      case AppConstant.selectDevicePageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => SelectDevicesPage());
      case AppConstant.detailInfoPageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => DetailInfoPage());
      case AppConstant.scanningDevicesPageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => ScanningDevicesPage());
        case AppConstant.weightDetailPageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => WeightDetailPage());
        case AppConstant.logWeightPageRoute:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => LogWeightPage());
      case AppConstant.loginPageRoute:
      case AppConstant.rootPageRoute:
      default:
        return null;
    }
  }
}

extension AppRouteExt on BuildContext {
  AppRoute route() {
    return Provider.of<AppRoute>(this, listen: false);
  }

  NavigatorState navigator() {
    return route().navigatorKey.currentState;
  }
}
