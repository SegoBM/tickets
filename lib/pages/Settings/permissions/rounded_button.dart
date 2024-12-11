import 'package:flutter/material.dart';

class MyRoundedIconButton extends StatelessWidget {
  final Function onPressed;
  final Color color;
  final Icon icon;

  const MyRoundedIconButton({
    Key? key,
    required this.onPressed,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){},
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(15),
      ),
      child: icon,
    );
  }
}