import 'dart:async';

import 'package:flutter/material.dart';

class CantidadWidget extends StatefulWidget {
  final String text;
  final String text2;
  final TextEditingController textController;
  final Color? backgroundColor;
  final double? fontSize;
  final double? width;
  final double? height;

  CantidadWidget({
    required this.text,
    this.text2 = " ",
    required this.textController,
    this.backgroundColor,
    this.fontSize,
    required this.width,
    required this.height,
  });

  @override
  _CantidadWidgetState createState() => _CantidadWidgetState();
}

class _CantidadWidgetState extends State<CantidadWidget> {
  bool isChecked = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.textController.text.isEmpty) {
      widget.textController.text = '1';
    }
  }

  void _increment(){
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 1;
      currentValue +=1;
      widget.textController.text = currentValue.toString();
    });
  }

  void _decrement(){
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 1;
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
        Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize ?? 12.0,
              fontWeight: FontWeight.normal,
            color: theme.colorScheme.onPrimary
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.only(left: 8.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child:   Text(
                  '${widget.textController.text}',
                  style: TextStyle(
                    fontSize: widget.fontSize ?? 12.0,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onPrimary
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
        Text(
            widget.text2,
            style: TextStyle(
              fontSize: widget.fontSize ?? 12.0,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onPrimary
          ),
        ),
      ],
    );
  }
}
