import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';

class GlobalThemData {
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);
  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.onPrimary,
        selectionColor: colorScheme.primary,
        selectionHandleColor: colorScheme.primary,
      ),
        fontFamily:GoogleFonts.openSans().fontFamily,
        colorScheme: colorScheme,
        canvasColor: colorScheme.background,
        scaffoldBackgroundColor: colorScheme.background,
        highlightColor: Colors.transparent,
        useMaterial3: true, focusColor: focusColor,
        unselectedWidgetColor: colorScheme.surfaceVariant,
        indicatorColor:const Color.fromRGBO(35, 100, 170, 1.0),
        shadowColor: const Color.fromRGBO(93, 93, 93, 0.5),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue)
        )),
       textTheme:  GoogleFonts.openSansTextTheme().copyWith(
         headline6: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
         subtitle1: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
         bodyText2: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
         button: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
       ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color.fromRGBO(218, 215, 205, 1.0),//#DAD7CD
    surface: Color.fromRGBO(218, 215, 205, 1.0),
    onPrimary: Color.fromRGBO(65, 65, 65, 1.0),
    onSurface: Color.fromRGBO(26, 26, 26, 1.0),
    secondary: Color.fromRGBO(207, 185, 165, 1.0),//#CFB9A5
    tertiary: Color.fromRGBO(146, 149, 120, 1.0),//#929578
    primaryContainer: Color.fromRGBO(166, 158, 177, 1.0),//#A69EB1
    secondaryContainer: Color.fromRGBO(126, 140, 153, 1.0),//#7E8C99
    onSecondary: Color.fromRGBO(10, 10, 10, 1.0),
    //Colores de los contenedores de las opciones
    onPrimaryContainer: Color.fromRGBO(164, 161, 154, 0.25),
    onSecondaryContainer: Color.fromRGBO(109, 108, 103, 0.3),
    error: Colors.redAccent,
    onError: Color.fromRGBO(10, 10, 10, 1.0),
    background: Color.fromRGBO(246, 245, 243, 1.0),
    onBackground: Color.fromRGBO(26, 26, 26, 1.0),
    //Color de letra de opcion seleccionada
    surfaceVariant: Color.fromRGBO(109, 108, 103, 1.0),
    inverseSurface: Color.fromRGBO(251, 251, 251, 1.0),
    //Color de boton cancelar o disabled
    inversePrimary: Color.fromRGBO(192, 192, 192, 1.0),
    shadow: Color.fromRGBO(64, 64, 64, 1.0),
    brightness: Brightness.light,
  );
  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF22333B),
    surface: Color(0xFF22333B),
    onPrimary: Colors.white,
    onSurface: Colors.white,
    tertiary: Color.fromRGBO(166, 156, 172, 1.0),//#A69CAC
    secondary: Color.fromRGBO(142, 154, 175, 1.0),//#8E9AAF
    primaryContainer: Color(0xFF84A59D),//#84A59D
    secondaryContainer: Color.fromRGBO(175, 156, 142, 1.0),
    //Colores de los contenedores de las opciones
    onPrimaryContainer: Color.fromRGBO(133, 146, 158, 0.25),
    onSecondaryContainer: Color.fromRGBO(93, 109, 126, 0.3),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFF3E4D54),
    onBackground: Color(0x0DFFFFFF),

    //Color de letra de opcion seleccionada
    surfaceVariant: Color.fromRGBO(111, 137, 154, 1.0),
    inverseSurface:  Color.fromRGBO(21, 32, 37, 1.0),
    //Color de boton cancelar o disabled
    inversePrimary: Color.fromRGBO(60, 63, 65, 1.0),
    shadow: Color.fromRGBO(19, 19, 19, 1.0),
    brightness: Brightness.dark,
  );
}