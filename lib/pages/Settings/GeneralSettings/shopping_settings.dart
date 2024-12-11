import 'package:flutter/material.dart';
import 'package:tickets/pages/Settings/GeneralSettings/widgets_settings.dart';
import '../../../models/ConfigModels/GeneralSettingsModels/ajustesGenerales.dart';
import '../../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class ShoppingSettings extends StatefulWidget {
  ThemeData theme; Size size;
  AjustesGeneralesModels? ajustesGeneralesModels;
  ShoppingSettings({super.key, required this.theme, required this.size, required this.ajustesGeneralesModels});
  @override
  _ShoppingSettingsState createState() => _ShoppingSettingsState();
}
class _ShoppingSettingsState extends State<ShoppingSettings> {
  late ThemeData theme; late Size size;
  late WidgetsSettings ws;
  AjustesGeneralesModels? ajustesGeneralesModels;
  @override
  void initState() {
    super.initState();
    theme = widget.theme;
    size = widget.size;
    ajustesGeneralesModels = widget.ajustesGeneralesModels;
    ws = WidgetsSettings(theme);
  }

  @override
  Widget build(BuildContext context) {
    return comprasForm();
  }
  Widget comprasForm(){
    return Container(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child:Column(children: [
        ws.myContainer("     Captura y actualización",comprasSettings()),
      ],),);
  }

  Widget comprasSettings(){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
      Row(children: [
        Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
          value: ajustesGeneralesModels != null?ajustesGeneralesModels!.permisosForzosos:false, onChanged: ajustesGeneralesModels != null?
          ((value){
            CustomAwesomeDialog(title: "¿Estás seguro que deseas cambiar los permisos a ${ajustesGeneralesModels!.permisosForzosos ? "NO" : ""} forzosos?",
                desc: '', btnOkOnPress: () async {
                  ajustesGeneralesModels!.permisosForzosos = value!;
                  setState(() {});
                }, btnCancelOnPress: (){}).showQuestion(context);
          }):null,),
        const SizedBox(width: 10,),
        SizedBox(width: size.width*.24,child: const Text("Alta de proveedores en captura",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),)
      ],),
      Row(children: [
        Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
          value:ajustesGeneralesModels != null? ajustesGeneralesModels!.permisosForzosos:false, onChanged:ajustesGeneralesModels != null? (value){
            CustomAwesomeDialog(title: "¿Estás seguro que deseas cambiar los permisos a ${ajustesGeneralesModels!.permisosForzosos? "NO" : ""} forzosos?",
                desc: '', btnOkOnPress: () async {
                  ajustesGeneralesModels!.permisosForzosos = value!;
                  setState(() {});
                }, btnCancelOnPress: (){}).showQuestion(context);
          }:null,),
        const SizedBox(width: 10,),
        SizedBox(width: size.width*.24,child: const Text("Alta de productos en captura",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),)
      ],),
      const SizedBox(),
    ],);
  }
}