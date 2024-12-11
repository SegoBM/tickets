import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:tickets/pages/Home/home_screen.dart';
import 'package:tickets/pages/login/app_login_view.dart';

class SplashScreen2 extends StatefulWidget {
  static String id = 'splashScreen2';
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState()=> _SplashScreen();
}
class _SplashScreen extends State<SplashScreen2> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context){
    return FlutterSplashScreen.gif(
      useImmersiveMode: true,
      gifPath: "assets/splash2.gif",
      gifHeight: 500,
      gifWidth: 500,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.fromRGBO(17, 17, 17, 1.0), Color.fromRGBO(17, 17, 17, 1.0)],
      ),
      nextScreen: const LoginPage(),
    );
  }
}