import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final Color backgroundColor;
  final Color inputColor;
  final Color colorBorder;
  final String text;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function(String)? onChange;
  final bool obscureText;
  final Widget? suffixIcon;
  final InputDecoration? decoration;


  const MyTextField({
    Key? key,
    required this.backgroundColor,
    required this.inputColor,
    required this.colorBorder,
    required this.text,
    required this.controller,
    this.validator,
    this.onChange,
    this.decoration,
    this.obscureText = false,
    this.suffixIcon,

  }): super( key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Borde redondeado
      ),
      child: TextFormField(
        controller: controller,
        // Color del texto
        cursorColor: inputColor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            suffixIcon: suffixIcon,
            labelStyle: TextStyle(color: inputColor),
            labelText: text,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
        ),
        validator: validator,
        onChanged: onChange,
        obscureText: obscureText,
        style: TextStyle(color: inputColor),
      ),
    );
  }
}