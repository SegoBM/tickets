import 'package:flutter/material.dart';
import 'package:tickets/pages/Settings/Users/user_registration_screen.dart';
import 'package:tickets/config/behavior/myScrollBehavior.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/pages/Tickets/tickets_home.dart';
import 'package:tickets/pages/TicketsTest/tickets_home.dart';
import 'package:tickets/pages/login/app_login_view.dart';
import 'package:tickets/pages/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:tickets/services/push_notifications_service.dart';
import 'pages/Home/home_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!Platform.isWindows){
    await PushNotificationService.initializeApp();
  }
  runApp(const MyApp());
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
    /*
    PushNotificationService.messageStream.listen((message) {
      print("a\na\na\na\na\na\na\na\na\na\na");
      print('MyApp: $message');
      print("a\na\na\na\na\na\na\na\na\na\na");
    });*/
  }
  @override
  void dispose() {
    instance = null;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      // home: isLogged ? const SplashScreen2() : const SplashScreen(),//navegacion manual para la pantalla de inicio
      //theme: AppTheme().getTheme(),
      themeMode: _themeMode, //or ThemeMode.dark
      theme: _themeData,
      darkTheme: GlobalThemData.darkThemeData,
      scrollBehavior: MyCustomScrollBehavior(),
      initialRoute: 'splashScreen2',
      routes: {
        SplashScreen2.id: (_) => const SplashScreen2(),
        LoginPage.id: (_) => const LoginPage(),
        HomeScreen.id: (_) => const HomeScreen(),
        TicketHomeScreen.id: (_) => const TicketHomeScreen(),
        TicketHomeScreenTest.id: (_) => const TicketHomeScreenTest(),

        UserRegistrationScreen.id: (_) => UserRegistrationScreen(listSubmoduloPermisos: [],areas: [], listEmpresas: [],
        listAjustesUsuarios: [],),

        // ListaMaterialesScreen.id: (_) => const ListaMaterialesScreen(),
      },
    );
  }
  void updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    if (_themeMode == ThemeMode.light) {
      // Tema claro
      _themeData = GlobalThemData.lightThemeData;
    } else {
      // Tema oscuro
      _themeData = GlobalThemData.darkThemeData;
    }
  }
}