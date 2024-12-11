import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/utils/color_palette.dart';
import '../../../shared/widgets/textfields/my_textfield_icon.dart';
import '../../../shared/widgets/textfields/my_textfield_numer.dart';

class WidgetsSettings{
  final ThemeData theme;
  WidgetsSettings(this.theme);

  Widget myContainer(String title,Widget child){
    return Container(decoration: BoxDecoration(color: theme.primaryColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        customTitleDivider(title, theme),
        const SizedBox(height: 10,),
        child
      ],),);
  }
  Widget myContainer2(String title,Widget child, double? width, Widget widget){
    return Container(width: width,decoration: BoxDecoration(color: theme.primaryColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[
          customTitleDivider(title, theme),
          widget
        ]),
        const SizedBox(height: 10,),
        child
      ],),);
  }
  Widget customTitleDivider(String title, ThemeData theme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          maxLines: 1, textDirection: TextDirection.ltr,
        )..layout(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final textWidth = textPainter.width;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(" $title", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary)),
            Container(width: textWidth*1.2,height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.secondary,borderRadius: BorderRadius.circular(10)),),
          ],
        );
      },
    );
  }
  Widget boxWithTextField(String title, TextEditingController controller, IconData icon, {bool enable = true,
    String? Function(String?)? validator,double? width = 200, List<TextInputFormatter>? inputFormatters}){
    return SizedBox(width: width,child: MyTextfieldIcon(
        errorStyle: const TextStyle(fontSize: 10.5, color: ColorPalette.err), inputFormatters: inputFormatters,
        backgroundColor: theme.colorScheme.background, labelText: title, enabled: enable,
        labelStyle: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
        floatingLabelStyle: TextStyle( fontWeight: FontWeight.bold,color: theme.colorScheme.onPrimary),
        textController: controller, suffixIcon: Icon(icon),validator: validator??(value){
      if(value == null || value.isEmpty){
        return 'Por favor completa este campo';
      }
      return null;
    }
    ));
  }
  Widget buttonCancelar(Function ()? onPressed){
    return OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.inversePrimary), onPressed: onPressed,
        child: const Text('Cancelar'));
  }
  Widget buttonAceptar(Function ()? onPressed){
    return ElevatedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.secondary),onPressed: onPressed, child: const Text('Guardar'));
  }
  Widget textFieldCantidades(String title, TextEditingController controller){
    return MyTextfieldNumber(
      backgroundColor: theme.colorScheme.primary, labelText: title,
      labelStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
      floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary), textController: controller,
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Por favor completa este campo';
        }
        return null;
      },
    );
  }
  Widget filaEspecial(String title, String value, {double? width = 140, Color? color, TextOverflow? textOverflow = TextOverflow.ellipsis}){
    return SizedBox(width: width, child: Row(children: [
      Text("$title: ", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
      Flexible(child: Text(value, overflow: textOverflow,style: TextStyle(color: color?? theme.colorScheme.onPrimary.withOpacity(0.8))))
    ],),);
  }
  Widget filaEspecialWidget(Widget widget, String value, {double? width = 140, Color? color, TextOverflow? textOverflow = TextOverflow.ellipsis}){
    return SizedBox(width: width, child: Row(children: [
      widget,
      const SizedBox(width: 5,),
      Flexible(child: Text(value, overflow: textOverflow,style: TextStyle(color: color?? theme.colorScheme.onPrimary.withOpacity(0.8))))
    ],),);
  }
  Widget buildLoadingIndicator(int n, Size size) {
    {
      List<Widget> cardList = List.generate(n, (index) {
        return cardEsqueleto(size.width);
      });
      return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: cardList)
      );
    }
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 35,child: Card(
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),),
        color: theme.colorScheme.background, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Shimmer.fromColors(
            baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(7),),
            ),
          ),
        )
    ),);
  }
}