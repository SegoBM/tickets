import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfieldNumber extends StatefulWidget {
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

  MyTextfieldNumber({
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
  });

  @override
  _MyTextfieldNumberState createState() => _MyTextfieldNumberState();
}

class _MyTextfieldNumberState extends State<MyTextfieldNumber> {
  @override
  void initState() {
    super.initState();
    if (widget.textController.text.isEmpty) {
      widget.textController.text = '0';
    }
  }

  void _increment() {
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 0;
      currentValue += 1;
      widget.textController.text = currentValue.toString();
    });
  }

  void _decrement() {
    setState(() {
      int currentValue = int.tryParse(widget.textController.text) ?? 0;
      if (currentValue > 0) {
        currentValue -= 1;
      }
      widget.textController.text = currentValue.toString();
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
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: widget.labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: widget.textColor ?? theme.colorScheme.onPrimary,
                  ),
              floatingLabelStyle: widget.floatingLabelStyle ??
                  TextStyle(
                    color: theme.colorScheme.secondary,
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
                  color: widget.colorLine ?? theme.colorScheme.onPrimary,
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
                IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  onPressed: _increment,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: _decrement,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



