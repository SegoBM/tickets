import 'dart:convert';
import 'dart:io';
import 'package:tickets/controllers/ComprasController/MaterialesControllers/familia_controller.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:image/image.dart' as img;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Compras/pages/materiales/materiales_main_screen.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:rive/rive.dart';

import '../../../../controllers/ComprasController/MaterialesControllers/materialesController.dart';
import '../../../../models/ComprasModels/MaterialesModels/familia_model.dart';
import '../../../../models/ComprasModels/MaterialesModels/materiales.dart';
import '../../../../shared/actions/handleException.dart';
import '../../../../shared/utils/image_picker.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/buttons/dropdown_decoration.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/textfields/dropdown_buttonform.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';



class EditMateriaScreen extends StatefulWidget {
  List<FamiliaModel> familia;
 final MaterialesModels material;

   EditMateriaScreen({
     super.key,
     required this.material,
     required this.familia
   });

  @override
  State<EditMateriaScreen> createState() => _EditMateriaScreenState();
  static const id = 'Edit_materials_screen';
}

class _EditMateriaScreenState extends State<EditMateriaScreen> {
  // final MaterialesModels material;
 final GlobalKey _gkey = GlobalKey();
 final GlobalKey<FormState> _forEditKey = GlobalKey<FormState>();
 final  ScrollController _threeFormSController = ScrollController();
 List<FamiliaModel> listFamilia = [];
 late FamiliaModel selectedFamiliaModel;

 List<MaterialesModels>materialList =[];

 List<String> listFamilias = ["Seleccione una Familia"];

 List<String> familiaListIt =[ "Seleccione una Familia",];
 String selectedFamilia = "Seleccione una Familia";

 List<String> subFamiliaListIt =["Seleccione una SubFamilia"];
 String selectedSubFamilia = "Seleccione una SubFamilia";

 String base64String ="";
 Uint8List? imageBytes;
 Image? image;

 late Future<List<MaterialesModels>> _futureMaterials;

 File? _image;

  late ThemeData theme;
  late Size size;
 //
 // String selectedClasif = "Clasificacion1";
 // String selecteCat = "Categoria1";
 // String selectedStat = "Status1";
 List<String> listEstatus = ['INACTIVO', 'ACTIVO', 'BLOQUEADO', 'FUERA DE LÍNEA'];
 final List<String> clasiItems = ["Clasificacion1", "Clasificacion2", "Clasificacion3"];
 final List<String> _catItem = ["Categoria1","Categoria2","Categoria3","Categoria4"];
 final List<String> statItem = ["0","1","2","3"];

 final Map<String, int> statusMap ={
   "INACTIVO": 0,
   "ACTIVO": 1,
   "BLOQUEADO": 2,
   "FUERA DE LÍNEA": 3
 };

 final Map<int, String> reseverStatusMap ={
   0: "INACTIVO",
   1: "ACTIVO",
   2: "BLOQUEADO",
   3: "FUERA DE LÍNEA"
 };


 int index = 0;

 final TextEditingController _fotoController = TextEditingController();

 final TextEditingController _codigoProductoController = TextEditingController();
 final TextEditingController _clasificacionController = TextEditingController();
 final TextEditingController _categoriaController = TextEditingController();
 final TextEditingController _estatusController = TextEditingController();
 final TextEditingController _descripcionController = TextEditingController();
 final TextEditingController _familiaNombreController = TextEditingController();
 final TextEditingController _idMaterialController = TextEditingController();
 final TextEditingController _subFamiliaNombreController = TextEditingController();
 final TextEditingController _subFamiliaIDController = TextEditingController();
 final TextEditingController _precioVentaController = TextEditingController();
 final TextEditingController _costoController = TextEditingController();
 final TextEditingController _fraccionArancelariaController = TextEditingController();
 final TextEditingController _unidadMedidaCompraController = TextEditingController();
 final TextEditingController _unidadMedidaVentaController = TextEditingController();
 final TextEditingController _composicionController = TextEditingController();
 final TextEditingController _espesorMMController = TextEditingController();
 final TextEditingController _anchoController = TextEditingController();
 final TextEditingController _largoController = TextEditingController();
 final TextEditingController _metrosXRolloController = TextEditingController();
 final TextEditingController _igiController = TextEditingController();
 final TextEditingController _referenciaCalidadController = TextEditingController();
 final TextEditingController _referenciaColorController = TextEditingController();
 final TextEditingController _gsmController = TextEditingController();
 final TextEditingController _pesoXBultoController = TextEditingController();

