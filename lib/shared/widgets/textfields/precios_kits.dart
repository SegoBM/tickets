import 'package:flutter/material.dart';

class PreciosWidget extends StatelessWidget {
  final String text;
  final TextEditingController textController;
  final Color? backgroundColor;
 final double? fontSize;
 final double? height;
 final double? width;

  PreciosWidget({
    required this.text,
    required this.textController,
    this.backgroundColor,
    this.fontSize,
    required this.height,
    required this.width,
  });

  late Size size;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: fontSize ?? 14.0, color: theme.colorScheme.onPrimary
          ),
        ),
        SizedBox(width: 10), // Espacio entre el texto y el contenedor
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.background, // Color de fondo configurable
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '${textController.text}',
            style: TextStyle(fontSize: fontSize ?? 14.0, color: theme.colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
