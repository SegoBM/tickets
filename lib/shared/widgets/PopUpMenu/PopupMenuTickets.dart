import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';

import '../../../config/theme/app_theme.dart';
import '../buttons/custom_dropdown_button.dart';
class MyPopupMenuButtonFilter extends StatefulWidget {
  List<String> selectedItems1, selectedItems2;
  MyPopupMenuButtonFilter({Key? key, required this.selectedItems2, required this.selectedItems1}) : super(key: key);
  @override
  _MyPopupMenuButtonState createState() => _MyPopupMenuButtonState();
}

class _MyPopupMenuButtonState extends State<MyPopupMenuButtonFilter> {
  List<Widget> list = [];
  List<String> items = ["Abierto", "En Progreso", "Resuelto", "Cerrado"];
  List<String> status = ['Abierto', 'En Progreso', 'Resuelto', 'Cerrado'];
  List<String> Importancia = ['Importante', 'Urgente', 'No urgente', 'Pregunta'];
  @override
  void initState(){
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorPalette.ticketsColor4,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            _filtros()[0],
          ],),
          const SizedBox(height: 5,),
          Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            _filtros()[1],
          ],),
        ],
      ),
    );
  }

  List<Widget> _filtros() {
    return [
      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8), width: 250,
        decoration: BoxDecoration(color: ColorPalette.ticketsSelectedColor, borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(context: context, items: status,
            selectedItems: widget.selectedItems1, textColor: Colors.black54,
            backgroundColor: ColorPalette.ticketsColor4, setState: setState,
            text: "Selecciona el estatus del ticket", color: Colors.black54,
            onTap: () {
          //widget.aplicarFiltro;
          setState(() {});
            }),
      ),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8), width: 250,
        decoration: BoxDecoration(color: ColorPalette.ticketsSelectedColor, borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(context: context, items: Importancia,
            selectedItems: widget.selectedItems2, setState: setState,
            text: "Selecciona la importancia del ticket", color: Colors.black54,
            textColor: Colors.black54, backgroundColor: ColorPalette.ticketsColor4,
            onTap: () {
              //widget.aplicarFiltro;
              setState(() {});
            }),
      ),
    ];
  }
}