 final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();
  final FocusNode _focusNode7 = FocusNode();
  final FocusNode _focusNode8 = FocusNode();
  final FocusNode _focusNode9 = FocusNode();
  final FocusNode _focusNode10 = FocusNode();
 final FocusNode _gsmFocusNode = FocusNode();

 @override
  void initState() {
    fillTExtFields();
    fillDropdowns();
    super.initState();
  }
  @override
  void dispose() {
   familiaListIt.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    return PressedKeyListener(key: _gkey,
        keyActions: {
          LogicalKeyboardKey.escape: (){
            CustomAwesomeDialog(
              title: 'Saldras de la eidción de Material',
              desc: Texts.lostData,
              btnCancelOnPress:(){},
              btnOkOnPress:(){
                Navigator.of(context).pop();
              },).showQuestion(context);
            print('Escape key pressed');
          }
        },
        Gkey: _forEditKey,
        child: WillPopScope(
          child: Scaffold(
            backgroundColor: theme.colorScheme.background,
            appBar: size.width > 600? MyCustomAppBarDesktop(
                title: 'Edición de Material', height: 45,
                context: context, backButton: true,defaultButtons: false,
                borderRadius:  BorderRadius.circular(25) ,
              suffixWidget: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0 ),
                onPressed: () async {
                  _customUpdate();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text( 'Guardar  (f4) ', style: TextStyle( color: theme.colorScheme.onPrimary ),),
                    Icon( IconLibrary.iconSave, color: theme.colorScheme.onPrimary )
                  ],),
              ),
            ): null,
            body: size.width > 600? _landScapeBody() : _portraitBody(),
          ) ,
          onWillPop: () async {
            bool salir = false;
            CustomAwesomeDialog(
              title: 'Saldras de la edición de Material',
              desc:Texts.lostData,
              btnCancelOnPress: (){ salir = true; },
              btnOkOnPress: (){ salir = false; },).showQuestion(context);
            return salir;
          },
        )
    );
  }


_landScapeBody(){
  return Form(
    key: _forEditKey,
    child: Scrollbar(
      thumbVisibility: true,
      controller: _threeFormSController,
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: _threeFormSController,
          child: Column( children:[
            _datosEnGeneral(),
            const SizedBox(height: 5,),
            ..._familySelector(),
            const SizedBox(height: 5,),
            _datosEnEspecifico(),
          ] ),
        ),
      ),
    ),
  );
}

