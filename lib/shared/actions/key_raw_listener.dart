import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef KeyAction = void Function();


class PressedKeyListener extends StatefulWidget {
  final GlobalKey Gkey;
  final Widget child;
  final Map<LogicalKeyboardKey, KeyAction> keyActions;
  FocusNode? focusNode;

  PressedKeyListener({
    super.key,
    required this.child,
    required this.keyActions,
    this.focusNode,
    required this.Gkey,
  });
  @override
  State<PressedKeyListener> createState() => _PressedKeyListenerState();
}
class _PressedKeyListenerState extends State<PressedKeyListener> {
  int refreshKey = 0; // this is th counter for the refresh key
  final FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    //FocusScope.of(context).requestFocus(_focusNode);
  return RawKeyboardListener(
      focusNode: widget.focusNode?? _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event){
        widget.keyActions.forEach(( key, action ){
          if( event.isKeyPressed(key) ){
            action();
          }
        });
        // if(event.isKeyPressed(LogicalKeyboardKey.escape)){
        //   // Navigator.of(context).pop(); // default action of sacpe key
        //   print('you have been pressed the scape key');}
        // if(event.isKeyPressed(LogicalKeyboardKey.f5)){
        // setState((){
        //   refreshKey++;
        // });
        // print('you have been pressed the f5 key');
        // }
        // if(event.isKeyPressed(LogicalKeyboardKey.f2)){
        //   print('you have been pressed the f2 key');
        // }
      },
      child:
      KeyedSubtree(
        key: Key('refeshkey_$refreshKey'),
        child: widget.child,
      )
  );
  }
}
