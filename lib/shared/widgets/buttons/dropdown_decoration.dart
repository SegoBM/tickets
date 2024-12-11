import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final TextStyle? textStyle;
  final List<dynamic> dropdownItems;
  final String selectedItem;
  final Icon? suffixIcon;
  final Function(String?)? onPressed;
  final bool enabled;
  final Color? dropdownColor;
  final double? borderRadius;
  final Color? selectedItemColor;
  final BoxDecoration? boxDecoration;


  const MyDropdown({
    Key? key,
    required this.dropdownItems,
    this.suffixIcon,
    this.textStyle,
    required this.selectedItem,
    required this.onPressed,
    this.enabled = true,
    this.dropdownColor,
    this.borderRadius,
    this.selectedItemColor,
    this.boxDecoration,

  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          decoration: boxDecoration,
          child: DropdownButton<String>(
            dropdownColor: dropdownColor,
            icon: suffixIcon != null? Padding(
              padding: const EdgeInsets.only(right: 10),
              child: suffixIcon,
            ) : null,
            value: selectedItem,
            onChanged: enabled ? onPressed : null,
            isExpanded: true,
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            style: TextStyle(color: selectedItemColor ?? Colors.black, fontSize: 14.5),
            items: dropdownItems.map((dynamic item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(item, style: textStyle,),
                )
              );
            }).toList(),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

