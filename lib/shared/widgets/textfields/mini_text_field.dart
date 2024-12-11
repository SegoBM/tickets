import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MiniTextFiled extends StatelessWidget {

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;
  final double scale;
  final List<TextInputFormatter>? inputFormatters;

  const MiniTextFiled({
    required this.controller,
    required this.onChanged,
    this.width = 80,
    this.height = 50,
    this.scale = 0.8,
    Key? key,
    this.inputFormatters,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: Transform.scale(
        scale: scale,
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onPrimary.withOpacity(0.7),
          ),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
            ),
          ),
          inputFormatters: inputFormatters ?? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          onChanged: onChanged,
        ),
      ),
    );
   }
  }
