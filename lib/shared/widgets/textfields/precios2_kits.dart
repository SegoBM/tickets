import 'dart:async';

import 'package:flutter/material.dart';

class Precios2Widget extends StatefulWidget {
  final String text;
  final TextEditingController textController;
  final Color? backgroundColor;
  final double? fontSize;
  final double? width;
  final double? height;

  Precios2Widget({
    required this.text,
    required this.textController,
    this.backgroundColor,
    this.fontSize,
    required this.height,
    required this.width,
  });

  @override
  _Precios2WidgetState createState() => _Precios2WidgetState();
}

class _Precios2WidgetState extends State<Precios2Widget> {
  bool isChecked = false;
  Timer? _timer;
  int number = 0;

  @override
  void initState() {
    super.initState();
    if (widget.textController.text.isEmpty) {
      widget.textController.text = '0';
    }
  }

  void _increment(){
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 0;
      currentValue +=1;
      widget.textController.text = currentValue.toString();
    });
  }

  void _decrement(){
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 0;
      if (currentValue > 0) {
        currentValue -= 1;
      }
      widget.textController.text = currentValue.toString();
    });
  }

  void _startTimer(){
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _increment();
    });
  }

  void _stopTimer(){
    _timer!.cancel();
  }

  void _startTimer2(){
    _timer = Timer.periodic(Duration (milliseconds: 100), (timer){
      _decrement();
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? true;
            });
          },
        ),
        Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize ?? 14.0,
            color: isChecked
                ? theme.colorScheme.onPrimary
                : theme.disabledColor,
          ),
        ),
        SizedBox(width: 10), // Espacio entre el texto y el contenedor
        Container(
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.only(left: 18.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child:   Text(
                  '${widget.textController.text} %',
                  style: TextStyle(
                    fontSize: widget.fontSize ?? 14.0,
                    color: isChecked
                        ? theme.colorScheme.onPrimary
                        : theme.disabledColor,
                  ),
                ),
              ),
                 Column(
                  children: [
                  GestureDetector(
                      onTap: _increment,
                      onLongPressStart: (_){
                        _startTimer();
                      },
                      onLongPressEnd: (_){
                        _stopTimer();
                    },
                    child: IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: isChecked ? _increment : null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _decrement,
                    onLongPressStart: (_){
                      _startTimer2();
                    },
                    onLongPressEnd: (_){
                      _stopTimer();
                    },
                    child: IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: isChecked ? _decrement : null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                  ),),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
