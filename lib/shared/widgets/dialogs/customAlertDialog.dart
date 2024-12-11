import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/texts.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  List<Widget>? actions;
  Function()? onPressedOk;
  Function()? onPressedCancel;

  CustomAlertDialog({required this.title, required this.content,this.actions,
  this.onPressedOk, this.onPressedCancel});// modificado para que no requiera el titulo y poder

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AlertDialog(
      //insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      scrollable: true,
      content: content,
      title: Text(title, style: TextStyle(color: themeData.colorScheme.onPrimary)),
      actions: actions?? [
        ElevatedButton(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(themeData.colorScheme.inversePrimary),
          ),
          onPressed: onPressedCancel?? () {
            Navigator.of(context).pop();
          },child: Text(Texts.cancel, style: TextStyle(color: themeData.colorScheme.onPrimary)),),
        ElevatedButton(onPressed: onPressedOk?? () {
            Navigator.of(context).pop();
          }, child: Text(Texts.accept, style: TextStyle(color: themeData.colorScheme.onPrimary))
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
      ),
    );
  }
}

