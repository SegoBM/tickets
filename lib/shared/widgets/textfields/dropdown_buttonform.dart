import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String labelText;
  final TextStyle? labelStyle;
  final TextStyle? dropdownTextStyle;
  final TextEditingController textController;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final double? width;
  final double? height;
  final bool showIcon;
  final TextStyle? textStyle;

  CustomDropdown({
    required this.labelText,
    required this.items,
    required this.textController,
    this.validator,
    this.onChanged,
    this.dropdownTextStyle,
    this.textStyle,
    this.labelStyle,
    this.width,
    this.height,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 60, maxWidth: width ?? 150,
        minHeight: 40,
    ),
      child: DropdownButtonFormField<String>(
        autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: labelText,
        labelStyle: labelStyle ?? TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary),
        border: const OutlineInputBorder(), filled: true,
        fillColor: theme.colorScheme.background,
      ),
      value: textController.text.isEmpty ? null : textController.text,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
            style: dropdownTextStyle ?? TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (onChanged != null) {
          onChanged!(newValue);
        }
        textController.text = newValue ?? '';
      },
      validator: validator,
      style: dropdownTextStyle ?? TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary),
       icon: showIcon ? null: SizedBox.shrink(),
      ),
    );
  }
}
