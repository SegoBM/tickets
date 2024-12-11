import 'package:flutter/material.dart';

import 'dialogClaveSat.dart';

class MyTextFieldClaveSat extends StatelessWidget {
  final Color inputColor;
  final Color colorBorder;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function(String)? onChange;
  ThemeData theme;

  MyTextFieldClaveSat({
    Key? key,
    required this.theme,
    required this.inputColor,
    required this.colorBorder,
    required this.controller,
    this.validator,
    this.onChange,
  }): super( key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260, height: 50,
      child: Row(children: [
        SizedBox(width: 200, height: 50, child:
        TextFormField(
          controller: controller,
          cursorColor: inputColor, enabled: false,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.money), labelStyle: TextStyle(color: inputColor),
            labelText: 'Clave SAT',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorBorder)),
          ),
          validator: validator, onChanged: onChange,
          style: TextStyle(color: inputColor),
        ),),
        const SizedBox(width: 10,),
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary, // Background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: IconButton(
            icon: const Icon(Icons.manage_search_rounded, color: Colors.white),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogClaveSat();
                },
              );
              if (result != null) {
                controller.text = result;
                print("Result: $result");
              }
            },
          ),
        ),
      ],)
    );
  }
}