import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final Color? colorText;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final double radius;
  CustomButton({ required this.text, required this.onPressed, this.icon,
    this.color, this.width, this.height, this.textStyle, this.colorText, this.radius = 10.0});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Cambia esto al radio que desees
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(color ?? Theme.of(context).colorScheme.primary),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: width ?? 145,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon != null? Icon(icon, color:colorText ?? Theme.of(context).colorScheme.onPrimary,) : const SizedBox(),
            SizedBox(width:width!=null? width!-25:120 ,child: Text(text,textAlign: TextAlign.center,
              style: textStyle?? TextStyle(color:colorText ?? Theme.of(context).colorScheme.onPrimary,),
            ),),
            const SizedBox()
          ],
        ),
      ),
    );
  }
}