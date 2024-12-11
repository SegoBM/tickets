import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import '../../shared/utils/icon_library.dart';
import '../../shared/utils/texts.dart';


class NoDataWidgetTickets extends StatelessWidget {
  //final double height;
  String? text;

  NoDataWidgetTickets({
    super.key,
    this.text
  });
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height-10, width: MediaQuery.of(context).size.width-10,
      color: ColorPalette.ticketsColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(IconLibrary.iconInfo, size: 96, color: Colors.white),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child:
            Text(text != null? text! : Texts.noInfo,
              style: const TextStyle(fontSize: 20,color: Colors.white,decoration: TextDecoration.none,), textAlign: TextAlign.center,)
            ),
          ],
        ),
      ),
    );
  }
}
