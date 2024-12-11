import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/texts.dart';

class CustomAwesomeDialog extends StatelessWidget {
  final String title;
  final String desc;
  DialogType dialogType;
  AnimType animType;
  final VoidCallback btnOkOnPress;
  final VoidCallback btnCancelOnPress;
  Color? btnOkColor;
  Color? btnCancelColor;
  Color? backgroundColor;
  double? width;
  bool dismissOnTouchOutside;
  TextStyle? textStyle;
  String? btnOkText;
  String? btnCancelText;
  int duration;

  CustomAwesomeDialog({
    required this.title,
    required this.desc,
    this.dialogType = DialogType.info,
    this.width,
    this.dismissOnTouchOutside = false,
    this.animType = AnimType.scale,
    this.backgroundColor,
    this.btnOkText = Texts.accept,
    this.btnCancelText = Texts.cancel,
    required this.btnOkOnPress,
    required this.btnCancelOnPress,
    this.btnOkColor,
    this.btnCancelColor,
    this.textStyle,
    this.duration = 2500
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
  void showQuestion(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    AwesomeDialog(
      enableEnterKey: true,
      dismissOnBackKeyPress: false,
      transitionAnimationDuration:  const Duration(milliseconds: 200),
      dismissOnTouchOutside: dismissOnTouchOutside,
      dialogBackgroundColor: backgroundColor?? themeData.colorScheme.background,
      width: width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.question, animType: animType, title: title, desc: desc,
      btnCancelColor: btnCancelColor?? themeData.colorScheme.inversePrimary,
      btnOkColor: btnOkColor?? themeData.colorScheme.secondary,
      buttonsTextStyle: textStyle?? TextStyle(color: themeData.colorScheme.onPrimary),
      btnCancelText: btnCancelText, btnOkText: btnOkText, btnOkOnPress: btnOkOnPress,
      btnCancelOnPress: btnCancelOnPress,
    ).show();
  }
  void showSuccess(BuildContext context) {
    AwesomeDialog(
      enableEnterKey: true,
      autoHide: Duration(milliseconds: duration),
      transitionAnimationDuration:  const Duration(milliseconds: 200),
      dismissOnTouchOutside: dismissOnTouchOutside,
      dialogBackgroundColor: backgroundColor?? Theme.of(context).colorScheme.background,
      width:  width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.success, animType: animType, title: title, desc: desc,
      btnOkOnPress: btnOkOnPress, btnCancelOnPress: btnCancelOnPress,
      btnCancel: const SizedBox(),btnOk: const SizedBox(),
    ).show();
  }
  void showError(BuildContext context) {
    AwesomeDialog(
        enableEnterKey: true,
      transitionAnimationDuration:  const Duration(milliseconds: 200),
      dismissOnTouchOutside: dismissOnTouchOutside,
      dialogBackgroundColor: backgroundColor?? Theme.of(context).colorScheme.background,
      width:  width?? MediaQuery.of(context).size.width*0.38,
        context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.error, animType: animType, title: title, desc: desc,
      btnOkOnPress: btnOkOnPress, btnCancelOnPress: btnCancelOnPress,
      btnCancel: const SizedBox(),btnOkText: btnOkText, btnOkColor: ColorPalette.err
    ).show();
  }
  void showWarning(BuildContext context){
    ThemeData themeData = Theme.of(context);
    AwesomeDialog(
      enableEnterKey: true,
      dismissOnBackKeyPress: false,
      transitionAnimationDuration:  const Duration(milliseconds: 200),
      dismissOnTouchOutside: dismissOnTouchOutside,
      dialogBackgroundColor: backgroundColor?? themeData.colorScheme.background,
      width: width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.warning, animType: animType, title: title, desc: desc,
      btnCancelColor: btnCancelColor?? themeData.colorScheme.inversePrimary,
      btnOkColor: btnOkColor?? themeData.colorScheme.secondary,
      buttonsTextStyle: textStyle?? TextStyle(color: themeData.colorScheme.onPrimary),
      btnCancelText: btnCancelText, btnOkText: btnOkText, btnOkOnPress: btnOkOnPress,
      btnCancelOnPress: btnCancelOnPress,
    ).show();

  }
}