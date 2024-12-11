import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final TextStyle textStyle;
  final List<dynamic> dropdownItems;
  final String selectedItem;
  final TextEditingController? lugarController;
  final Icon suffixIcon;
  final Function(String?)? onPressed;
  final bool enabled;

  const MyDropdown({
    Key? key,
    required this.dropdownItems,
    this.lugarController,
    required this.suffixIcon,
    required this.textStyle,
    required this.selectedItem,
    required this.onPressed,
    this.enabled = true,

  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: DropdownButton<String>(
          icon: suffixIcon, value: selectedItem,
          onChanged: enabled ? onPressed : null,
          isExpanded: true, menuMaxHeight: 300,
          borderRadius: BorderRadius.circular(10),
          items: dropdownItems.map((dynamic item) {
            return DropdownMenuItem<String>(value: item,
              child: Text(item, style: textStyle,),
            );
          }).toList(),
          onTap: () {},
        ),
      ),
    );
  }
}