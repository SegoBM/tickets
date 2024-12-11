import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class MyCherryToast {
  static void showWarningSnackBar(BuildContext context, ThemeData theme, String message, [String subTitle = '']) {
    CherryToast.warning(width: 400,
      toastPosition: Position.center,
      backgroundColor: theme.colorScheme == GlobalThemData.lightColorScheme
          ? const Color.fromRGBO(255, 255, 255, 1)
          : const Color.fromRGBO(27, 36, 41, 1),
      title:  Text(message, style: const TextStyle(fontSize: 16)),
      action:  Text(subTitle, style: const TextStyle(fontSize: 14)),
    ).show(context);
  }
}