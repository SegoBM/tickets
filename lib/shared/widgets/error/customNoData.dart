import 'package:flutter/material.dart';

import '../../utils/icon_library.dart';
import '../../utils/texts.dart';

class NoDataWidget extends StatelessWidget {
  //final double height;
  String? text;

  NoDataWidget({
    super.key,
    this.text
  });
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height-10, width: MediaQuery.of(context).size.width-10,
      color: themeData.colorScheme.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconLibrary.iconInfo,
              size: 96,
              color: themeData.colorScheme.onPrimary,
            ),
          const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child:
                Text(text != null? text! : Texts.noInfo,
                    style: TextStyle(fontSize: 20,color: themeData.colorScheme.onPrimary,decoration: TextDecoration.none,), textAlign: TextAlign.center,)
            ),
          ],
        ),
      ),
    );
  }
}
