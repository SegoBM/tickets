import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tickets/config/behavior/myScrollBehavior.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/pages/Tickets/tickets_home.dart';
import 'package:tickets/pages/login/app_login_view.dart';
import 'package:tickets/pages/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'bloc/AppProviders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  static void updateTheme(ThemeMode themeMode) {
    _MyAppState? state = _MyAppState.instance;
    if (state != null) {
      state.updateTheme(themeMode);
    }
  }
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static _MyAppState? instance;
  bool isLogged = false;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeData _themeData = GlobalThemData.lightThemeData;

  @override
  void initState() {
    super.initState();
    if(Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      WindowManager.instance.setMinimumSize(const Size(900, 650));
    }
    instance = this;
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLogged = true;
      });
    });
  }

  @override
  void dispose() {
    instance = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: AppProviders.getProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: _themeData,
        darkTheme: GlobalThemData.darkThemeData,
        scrollBehavior: MyCustomScrollBehavior(),
        initialRoute: 'splashScreen2',
        routes: {
          SplashScreen2.id: (_) => const SplashScreen2(),
          LoginPage.id: (_) => const LoginPage(),
          TicketHomeScreen.id: (_) => const TicketHomeScreen(),
        },
      ),
    );
  }

  void updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    if (_themeMode == ThemeMode.light) {
      _themeData = GlobalThemData.lightThemeData;
    } else {
      _themeData = GlobalThemData.darkThemeData;
    }
  }
}