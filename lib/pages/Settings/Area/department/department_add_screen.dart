import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/departamentoController.dart';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import '../../../../models/ConfigModels/puesto.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/utils/user_preferences.dart';
import '../../../../shared/widgets/dialogs/customAlertDialog.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class DepartamentoAddScreen extends StatefulWidget {
  @override
  _DepartamentoAddScreenState createState() => _DepartamentoAddScreenState();
}

class _DepartamentoAddScreenState extends State<DepartamentoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _departmentAddkey = GlobalKey();
  final _departamentoController = TextEditingController();
  final List<String> _puestos = [];
  final _puestoController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late Size size; late ThemeData theme;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return PressedKeyListener(
        keyActions: {
          LogicalKeyboardKey.f4: (){_save();},
          LogicalKeyboardKey.f1: (){_addDepartment();},
          LogicalKeyboardKey.escape: () {
            CustomAwesomeDialog(title: Texts.alertExit,
                desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
                btnCancelOnPress: (){}).showQuestion(context);
          },
        },
        Gkey: _departmentAddkey,
        child: Scaffold(
          appBar: size.width > 600? MyCustomAppBarDesktop(padding: 10.0,title:"Alta de departamento",
              height: 45,
              suffixWidget: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Guardar  ', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),),
                    Container(padding: const EdgeInsets.all(.5),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: theme.colorScheme.secondary, width: 3,),)),
                        child: Text(' f4 ', style: TextStyle( color: theme.colorScheme.onPrimary ),)),
                    Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary, size: size.width *.015, ),
                  ],),onPressed: (){ _save(); },
              ),
              context: context,backButton: true, defaultButtons: false,
              borderRadius: const BorderRadius.all(Radius.circular(25))
          ) : null,
          body: Form(key: _formKey,
              child: SingleChildScrollView(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(width: size.width*0.40,child: MyTextfieldIcon(labelText: "Departamento",toUpperCase: true,
                        textController: _departamentoController, backgroundColor: theme.colorScheme.background,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Texts.completeField;
                          }else if(value.length > 50){
                            return 'El nombre del departamento debe tener menos de 50 caracteres';
                          }
                          return null;
                        })
                    ),
                    const SizedBox(height: 10),
                    _myContainerPermisos('Puestos',_puestos,size.width),
                  ],
                ),
              ),)
        ),
      )
    );
  }

  Widget _myContainerPermisos(String text,List<String> departamento,double width){
    return Container(width: width,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor), padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            const SizedBox(),
            Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),),
            IconButton(onPressed: (){_addDepartment();},
              icon: const Icon(IconLibrary.iconAdd),
              hoverColor: theme.colorScheme.background, style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
                padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            ),
          ],),
          Divider(thickness: 2,color: theme.colorScheme.secondary,),
          SizedBox(height: size.height-295,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(controller: scrollController, itemCount: departamento.length,
                itemBuilder: (context, index){
                  return _departmentWidget(index);
                },
              ),
            ),)
        ],)
    );
  }
  Widget _rowDivided(Widget widgetL, Widget widgetR){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
      SizedBox(width: size.width*0.35,child: widgetL,),
      SizedBox(width: size.width*0.35,child: widgetR,),
    ],);
  }
  Widget _backBody(){
    return IconButton(
      icon: const Icon(IconLibrary.iconBack),
      onPressed: () {
        CustomAwesomeDialog(title: Texts.alertExit, desc: Texts.lostData,
            btnOkOnPress: (){Navigator.of(context).pop();}, btnCancelOnPress: (){}).showQuestion(context);
      },
    );
  }
  void _addDepartment(){
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context2){
      return StatefulBuilder(
          builder: (BuildContext context2, StateSetter setState)
          {return ScaffoldMessenger(child: Builder(
              builder: (context2) => PressedKeyListener(keyActions: {
                LogicalKeyboardKey.f4: (){saveDepartment(context2);},
                LogicalKeyboardKey.escape: () {
                  _puestoController.text = "";
                  Navigator.of(context2).pop();
                },
              }, Gkey: _departmentAddkey,
              child: Scaffold(backgroundColor: Colors.transparent, body: alertDialogAddJob(context2))
              )
          ));}
      );
    });
  }
  Widget _departmentWidget(int index){
    return MySwipeTileCard(horizontalPadding: 0, colorBasico: theme.colorScheme.background,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            SizedBox(width: (size.width*.35),child: Text(_puestos[index],
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),),)
          ],),), onTapLR: (){editPuesto(index);},
        onTapRL: (){deletePuesto(index);});
  }
  void editPuesto(int index){
    _puestoController.text = _puestos[index];
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context2){
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState)
          {return ScaffoldMessenger(child: Builder(
              builder: (context) => Scaffold(backgroundColor: Colors.transparent,
                  body: alertDialogEditJob(context, index)
              )
          ));}
      );
    });
  }
  void deletePuesto(int index){
    CustomAwesomeDialog(title: Texts.askDeleteConfirm,
        desc: 'Puesto: ${_puestos[index]}', btnOkOnPress: (){_puestos.removeAt(index);setState(() {});},
        btnCancelOnPress: (){}).showQuestion(context);
  }
  Widget alertDialogAddJob(BuildContext context){
    return CustomAlertDialog(title: "Agregar Puesto",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Puesto", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,),toUpperCase: true,
                textController: _puestoController, suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: (){saveDepartment(context);},
      onPressedCancel: (){
        _puestoController.text = "";
        Navigator.of(context).pop();
      },
    );
  }
  void saveDepartment(BuildContext context){
    if(_puestoController.text.isNotEmpty){
      if(_puestoController.text.length > 50){
        CustomSnackBar.showInfoSnackBar(context, 'El nombre del puesto debe tener menos de 50 caracteres');
      }else{
        _puestos.add(_puestoController.text.trim());
        setState(() {});
        _puestoController.text = "";
        Navigator.of(context).pop();
      }
    }else{
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
  Widget alertDialogEditJob(BuildContext context, int index){
    return CustomAlertDialog(title: "Editar Puesto",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Puesto", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,),
                textController: _puestoController,toUpperCase: true,
                suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: (){
        if(_puestoController.text.isNotEmpty){
          if(_puestoController.text.length > 50){
            CustomSnackBar.showInfoSnackBar(context, 'El nombre del puesto debe tener menos de 50 caracteres');
          }else{
            _puestos[index] = _puestoController.text.trim();
            setState(() {});
            _puestoController.text = "";
            Navigator.of(context).pop();
          }
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }
  void _save(){
    if (_formKey.currentState!.validate()) {
      if(_puestos.isNotEmpty){
        DepartamentoModels departamento = DepartamentoModels(nombre: _departamentoController.text.trim(),
            puestos: _puestos.map((e) => PuestoModels(nombre: e)).toList());
        CustomAwesomeDialog(title: Texts.askSaveConfirm, desc: '', btnOkOnPress: () async {
              try{
                LoadingDialog.showLoadingDialog(context, Texts.savingData);
                String empresaID = await  UserPreferences().getEmpresaId();
                DepartamentoController departamentoController = DepartamentoController();
                bool check = await departamentoController.checkDepartamento(_departamentoController.text.trim(), empresaID);
                LoadingDialog.hideLoadingDialog(context);
                if(check){
                  Navigator.of(context).pop(departamento);
                }else{
                  CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: Texts.errorNameDepartment,
                    btnOkOnPress: (){}, btnCancelOnPress: () {  },).showError(context);
                }
              }catch(e){
                LoadingDialog.hideLoadingDialog(context);
                ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
                String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
                CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: error, btnOkOnPress: (){},
                    btnCancelOnPress: () {  },).showError(context);
              }
            }, btnCancelOnPress: (){}).showQuestion(context);
      }else{
        CustomSnackBar.showInfoSnackBar(context, 'Agregue por lo menos un puesto para continuar');
      }
    }else{
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
}