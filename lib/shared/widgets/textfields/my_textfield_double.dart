import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfieldNumberD extends StatefulWidget {
  final String labelText;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextEditingController textController;
  final Color? colorLine;
  final Color? colorLineBase;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? cursorColor;
  final TextStyle? floatingLabelStyle;
  final double radius;
  String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  MyTextfieldNumberD({
    super.key,
    required this.labelText,
    this.labelStyle,
    this.cursorColor,
    required this.textController,
    this.textColor,
    this.colorLine,
    this.backgroundColor,
    this.textStyle,
    this.colorLineBase,
    this.floatingLabelStyle,
    this.radius = 10,
    this.validator,
    this.onChanged,
  });
  @override
  _MyTextfieldNumberDState createState() => _MyTextfieldNumberDState();
}

class _MyTextfieldNumberDState extends State<MyTextfieldNumberD> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.textController.text.isEmpty) {
      widget.textController.text = '0.0';
    }
  }
@override
void dispose(){
    super.dispose();
}

  void _increment() {
    setState(() {
      double currentValue = double.tryParse(widget.textController.text) ?? 0.0;
      currentValue += 0.1;
      widget.textController.text = currentValue.toStringAsFixed(1);
    });
  }

  void _startTimer(){
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
     _increment();
     //_decrement();
    });
  }
 void _startTimer2(){
    _timer = Timer.periodic(const Duration (milliseconds: 100), (timer) {
      _decrement();
    });
 }
  void _stopTimer(){
    _timer!.cancel();
  }

  void _decrement() {
    setState(() {
      double currentValue = double.tryParse(widget.textController.text) ?? 0.0;
      if (currentValue > 0.0) {
        currentValue -= 0.1;
      }
      widget.textController.text = currentValue.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.primaryColor,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
            controller: widget.textController,
            cursorColor: widget.cursorColor,
            onChanged: (newValue) {
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
              widget.textController.text = newValue ?? '';
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: widget.labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: widget.textColor ?? theme.colorScheme.onPrimary,
                  ),
              floatingLabelStyle: widget.floatingLabelStyle ??
                  TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                  color: widget.colorLine ?? theme.colorScheme.secondary,
                  width: 2.1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                  color: widget.colorLineBase ??
                      theme.colorScheme.onSecondaryContainer,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                  color: widget.colorLine ?? theme.colorScheme.secondary,
                  width: 2.1,
                ),
              ),
            ),
            style: widget.textStyle ??
                TextStyle(
                  fontSize: 14,
                  color: widget.textColor ?? theme.colorScheme.onPrimary,
                ),
          ),
          Positioned(
            right: 0,
            child: Column(
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
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: _increment,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                GestureDetector(
                  onTap: _decrement,
                  onLongPressStart:(_){
                    _startTimer2();
                  },
                  onLongPressEnd:(_){
                    _stopTimer();
                  },
                  child:IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _decrement,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regExp = RegExp(r'^\d*\.?\d*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
