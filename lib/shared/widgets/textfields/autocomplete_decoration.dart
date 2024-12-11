import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAutocomplete extends StatelessWidget {
  final String? labelText;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final List<String> dropdownItems;
  final TextEditingController? textController;
  final Color? colorLine;
  final Icon suffixIcon;
  final Function(String?) onValueChanged;
  final bool? toUppercase;
  final String? text;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String?) onValueChange;
  final String? placeholderText;

  const MyAutocomplete({
    super.key,
    this.labelText,
    this.labelStyle,
    required this.dropdownItems,
    this.textController,
    this.colorLine,
    required this.suffixIcon,
    this.textStyle,
    required this.onValueChanged,
    required this.onValueChange,
    this.toUppercase,
    this.text,
    this.keyboardType,
    this.inputFormatters,
    this.placeholderText,
  });

  String getTextFieldText() {
    return textController!.text;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Autocomplete<String>(
      optionsMaxHeight: 200,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return dropdownItems.where((String option) {
          return option.contains(textEditingValue.text);
        });
      },
      onSelected: (String selection) {
        textController?.text = selection;
        onValueChanged(selection);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textController,
          FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        if (textController.text.isEmpty) {
          textController.text = placeholderText ?? "";
        }

        return TextField(
          inputFormatters: inputFormatters ??
              (toUppercase != null
                  ? [toUppercase! ? UpperCaseTextFormatter() : TitleCaseTextFormatter()]
                  : <TextInputFormatter>[]),
          onTap: () {
            if (textController.text == placeholderText) {
              textController.clear();
            }
          },
          onChanged: (String text) {
            if (text.isEmpty) {
            textController.text = placeholderText!;
            print(textController);
            }
             onValueChange(text);
          },
          controller: textController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle ?? TextStyle(
              color: theme.colorScheme.onPrimary,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colorLine ?? theme.colorScheme.onPrimary,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
          style: textStyle ?? TextStyle(),
          keyboardType: keyboardType,
        );
      },
      optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options
          ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 200,
              height: 300,
              color: theme.colorScheme.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option, style: TextStyle(color: colorLine)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
class TitleCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Convierte el texto a título, lo que significa que la primera letra de cada palabra está en mayúscula.
    return TextEditingValue(
      text: toTitleCase(newValue.text),
      selection: newValue.selection,
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
