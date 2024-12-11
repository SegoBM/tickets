import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/utils/color_palette.dart';

class MyTextfieldIcon extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final TextEditingController textController;
  final Color? colorLine;
  final Color? colorLineBase;
  final Color? backgroundColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? enabled;
  final Function()? onTap;
  final bool? toUpperCase;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool? formatting;
  final TextStyle? floatingLabelStyle;
  final double radius;
  final Color? textColor;
  final Color? cursorColor;
  String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  final FocusNode? focusNode;
  final bool autoSelectText;
  List<TextInputFormatter>? inputFormatters;

  final Function(dynamic value)? onSaved;


  MyTextfieldIcon({
    super.key,
    required this.labelText,
    this.labelStyle,
    this.cursorColor,
    required this.textController,
    this.textColor,
    this.colorLine,
    this.backgroundColor,
    this.suffixIcon,
    this.textStyle,
    this.enabled,
    this.onTap,
    this.toUpperCase,
    this.keyboardType,
    this.onChanged,
    this.colorLineBase,
    this.formatting,
    this.prefixIcon,
    this.floatingLabelStyle,
    this.radius = 10,
    this.validator,
    this.minLines =1,
    this.maxLines =1,
    this.maxLength,
    this.errorStyle,
    this.onSaved,
    this.hintText,
    this.autoSelectText = false,
    this.inputFormatters,
    FocusNode? focusNode,
  }) : focusNode = focusNode ?? FocusNode() {
    if (autoSelectText) {
      this.focusNode?.addListener(() {
        if (this.focusNode!.hasFocus) {
          textController.selection = TextSelection(
            baseOffset: 0,affinity: TextAffinity.downstream,isDirectional: false,
            extentOffset: textController.text.length,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
      color: backgroundColor ?? theme.primaryColor, // Color de fondo
      borderRadius: BorderRadius.circular(radius),
    ),
      child: TextFormField(
      minLines: minLines, maxLines: maxLines,  maxLength: maxLength,
        autovalidateMode: AutovalidateMode.onUserInteraction, validator: validator,
      controller: textController,
      focusNode: focusNode,
      cursorColor:  cursorColor,
      inputFormatters:
      inputFormatters?? (toUpperCase != null ? (toUpperCase! ? [UpperCaseTextFormatter()] : (formatting == null ? [TitleCaseTextFormatter()]  :
      (formatting!? [TitleCaseTextFormatter()] : null)))
          :  (formatting == null ? [TitleCaseTextFormatter()]  :
      (formatting!? [TitleCaseTextFormatter()] : null))),
      decoration: InputDecoration(
        counterText: "",hintText: hintText,
        labelText: labelText,
        labelStyle: labelStyle?? TextStyle(fontSize: 14, color: textColor != null ? textColor : theme.colorScheme.onPrimary),
        floatingLabelStyle: floatingLabelStyle?? TextStyle(color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold),
        errorStyle: errorStyle,
        prefixIcon: prefixIcon,suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorLine != null? colorLine! : theme.colorScheme.secondary,
          width: 2.1),),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorLineBase != null? colorLineBase! : theme.colorScheme.onSecondaryContainer,
              width: 1.5),),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: ColorPalette.err,
              width: 1),),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorLine != null? colorLine! : theme.colorScheme.secondary,
              width: 2.1),),

      ),

      style: textStyle??  TextStyle(fontSize: 14,color:textColor?? theme.colorScheme.onPrimary), enableInteractiveSelection: enabled ?? true, readOnly: enabled != null? !enabled! : false,
      onTap: onTap, keyboardType: keyboardType, onChanged: onChanged, onSaved: ( value ){
        if( value != null  && value.isNotEmpty ){
          onSaved?.call(value);
        }
      },
    ),);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(), // Convierte el texto a mayúsculas
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
