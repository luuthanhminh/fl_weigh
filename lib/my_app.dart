import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n7bluetooth/generated/l10n.dart';
import 'package:n7bluetooth/pages/detail_info/detail_info_provider.dart';
import 'package:n7bluetooth/pages/home/home_provider.dart';
import 'package:n7bluetooth/pages/log_weight/log_weight_provider.dart';
import 'package:n7bluetooth/pages/login/login_provider.dart';
import 'package:n7bluetooth/pages/scanning_devices/scanning_devices_provider.dart';
import 'package:n7bluetooth/services/app_dialog.dart';
import 'package:n7bluetooth/services/app_loading.dart';
import 'package:n7bluetooth/services/dynamic_size.dart';
import 'package:n7bluetooth/services/local/credential.dart';
import 'package:n7bluetooth/services/local/sqlite/store.dart';
import 'package:n7bluetooth/services/local/storage.dart';
import 'package:n7bluetooth/services/local/storage_preferences.dart';
import 'package:n7bluetooth/services/locale_provider.dart';
import 'package:n7bluetooth/services/remote/api_user.dart';
import 'package:n7bluetooth/utils/app_constant.dart';
import 'package:n7bluetooth/utils/app_route.dart';
import 'package:n7bluetooth/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> myMain() async {
  /// Start services later
  WidgetsFlutterBinding.ensureInitialized();
  await DefaultStore.instance.init();
  /// Force portrait mode
  await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]);

  /// Run Application
  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AppRoute>(create: (_) => AppRoute()),
        Provider<Storage>(create: (_) => StoragePreferences()),
        ChangeNotifierProvider<Credential>(
            create: (BuildContext context) =>
                Credential(context.read<Storage>())),
        ProxyProvider<Credential, ApiUser>(
            create: (_) => ApiUser(),
            update: (_, Credential credential, ApiUser userApi) {
              return userApi..token = credential.token;
            }),
        Provider<AppLoadingProvider>(create: (_) => AppLoadingProvider()),
        Provider<AppDialogProvider>(create: (_) => AppDialogProvider()),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<AppThemeProvider>(
            create: (_) => AppThemeProvider()),
        ChangeNotifierProvider<HomeProvider>(
            create: (BuildContext context) => HomeProvider(
                  context.read<ApiUser>(),
                  context.read<Credential>(),
                )),
        ChangeNotifierProvider<LoginProvider>(
            create: (BuildContext context) => LoginProvider(
                  context.read<ApiUser>(),
                  context.read<Credential>(),
                )),
        ChangeNotifierProvider<ScanningDevicesProvider>(
            create: (BuildContext context) => ScanningDevicesProvider(
              context.read<Storage>()
            )),
        ChangeNotifierProvider<DetailInfoProvider>(
            create: (BuildContext context) => DetailInfoProvider(
              context.read<Storage>()
            )),
        ChangeNotifierProvider<LogWeightProvider>(
            create: (BuildContext context) => LogWeightProvider(
            )
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with DynamicSize {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // Get providers
    final AppRoute appRoute = context.watch<AppRoute>();
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    final AppTheme appTheme = context.theme();
    // Build Material app
    return MaterialApp(
      navigatorKey: appRoute.navigatorKey,
      locale: localeProvider.locale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: appTheme.buildThemeData(),
      //https://stackoverflow.com/questions/57245175/flutter-dynamic-initial-route
      //https://github.com/flutter/flutter/issues/12454
      //home: (appRoute.generateRoute(
      ///            const RouteSettings(name: AppConstant.rootPageRoute))
      ///        as MaterialPageRoute<dynamic>)
      ///    .builder(context),
      initialRoute: AppConstant.selectDevicePageRoute,
      onGenerateRoute: appRoute.generateRoute,
      navigatorObservers: <NavigatorObserver>[appRoute.routeObserver],
    );
  }

  /// Custom page transitions theme
  PageTransitionsTheme buildPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
      },
    );
  }
}
