import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';

class CustomSnackBar {
  static void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(children: <Widget>[
        const Icon(IconLibrary.iconCheck, color: Colors.white),
        const SizedBox(width: 10,),
        Flexible(child: Text(message, style: const TextStyle(color: Colors.white),))
      ],),
      backgroundColor: ColorPalette.ok,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(children: <Widget>[
      const Icon(IconLibrary.iconError, color: Colors.white),
        const SizedBox(width: 10,),
        Flexible(child: Text(message, style: const TextStyle(color: Colors.white)))]),
      backgroundColor: ColorPalette.err,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content:  Row(children: <Widget>[
        const Icon(IconLibrary.iconWarning, color: Colors.white),
        const SizedBox(width: 10,),
        Flexible(child: Text(message, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: ColorPalette.accentColor,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 4),
      content: Row(children: <Widget>[
        const Icon(IconLibrary.iconInfo, color: Colors.white),
        const SizedBox(width: 10),
        Flexible(child: Text(message, style: const TextStyle(color: Colors.white)))
      ]),
      backgroundColor: ColorPalette.informationColor,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
