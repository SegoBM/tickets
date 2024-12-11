import 'package:flutter/material.dart';
final GlobalKey<State> _dialogKey = GlobalKey<State>();
Future<T?> myShowDialog<T extends Object?> (Widget widget, BuildContext context,[double? width, GlobalKey<State>? key,Color? background]){
  return showDialog(context: context, barrierDismissible: false,
      builder:(BuildContext context){
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState1)
            {
              return ScaffoldMessenger(child: Builder(
                  builder: (context) => AlertDialog(
                    backgroundColor: background,
                    key: key?? _dialogKey,
                    surfaceTintColor: background?? Theme.of(context).colorScheme.background,
                    content: SizedBox(
                      width: width?? MediaQuery.of(context).size.width * 0.8, // Ajusta el ancho según sea necesario
                      child: widget,
                    ),
                  )
              ));
            }
        );
      });
}
Future<T?> myShowDialogScale<T extends Object?> (Widget widget, BuildContext context,{double? width, double? height, double scale= .82,
  GlobalKey<State>? key,Color? background, ShapeBorder? shape}){
  return showDialog(context: context, barrierDismissible: false,
      builder:(BuildContext context){
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState1)
            {
              return ScaffoldMessenger(  child: Builder(
                  builder: (context) => Transform.scale(scale: scale ,child: AlertDialog(
                    shape: shape,
                    backgroundColor: background,
                    key: key?? _dialogKey,
                    surfaceTintColor: background?? Theme.of(context).colorScheme.background,
                    content: SizedBox(
                      width: width?? MediaQuery.of(context).size.width * 0.8,// Ajusta el ancho según sea necesario
                      height: height?? MediaQuery.of(context).size.height,// Ajusta el alto según sea necesario
                      child: widget,
                    ),
                  ),)
              ));
            }
        );
      });
}
void hideMyDialog() {
  if (_dialogKey.currentContext != null) {
    Navigator.of(_dialogKey.currentContext!, rootNavigator: true).pop();
  }
}