Widget  _portraitBody(){
    return Placeholder();
}

 Widget _datosEnGeneral() {
   return Column( children:
   [
     _headerContainer( "Datos Generales" ),
     Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
       children: [
         Column(children:[
           _dividedFormRow( portion: .27,
             MyTextfieldIcon(
                 colorLineBase: theme.colorScheme.onPrimary,
                 backgroundColor: theme.colorScheme.background,
                 suffixIcon: const Icon(IconLibrary.barCode) ,
                 inputFormatters: [LengthLimitingTextInputFormatter(10)],
                 labelText: 'Código', textController: _codigoProductoController,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Este campo es requerido';
                   }else if(value.length < 4 ){
                     return 'El campo debe de tener mas de 4 caracteres. Ingresados ${value.length}';
                 } if(value.length >10){
                     return 'El campo debe de tener menos de 10caracteres. Ingresados ${value.length}';
                   }
                   return null; // Indica que el valor es válido
                 }
             ),
             CustomDropdown(
                 labelText: "Clasificacion",
                 items: clasiItems,
                 textController: _clasificacionController,
                 onChanged: (newValue) {
                   setState(() {
                     _clasificacionController.text = newValue!;
                   });
                 },
                 // validator: (value) {
                 //   if (value == null || value.isEmpty) {
                 //     return 'Este campo es requerido';
                 //   }
                 //   return null;
                 // }
             ),
           ),
           const SizedBox( height: 10, ),
           _dividedFormRow( portion: .27,
             CustomDropdown(
                 labelText: "Categoria",
                 items: _catItem,
                 textController: _categoriaController,
                 onChanged: (newValue) {
                    setState(() {
                      _categoriaController.text = newValue!;
                    });
                 },
                 // validator: (value) {
                 //   if (value == null || value.isEmpty) {
                 //     return 'Este campo es requerido';
                 //   }
                 //   return null; // Indica que el valor es válido
                 // }
             ),
             CustomDropdown(
                 labelText: 'Estatus',
                 items:listEstatus,
                 textController: _estatusController,
                 onChanged: (newValue) =>
                 setState(() {
                   _estatusController.text = newValue!;
                 }),
                 // validator: (value) {
                 //   if (value == null || value.isEmpty) {
                 //     return 'Este campo es requerido';
                 //   }
                 //   return null; // Indica que el valor es válido
                 // }
             ),
           ),
           const SizedBox( height: 10 ),
           _singleFormRow( portion: .55, space: 2,
             MyTextfieldIcon(
                 formatting: true,
                 colorLineBase: theme.colorScheme.onPrimary,
                 backgroundColor: theme.colorScheme.background,
                 labelText: 'Descripción',
                 textController: _descripcionController,
                 suffixIcon: const Icon(IconLibrary.noteIcon),
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Este campo es requerido';
                   } else if( 10 < value.length){
                     'El campo debe de tener mas de 10 caracteres. Ingresados ${value.length}';
                   }
                   return null; // Indica que el valor es válido
                 }
             ),
           ),
         ]),
         Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             MyImagePickerWidget(
               holderText: 'Insertar Imagen',
               height: size.height*.35,
               width: size.width*.25,
               onImagePicked: (File image) {
                 setState(() {
                   _image = image;
                 });
               },
             ),
           ],),
       ],),
   ]) ;
 }

 List<Widget> _familySelector(){
   return [
     _headerContainer("Seleccione una Familia"),
     _dividedFormRow( Column(crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text("Familia", style: TextStyle(fontSize: 15),),
         MyDropdown(
           textStyle: TextStyle(fontSize: 12.0, color: theme.colorScheme.onPrimary),
           dropdownItems: listFamilias ,
           selectedItem: selectedFamilia,
           suffixIcon: const Icon(IconLibrary.iconGroups),
           onPressed: (String? value) async {
             setState(() {
               selectedFamilia = value!;
               selectedSubFamilia = "Seleccione una SubFamilia";
               if (value != "Seleccione una Familia") {
                 subFamiliaListIt = ["Seleccione una SubFamilia"];
                 for (int i = 0; i < listFamilia.length; i++) {
                   print(value);
                   if (listFamilia[i].nombre == value) {
                     print(value);
                     selectedFamiliaModel = listFamilia[i];
                     break;
                   }
                 }
                 for( int j = 0; j < selectedFamiliaModel.subFamilia!.length; j++ ){
                   print("selectedFamiliaModel.subFamilia![j].nombre: ${selectedFamiliaModel.subFamilia![j].nombre}");
                   subFamiliaListIt.add( selectedFamiliaModel.subFamilia![j].nombre );
                 }
               }
             });
           },
           enabled: true,
         )
       ],),
        Column(
          children:[
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation){
                  return FadeTransition(
                      opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.0),
                        end: Offset.zero
                      ).animate(animation),
                      child: child,
                    ),
                  );
              },
              child: selectedFamilia != "Seleccione una Familia"
              ? Column(
                key: ValueKey<String>(selectedFamilia),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SubFamilia", style: TextStyle( fontSize: 15 ),
                  ),
                  MyDropdown(
                    enabled: true,
                    textStyle: TextStyle(
                        fontSize: 12.0,
                        color: theme.colorScheme.onPrimary),
                    dropdownItems: subFamiliaListIt,
                    selectedItem: selectedSubFamilia,
                    suffixIcon: const Icon(IconLibrary.iconGroups),
                    onPressed: (String? value) async {
                      print(value);
                      setState(() {
                        selectedSubFamilia = value!;
                      });
                    },
                  )
                ],
              ): const SizedBox.shrink(),
            )
          ]
        )
     )
   ];
 }

 Widget _threeFormBody(){
   return Column(
     children:
     <Widget>[
       _threeRowContainer(
           MyTextfieldIcon(
             focusNode: _gsmFocusNode ,
             autoSelectText: true,
             formatting: true,
             backgroundColor: theme.colorScheme.background,
             labelText: 'GSM',
             textController: _igiController,
             suffixIcon: Icon(
                 Icons.public_off_outlined, size: size.height * .025),
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
           ),
           MyTextfieldIcon(
             focusNode: _focusNode10,
             autoSelectText: true,
             backgroundColor: theme.colorScheme.background,
             labelText: 'Peso por Bulto',
             textController: _pesoXBultoController,
             suffixIcon: Icon(
               Icons.scale_outlined, size: size.height * .025,),
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
             validator: (value) {
               if (!isNumeric(value!)) {
                 return 'Por favor ingrese un valor númerico';
               }
             },
           ),
           MyTextfieldIcon(
             focusNode: _focusNode,

             autoSelectText: true,
             backgroundColor: theme.colorScheme.background,
             suffixIcon: Icon(
                 IconLibrary.iconMoney, size: size.height * .025),
             labelText: 'Precio de Venta',
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
             textController: _precioVentaController,
             validator: (value) {
               if (!isNumeric(value!)) {
                 return "Porfavor ingrese un valor númerico";
               }
             },
           )
       ),
       const SizedBox(height: 10,),
       _threeRowContainer(
           MyTextfieldIcon(
             focusNode: _focusNode2,
             autoSelectText: true,
             backgroundColor: theme.colorScheme.background,
             // validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
             suffixIcon: Icon(Icons.payment, size: size.height * .025),
             labelText: 'Costo',
             textController: _costoController,
             validator: (value) {
               if (!isNumeric(value!)) {
                 return 'ingrese un valor númerico';
               }
             },
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
           ),
           MyTextfieldIcon(
             focusNode: _focusNode3,
             autoSelectText: true,
             backgroundColor: theme.colorScheme.background,
             labelText: 'Fraccion arancelaria',
             textController: _fraccionArancelariaController,
             suffixIcon: Icon(Icons.percent, size: size.height * .025),
             validator: (value) {
               if (!isNumeric(value!)) {
                 return 'Por favor ingrese un valor númerico';
               }
             },
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
           ),
           MyTextfieldIcon(
             focusNode: _focusNode4,
             autoSelectText: true,
             backgroundColor: theme.colorScheme.background,
             labelText: 'Unidad Medida ( Compra )',
             textController: _unidadMedidaCompraController,
             suffixIcon: Icon(
                 Icons.straighten_outlined, size: size.height * .025),
             validator: (value) {
               if (!isNumeric(value!)) {
                 return 'Por favor ingrese un valor númerico';
               }
             },
             floatingLabelStyle: TextStyle(
                 color: theme.colorScheme.onPrimary),
           )
       ),
       const SizedBox(height: 10),
       _threeRowContainer(
         MyTextfieldIcon(
           focusNode: _focusNode5,
           autoSelectText: true,
           backgroundColor: theme.colorScheme.background,
           labelText: 'Unidad Medida ( Venta )',
           textController: _unidadMedidaVentaController,
           suffixIcon: Icon(
               Icons.straighten_outlined, size: size.height * .025),
           validator: (value) {
             if (!isNumeric(value!)) {
               return 'Por favor ingrese un valor númerico';
             }
           },
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
         ),
         MyTextfieldIcon(
           backgroundColor: theme.colorScheme.background,
           labelText: 'Composición',
           textController: _composicionController,
           suffixIcon: Icon(IconLibrary.callMade, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
         ),
         MyTextfieldIcon(
           focusNode: _focusNode6,
           autoSelectText: true,
           backgroundColor: theme.colorScheme.background,
           labelText: 'Espesor "MM"',
           textController: _espesorMMController,
           suffixIcon: Icon(
               Icons.square_foot_outlined, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
           validator: (value) {
             if (!isNumeric(value!)) {
               return 'Por favor ingrese un valor númerico';
             }
           },
         ),
       ),
       const SizedBox(height: 10,),
       _threeRowContainer(
         MyTextfieldIcon(
           focusNode: _focusNode7,
           autoSelectText: true,
           backgroundColor: theme.colorScheme.background,
           enabled: true,
           labelText: 'Ancho',
           textController: _anchoController,
           suffixIcon: Icon(
               Icons.width_wide_outlined, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
           validator: (value) {
             if (!isNumeric(value!)) {
               return 'Por favor ingrese un valor númerico';
             }
           },
         ),
         MyTextfieldIcon(
           focusNode: _focusNode8,
           autoSelectText: true,
           backgroundColor: theme.colorScheme.background,
           labelText: 'Largo',
           textController: _largoController,
           suffixIcon: Icon(
               Icons.density_large_outlined, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
           validator: (value) {
             if (!isNumeric(value!)) {
               return 'Por favor ingrese un valor númerico';
             }
           },
         ),
         MyTextfieldIcon(
           focusNode: _focusNode9,
           autoSelectText: true,
           backgroundColor: theme.colorScheme.background,
           labelText: 'Metros por rollo',
           textController: _metrosXRolloController,
           suffixIcon: const Icon(Icons.radar),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
           validator: (value) {
             if (!isNumeric(value!)) {
               return 'Por favor ingrese un valor númerico';
             }
           },
         ),
       ),
       const SizedBox(height: 10,),
       _threeRowContainer(
         MyTextfieldIcon(
           backgroundColor: theme.colorScheme.background,
           labelText: 'IGI',
           textController: _gsmController,
           suffixIcon: Icon(
               Icons.format_underline, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
         ),
         MyTextfieldIcon(
           backgroundColor: theme.colorScheme.background,
           labelText: 'Referencia de Calidad',
           textController: _referenciaCalidadController,
           suffixIcon: Icon(
               Icons.psychology_outlined, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
         ),
         MyTextfieldIcon(
           backgroundColor: theme.colorScheme.background,
           labelText: 'Referencia de Color',
           textController: _referenciaColorController,
           suffixIcon: Icon(
               Icons.palette_outlined, size: size.height * .025),
           floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
         ),
       ),
     ],
   );
 }

 Widget _datosEnEspecifico(){
   return Column(children:[
     _headerContainer("Datos en especifico"),
     _threeFormBody()
   ]);
 }

 Widget _threeRowContainer( Widget widget1, Widget widget2, Widget widget3){
   return Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children:
       [
         SizedBox( width: size.width*.223, child: widget1, ),
         SizedBox( width: size.width*.223, child: widget2, ),
         SizedBox( width: size.width*.223, child: widget3,),
       ]
   );
 }

 Widget _headerContainer(String text){
   return Container(
     width: size.width/3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
     padding: const EdgeInsets.all(10),
     child:Center(
       child:Column( children:[
         Text(text,style: const TextStyle( fontSize: 18.0,fontWeight: FontWeight.bold ),),
         Divider( thickness: 2, color: theme.colorScheme.secondary, ),
       ],
       ),),);
 }
 Widget _dividedFormRow( Widget widgetL, Widget widgetR,{ double? portion = .20 } ){
   return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     children: [
       SizedBox( width: size.width*portion! , child: widgetL,),
       const SizedBox( width: 10, ),
       SizedBox( width: size.width*portion, child: widgetR,),
     ],);
 }
 Widget _dividedFormRowLeft( Widget widgetL, Widget widgetR, { double space = 5 } ){
   return Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
     children: [
       SizedBox( width: space, ),
       SizedBox( width: size.width*.223 , child: widgetL,),
       SizedBox( width: space, ),
       SizedBox( width: size.width*.223, child: widgetR,),
       const SizedBox(width: 5,),
       SizedBox(width: size.width*.223,),
       const SizedBox(width: 5),
     ],);
 }
 Widget _singleFormRow( Widget widgetL, {double portion  = .2, double space = 5}){
   return Row( mainAxisAlignment: MainAxisAlignment.start,
     children: [
       SizedBox( width: space, ),
       SizedBox(  width: size.width *portion, child: widgetL,),
     ],);
 }
  _customUpdate() async {
   if( _forEditKey.currentState!.validate()){
    if( selectedFamilia == "Seleccione una Familia" || selectedSubFamilia == "Seleccione una SubFamilia" ){
      CustomAwesomeDialog(
        title: 'Familia/subFamilia no seleccionada',
        desc: 'Por favor seleccione una familia/subFamilia',
        btnOkOnPress: () {  },
        btnCancelOnPress: () {  },
      ).showQuestion(context);
    } else{
      CustomAwesomeDialog(
        title:'¿Está seguro de guardar este material?',
        desc: '',
        btnCancelOnPress: (){},
        btnOkOnPress: () async{
          await updateMaterial();
          },
      ).showQuestion(context);

    }

   }
 }

 bool isNumeric(String s){
   return double.tryParse(s) != null ;
 }

 Future<void> getMaterials() async {
   materialList = [];
 }
 Future<void> updateMaterial ()async {

   try {
     MaterialesModels material = MaterialesModels(
       idMaterial: widget.material.idMaterial,
       categoria: _categoriaController.text.trim(),
       codigoProducto: _codigoProductoController.text.trim(),
       unidadMedidaCompra: _unidadMedidaCompraController.text.trim(),
       unidadMedidaVenta: _unidadMedidaVentaController.text.trim(),
       composicion: _composicionController.text.trim(),
       espesorMM: double.parse(_espesorMMController.text.trim()),
       ancho: double.parse(_anchoController.text.trim()),
       largo: double.parse(_largoController.text.trim()),
       metrosXRollo: int.parse(_metrosXRolloController.text.trim()),
       costo: double.parse(_costoController.text.trim()),
       precioVenta: double.parse(_precioVentaController.text.trim()),
       igi: double.parse(_igiController.text.trim()),
       referenciaCalidad: _referenciaCalidadController.text,
       referenciaColor: _referenciaColorController.text,
       gsm: double.parse(_gsmController.text.trim()),
       pesoXBulto: double.parse(_pesoXBultoController.text.trim()),
       descripcion: _descripcionController.text,
       foto: base64String,
       subFamiliaID: selectedFamiliaModel.subFamilia!.firstWhere((element) => element.nombre == selectedSubFamilia).iDSubFamilia,
       subFamiliaNombre: selectedSubFamilia,
       familiaNombre: selectedFamilia,
       fraccionArancelaria: double.parse(_fraccionArancelariaController.text.trim()),
       estatus: statusMap[_estatusController.text.trim()]!,
     );

     bool result = await MaterialesController().updateMaterial( material, widget.material.idMaterial.toString());

    if (result) {
    CustomAwesomeDialog(title: Texts.savingData, desc: '', btnOkOnPress: () { Navigator.of(context).pop(); }, btnCancelOnPress: () {  },).showSuccess(context);
    await Future.delayed(const Duration(milliseconds: 2500), (){
      _forEditKey.currentState!.reset();
      Navigator.of(context).pop();
    });
    }
   } catch(e){
     // LoadingDialog.hideLoadingDialog(context);
     ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
     String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
     CustomAwesomeDialog(title: Texts.errorSavingData, desc: error, btnOkOnPress: () {
       Navigator.of(context).pop();
     }, btnCancelOnPress: () {}).showError(context);
     print('Error al enviar la solicitud: $e');
   } finally {
     // LoadingDialog.hideLoadingDialog(context);
   }
 }

 Future<void> _pickImage() async {
   FilePickerResult? result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['jpg','png','jpeg'] );
   if(result != null){
     PlatformFile file = result.files.single;
     final File imageFile = File( file.path.toString());
     int fileSize = await imageFile.length();
     int maxSize = 1024*1024;
     if( fileSize <= maxSize){
       imageBytes = await imageFile.readAsBytes();
       image = Image.memory(imageBytes!);
       base64String = maxSize/10 > fileSize? base64.encode(imageBytes!) : await reducirCalidadImageneBase64( base64.encode(imageBytes!) );
     } else {
       CustomAwesomeDialog(
         title: Texts.errorSavingData, desc:'La imagen debe tener un tamaño menor a 1MB',
         btnOkOnPress: () {  },btnCancelOnPress: () {  }).showError(context);
     }
   }
 }

 Future<String> reducirCalidadImageneBase64( String base64Str, { int calidad = 50 } ) async {
   Uint8List byte = base64.decode(base64Str);
   img.Image? image = img.decodeImage(byte);
   Uint8List jpeg  = img.encodeJpg(image!, quality: calidad);
   return base64.encode(jpeg);
 }

 fillDropdowns() {
   listFamilias.clear();
   listFamilias.add("Seleccione una Familia");
   subFamiliaListIt.clear();
   subFamiliaListIt.add("Seleccione una SubFamilia");
   listFamilia = widget.familia;
   for ( var familia in listFamilia ){
     listFamilias.add(familia.nombre);
     if( familia.nombre == widget.material.familiaNombre ){
       selectedFamiliaModel = familia;
       selectedFamilia = familia.nombre;
     }
   }
   if( selectedFamilia != "Seleccione una Familia" ){
     for( var subFamilia in selectedFamiliaModel.subFamilia! ){
       subFamiliaListIt.add( subFamilia.nombre );
       if(subFamilia.nombre == widget.material.subFamiliaNombre){
         selectedSubFamilia = subFamilia.nombre;
       }
     }
   }
   setState(() {});
 }

 fillTExtFields(){
   _codigoProductoController.text = widget.material.codigoProducto;
   _categoriaController.text = widget.material.categoria;
   _estatusController.text = widget.material.estatus.toString();
   _descripcionController.text = widget.material.descripcion;
   _familiaNombreController.text = widget.material.familiaNombre??'';
   _subFamiliaNombreController.text = widget.material.subFamiliaNombre??'';
   _precioVentaController.text = widget.material.precioVenta.toString();
   _costoController.text = widget.material.costo.toString();
   _fraccionArancelariaController.text = widget.material.fraccionArancelaria.toString();
   _unidadMedidaCompraController.text = widget.material.unidadMedidaCompra.toString();
   _unidadMedidaVentaController.text = widget.material.unidadMedidaVenta.toString();
   _composicionController.text = widget.material.composicion;
   _espesorMMController.text = widget.material.espesorMM.toString();
   _anchoController.text = widget.material.ancho.toString();
   _largoController.text = widget.material.largo.toString();
   _metrosXRolloController.text = widget.material.metrosXRollo.toString();
   _igiController.text = widget.material.igi.toString();
   _referenciaCalidadController.text = widget.material.referenciaCalidad;
   _referenciaColorController.text = widget.material.referenciaColor;
   _gsmController.text = widget.material.gsm.toString();
   _pesoXBultoController.text = widget.material.pesoXBulto.toString();
   _estatusController.text = reseverStatusMap[widget.material.estatus]!;

 }

}


