import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/texts.dart';

class CustomAwesomeDialogTickets extends StatelessWidget {
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

  CustomAwesomeDialogTickets({
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
    AwesomeDialog(
      enableEnterKey: true,
      dismissOnBackKeyPress: false,
      transitionAnimationDuration:  const Duration(milliseconds: 200),
      dismissOnTouchOutside: dismissOnTouchOutside,
      dialogBackgroundColor: ColorPalette.ticketsColor3,
      width: width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.question, animType: animType, title: title, desc: desc,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      descTextStyle: TextStyle(color: Colors.white),
      btnCancelColor: ColorPalette.ticketsColor2,
      btnOkColor: ColorPalette.ticketsColor6,
      buttonsTextStyle: textStyle?? TextStyle(color: Colors.white),
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
      dialogBackgroundColor: ColorPalette.ticketsColor3,
      width:  width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.success, animType: animType, title: title, desc: desc,
      titleTextStyle: TextStyle(color: Colors.white , fontSize: 18),
      btnOkOnPress: btnOkOnPress, btnCancelOnPress: btnCancelOnPress,
      buttonsTextStyle: textStyle?? TextStyle(color: Colors.white),
      btnCancel: const SizedBox(),btnOk: const SizedBox(),
    ).show();
  }
  void showError(BuildContext context) {
    AwesomeDialog(
        enableEnterKey: true,
        transitionAnimationDuration:  const Duration(milliseconds: 200),
        dismissOnTouchOutside: dismissOnTouchOutside,
        dialogBackgroundColor: ColorPalette.ticketsColor3,
        width:  width?? MediaQuery.of(context).size.width*0.38,
        context: Navigator.of(context, rootNavigator: true).context,
        dialogType: DialogType.error, animType: animType, title: title, desc: desc,
        btnOkOnPress: btnOkOnPress, btnCancelOnPress: btnCancelOnPress,
        buttonsTextStyle: textStyle?? TextStyle(color: Colors.white),
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
      dialogBackgroundColor: ColorPalette.ticketsColor3,
      width: width?? MediaQuery.of(context).size.width*0.38,
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.warning, animType: animType, title: title, desc: desc,
      btnCancelColor: ColorPalette.ticketsColor2,
      btnOkColor: ColorPalette.ticketsColor6,
      buttonsTextStyle: textStyle?? TextStyle(color: Colors.white),
      btnCancelText: btnCancelText, btnOkText: btnOkText, btnOkOnPress: btnOkOnPress,
      btnCancelOnPress: btnCancelOnPress,
    ).show();

  }
}