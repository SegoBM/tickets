import 'package:flutter/material.dart';

class MyFlatDropDown extends StatelessWidget {
  final Key? key;
  final List<dynamic> dropDownItems;
  final String selectedItem;
  final bool enabled;
  final Function(String?)? onPressed;
  final Color dropdownColor;

  final BoxDecoration? boxDecoration;
  final TextStyle? textStyle;
  final TextStyle? textStyleLabel;
  final Icon? suffixIcon;
  final Size? size;
  final Size? size2;


   MyFlatDropDown({
     this.key,
     required this.dropDownItems,
     required this.selectedItem,
     required this.onPressed,

     this.boxDecoration,
     this.textStyle,
     required this.enabled,
     this.textStyleLabel,
     required this.dropdownColor,
      this.suffixIcon, this.size, this.size2,


   });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData( useMaterial3: true ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.6,
          child:
          Container(
            height: size?.height,
            width: size2?.width,
            decoration: boxDecoration,
            child: DropdownButton<String>(
              items: dropDownItems.map((dynamic i){
                return DropdownMenuItem<String>(
                  value: i,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(i,style: textStyle,),
                    ],
                  ),
                );
              } ).toList(),
              icon: suffixIcon != null? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: suffixIcon,
              ) : null,
              isExpanded: true,
              onTap: () {},
              value: selectedItem,
              onChanged: enabled ? onPressed : null,
              style: textStyleLabel,
              underline: Container( height: 0, color: Colors.transparent),
              alignment: Alignment.center,
              dropdownColor: dropdownColor,
            ),

          ),
        ),
      ),
    );
  }
}
