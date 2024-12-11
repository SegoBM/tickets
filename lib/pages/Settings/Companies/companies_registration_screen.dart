import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/ConfigControllers/empresaController.dart';
import 'package:tickets/models/ConfigModels/empresa.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:file_picker/file_picker.dart';

class CompaniesRegistrationScreen extends StatefulWidget {
  static String id = 'userRegistration';
  const CompaniesRegistrationScreen({super.key});
  @override
  _CompaniesRegistrationScreenState createState() => _CompaniesRegistrationScreenState();
}

class _CompaniesRegistrationScreenState extends State<CompaniesRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _gKey = GlobalKey();
  final _direccionController = TextEditingController(), _direccionFiscalController = TextEditingController(),
      _nombreController = TextEditingController(), _cpController = TextEditingController(),
      _telefonoController = TextEditingController(), _rfcController = TextEditingController(),
      _emailController = TextEditingController(), _regimenFiscalConfirmController = TextEditingController(),
      _razonSocialController = TextEditingController(), _selloFiscalConfirmController = TextEditingController(),
      _giroController = TextEditingController();
  final _scrollController = ScrollController();

  late Size size; late ThemeData theme;
  Image? image; Uint8List? imageBytes;
  String base64String = "";
  @override
  void initState() {
    _regimenFiscalConfirmController.text = 'REGIMEN GENERAL DE LEY DE PERSONAS MORALES';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return PressedKeyListener(
        keyActions: {
          LogicalKeyboardKey.escape: (){
            CustomAwesomeDialog(title: Texts.alertExit,
              desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
              btnCancelOnPress: (){}).showQuestion(context);
          },
          LogicalKeyboardKey.f4: (){_save();},
        }, Gkey: _gKey,
        child: WillPopScope(
            child: Scaffold(backgroundColor: theme.backgroundColor,
              appBar: size.width > 600? MyCustomAppBarDesktop(title:"Alta de empresa", height: 45,
                suffixWidget: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Guardar  ', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),),
                      Container(padding: const EdgeInsets.all(.5),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: theme.colorScheme.secondary, width: 3))),
                          child: Text(' f4 ', style: TextStyle( color: theme.colorScheme.onPrimary ))),
                      Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary, size: size.width *.015),
                    ],),onPressed: (){_save();},
                ),
                context: context,backButton: true, defaultButtons: false,
                borderRadius: const BorderRadius.all(Radius.circular(25))
              ) : null,
            body: Padding(padding: const EdgeInsets.all(8.0),
              child: size.width > 600? _landscapeBody() : _portraitBody(),),
          ),
        onWillPop: () async {
          bool salir = false;
          CustomAwesomeDialog(title: Texts.alertExit,
            desc: Texts.lostData, btnOkOnPress:(){salir  = true;},
            btnCancelOnPress: () {salir = false;},).showQuestion(context);
          return salir;
        }
    ));
  }
  List<Widget> bodyDataCompanie(){
    return [
      _myContainer("DATOS DE LA EMPRESA"),
      _rowDivided(
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Nombre", textController: _nombreController,
          suffixIcon: const Icon(IconLibrary.iconBusiness),toUpperCase: true, validator: (value) {
            if (value == null || value.isEmpty) {
              return Texts.completeField;
            }else if(value.length > 50){
              return 'El nombre debe tener menos de 50 caracteres';
            }
            return null;
          },),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
          labelText: "Dirección", textController: _direccionController,
          suffixIcon: const Icon(IconLibrary.iconMap,),validator: (value) {
            if (value == null || value.isEmpty) {
              return Texts.completeField;
            }else if(value.length > 250){
              return 'La dirección debe tener menos de 250 caracteres';
            }
            return null;
          },),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
            labelText: "Código postal", textController: _cpController,
            suffixIcon: const Icon(IconLibrary.iconLocation),validator: (value) {
              if (value == null || value.isEmpty) {
                return Texts.completeField;
              }else if(value.length!=5 || double.tryParse(value)==null){
                return 'Ingrese un codigo postal valido (${value.length}/5)';
              }
              return null;
            }),
      ),
      const SizedBox(height: 10,),
      _rowDivided(
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
          labelText: "Teléfono", textController: _telefonoController,
          suffixIcon: const Icon(IconLibrary.iconPhone),validator: (value){
            Pattern pattern = r'^\d{10}$';
            RegExp regex = RegExp(pattern as String);
            if (value == null || value.isEmpty) {
              return null;
            } else if (!regex.hasMatch(value)) {
              return 'Por favor ingresa un número de teléfono válido';
            }
            return null;
          },),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Correo electrónico",
          textController: _emailController, suffixIcon: const Icon(IconLibrary.iconEmail),formatting: false,
          validator: (value) {
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = RegExp(pattern as String);
            if (value == null || value.isEmpty) {
              return null;
            } else if (value.length > 50) {
              return 'La dirección de correo electrónico debe tener menos de 50 caracteres';
            } else if (!regex.hasMatch(value)) {
              return 'Por favor ingresa un correo electrónico válido';
            }
            return null;
          },
        ),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
          labelText: "Giro", textController: _giroController,
          suffixIcon: const Icon(IconLibrary.iconStatistics),validator: (value){
            if (value == null || value.isEmpty) {
              return null;
            }else if(value.length > 15){
              return 'El giro debe tener menos de 15 caracteres';
            }
            return null;
          },),
      ),
      const SizedBox(height: 10,),
    ];
  }
  List<Widget> bodyDataFiscal(){
    return [
      _myContainer("INFORMACIÓN FISCAL"),
      _rowDivided(
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "RFC",
            textController: _rfcController,toUpperCase: true,
            suffixIcon: const Icon(IconLibrary.iconDescription),validator: (value) {
              if (value == null || value.isEmpty) {
                return Texts.completeField;
              }else if(value.length!=12){
                return 'Ingrese un RFC valido (${value.length}/12)';
              }
              return null;
            }),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
          labelText: "Régimen fiscal", textController: _regimenFiscalConfirmController,
          suffixIcon: const Icon(IconLibrary.iconDescriptionContact),toUpperCase: true,validator: (value){
            if (value == null || value.isEmpty) {
              return null;
            }else if(value.length > 50){
              return 'El régimen fiscal debe tener menos de 50 caracteres';
            }
            return null;
          },),
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Razón social",
          textController: _razonSocialController,
          suffixIcon: const Icon(IconLibrary.iconBusiness2),validator: (value){
            if (value == null || value.isEmpty) {
              return null;
            }else if(value.length > 100){
              return 'La razón social debe tener menos de 50 caracteres';
            }
            return null;
          },),
      ),
      const SizedBox(height: 10,),
      _rowDivided(
        MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
          labelText: "Sello digital", textController: _selloFiscalConfirmController,
          suffixIcon: const Icon(IconLibrary.iconDescriptionFile),),
          MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
            labelText: "Dirección fiscal", textController: _direccionFiscalController,
            suffixIcon: const Icon(IconLibrary.iconMap,), validator: (value){
              if (value == null || value.isEmpty) {
                return null;
              }else if(value.length > 500){
                return 'La dirección fiscal debe tener menos de 500 caracteres';
              }
              return null;
            },), const SizedBox()
      ),
    ];
  }
  List<Widget> attachWidget(){
    return [
      _myContainer("Logo de la empresa"),
      if(imageBytes!=null)... [
        Image.memory(imageBytes!, width: 100,)
      ],
      const SizedBox(height: 10,),
      ElevatedButton.icon(icon: const Icon(Icons.attach_file_rounded), // Icono del botón
        label: const Text('Seleccionar archivo'), // Texto del botón
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
            allowedExtensions: ['jpg', 'png', 'jpeg'],);
          if (result != null) {
            PlatformFile file = result.files.single;
            final File imageFile = File(file.path.toString());
            int fileSize = await imageFile.length();
            int maxSize = 1024*1024;
            if(fileSize <= maxSize){
              imageBytes = await imageFile.readAsBytes();
              image = Image.memory(imageBytes!);
              base64String = await reducirCalidadImagenBase64(base64.encode(imageBytes!));
              setState(() {});
            }else{
              CustomAwesomeDialog(title: Texts.errorSavingData, desc: Texts.imageSizeMb,
                  btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
            }
          } else {
            // El usuario canceló la selección de archivos
          }
        },
        style: ElevatedButton.styleFrom(onPrimary: theme.colorScheme.onPrimary, // Color del texto e icono del botón
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
        ),
      ),
      const SizedBox(height: 10,),
    ];
  }
  Widget _landscapeBody(){
    return Form(key: _formKey,
        child: Scrollbar(controller: _scrollController,thumbVisibility: true,
          child: FadingEdgeScrollView.fromSingleChildScrollView(child:
        SingleChildScrollView(controller: _scrollController,
            child: Column(
              children: <Widget>[
                ...bodyDataCompanie(),
                ...bodyDataFiscal(),
                ...attachWidget(),
              ],
            ))),)
    );
  }
  Widget _myContainer(String text){
    return Container(width: size.width/3,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
      padding: const EdgeInsets.all(14.0),
      child: Center(
          child: Column(children: [
            Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            Divider(thickness: 2,color: theme.colorScheme.secondary,)
          ],)
      ),
    );
  }
  Widget _rowDivided(Widget widgetL, Widget widgetR, Widget widgetC){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
      SizedBox(width: size.width*0.25,child: widgetL,),
      SizedBox(width: size.width*0.25,child: widgetR,),
      SizedBox(width: size.width*0.25,child: widgetC,),
    ],);
  }
  Widget _portraitBody(){
    return Column(children: [Text("data")],);
  }
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes manejar la lógica para guardar el área y sus departamentos
      CustomAwesomeDialog(title: Texts.askSaveConfirm, desc: '', btnOkOnPress:() async {
          try{
            LoadingDialog.showLoadingDialog(context, Texts.savingData);
            EmpresaController empresaController = EmpresaController();
            bool check = await empresaController.checkEmpresa(_nombreController.text.trim(), _rfcController.text.trim());
            if(check){
              EmpresaModels empresaModels = EmpresaModels(
                nombre: _nombreController.text.trim(),
                direccion: _direccionController.text.trim(),
                razonSocial: _razonSocialController.text.trim(),
                rfc: _rfcController.text.trim(),
                cp: double.parse(_cpController.text).toInt(),
                giro: _giroController.text.trim(),
                telefono: _telefonoController.text.trim(),
                correo: _emailController.text.trim(),
                regimenFiscal: _regimenFiscalConfirmController.text.trim(),
                selloDigital: _selloFiscalConfirmController.text.trim(),
                direccionFiscal: _direccionFiscalController.text.trim(),
                logo: base64String
              );
              bool result = await empresaController.saveEmpresa(empresaModels);
              LoadingDialog.hideLoadingDialog(context);
              if (result) {
                CustomAwesomeDialog(title: Texts.addSuccess, duration: 3500, desc: Texts.companiesCreateSuccess,
                    btnOkOnPress: () {}, btnCancelOnPress: () {}).showSuccess(context);
                Future.delayed(const Duration(milliseconds: 3550), () {
                  Navigator.of(context).pop();
                });
              } else {
                CustomSnackBar.showErrorSnackBar(context, Texts.errorSavingData);
              }
            }else{
              LoadingDialog.hideLoadingDialog(context);
              CustomAwesomeDialog(title: Texts.errorSavingData, desc: Texts.errorNameCompany,
                btnOkOnPress: () {}, btnCancelOnPress: () {  },).showError(context);
            }
          }catch(e){
            LoadingDialog.hideLoadingDialog(context);
            CustomSnackBar.showErrorSnackBar(context, '${Texts.errorSavingData}. $e');
            print('Error al enviar la solicitud: $e');
          }
        },
        btnCancelOnPress: () {},).showQuestion(context);
    }else{
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }

  Future<String> reducirCalidadImagenBase64(String base64Str, {int calidad = 50}) async {
    // Decodificar la imagen base64 a Uint8List
    Uint8List bytes = base64.decode(base64Str);
    // Decodificar la imagen para obtener un objeto Image de 'image'
    img.Image? image = img.decodeImage(bytes);
    // Codificar la imagen a JPEG con una calidad reducida
    Uint8List jpeg = img.encodeJpg(image!, quality: calidad);
    // Convertir la imagen optimizada a base64
    return base64.encode(jpeg);
  }
}