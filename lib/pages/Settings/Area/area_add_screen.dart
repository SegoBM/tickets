import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/areaController.dart';
import 'package:tickets/models/ConfigModels/area.dart';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/pages/Settings/Area/department/department_add_screen.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../../controllers/ConfigControllers/departamentoController.dart';
import '../../../shared/actions/my_show_dialog.dart';
import '../../../shared/utils/icon_library.dart';
import '../../../shared/utils/texts.dart';
import '../../../shared/utils/user_preferences.dart';
import '../../../shared/widgets/dialogs/customAlertDialog.dart';
import '../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class AreaAddScreen extends StatefulWidget {
  @override
  _AreaAddScreenState createState() => _AreaAddScreenState();
}

class _AreaAddScreenState extends State<AreaAddScreen> {
  final _formKey = GlobalKey<FormState>(); final GlobalKey _areaAddKey = GlobalKey();
  final _areaController = TextEditingController();
  final List<DepartamentoModels> _departments = [];
  final _departmentController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late Size size; late ThemeData theme;
  AreaController areaController = AreaController();
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return PressedKeyListener( keyActions: {
      LogicalKeyboardKey.escape: () {
        CustomAwesomeDialog( title: Texts.alertExit, desc: Texts.lostData,
            btnOkOnPress: (){ Navigator.of(context).pop(); }, btnCancelOnPress: (){}).showQuestion(context);
      },
      LogicalKeyboardKey.f4: () {_save();},
      LogicalKeyboardKey.f1: () {_addDepartment();},
    }, Gkey: _areaAddKey,
    child: Scaffold(
      appBar: size.width > 600? MyCustomAppBarDesktop(padding: 10.0,title:"Alta de area", height: 45,
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
          context: context, backButton: true, defaultButtons: false,
          borderRadius: const BorderRadius.all(Radius.circular(25))
      ) : null,
      body: Form(key: _formKey,
          child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: <Widget>[
                SizedBox(width: size.width*0.40,child: MyTextfieldIcon(labelText: "Area", toUpperCase: true,
                    textController: _areaController, backgroundColor: theme.colorScheme.background,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Texts.completeField;
                      }else if(value.length > 20){
                        return 'El nombre del area debe tener menos de 20 caracteres';
                      }
                      return null;
                    }),),
                const SizedBox(height: 10),
                _myContainerPermisos('Departamentos',_departments,size.width),
              ],
            ),
          ),)
      ),
    ));
  }

  Widget _myContainerPermisos(String text,List<DepartamentoModels> departamentos,double width){
    return Container(width: width,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor),
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            const SizedBox(),
            Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),),
            IconButton(onPressed: (){_addDepartment();}, icon: const Icon(IconLibrary.iconAdd),
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
              child: ListView.builder(controller: scrollController,
                itemCount: departamentos.length,
                itemBuilder: (context, index){
                  return _departmentWidget(departamentos[index]);
                },
              ),
            ),)
        ],)
    );
  }
  Future<void> _addDepartment() async {
    final GlobalKey<State> dialogKey = GlobalKey<State>();
    DepartamentoModels? departamento = await myShowDialog(DepartamentoAddScreen(), context, size.width*0.40, dialogKey);
    if(departamento != null){
      print(departamento.nombre);
      _departments.add(departamento);
      setState(() {});
    }
  }
  Widget _departmentWidget(DepartamentoModels departamentoModels){
    return MySwipeTileCard(horizontalPadding: 0,
        colorBasico: theme.colorScheme.background,containerB: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
          SizedBox(width: size.width*.35, child: Text(departamentoModels.nombre, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),),)
        ],),), onTapLR: (){editDepartment(departamentoModels);},
        onTapRL: (){deleteDepartment(departamentoModels);});
  }
  void editDepartment(DepartamentoModels departamento){
    _departmentController.text = departamento.nombre;
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context2){
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState)
          {return ScaffoldMessenger(child: Builder(
              builder: (context) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: alertDialogEditDepartment(context, departamento)
              )
          ));}
      );
    });
  }
  void deleteDepartment(DepartamentoModels departamento){
    CustomAwesomeDialog(title: Texts.askDeleteConfirm,
        desc: 'Departamento: ${departamento.nombre}', btnOkOnPress: (){
        _departments.remove(departamento);
        setState(() {});
      }, btnCancelOnPress: (){}).showQuestion(context);
  }
  Widget alertDialogAddDepartment(BuildContext context){
    return CustomAlertDialog(title: "Agregar Departamento",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Departamento", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,), toUpperCase: true,
                textController: _departmentController,
                suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: (){
        if(_departmentController.text.isNotEmpty){
          print(_departmentController.text);
          print(_departments.length);
          setState(() {});
          _departmentController.text = "";
          Navigator.of(context).pop();
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }
  Widget alertDialogEditDepartment(BuildContext context, DepartamentoModels departamento){
    return CustomAlertDialog(title: "Editar Departamento",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Departamento", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,), toUpperCase: true,
                textController: _departmentController,
                suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: () async {
        if(_departmentController.text.isNotEmpty){
          if(_departmentController.text.length > 50){
            CustomSnackBar.showInfoSnackBar(context, 'El nombre del departamento debe tener menos de 50 caracteres');
          }else{
            try{
              LoadingDialog.showLoadingDialog(context, Texts.savingData);
              String empresaID = await  UserPreferences().getEmpresaId();
              DepartamentoController departamentoController = DepartamentoController();
              bool check = await departamentoController.checkDepartamento(_departmentController.text.trim(), empresaID);
              LoadingDialog.hideLoadingDialog(context);
              if(check){
                departamento.nombre = _departmentController.text;
                setState(() {});
                _departmentController.text = "";
                Navigator.of(context).pop();
              }else{
                CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: Texts.errorNameDepartment,
                  btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
              }
            }catch(e){
              ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
              String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
              CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: error,
                btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
            }
          }
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }
  void _save(){
    if (_formKey.currentState!.validate()) {
      if(_departments.isNotEmpty){
        CustomAwesomeDialog(title: Texts.askSaveConfirm,
            desc: '', btnOkOnPress: () async {
              try{
                LoadingDialog.showLoadingDialog(context, Texts.savingData);
                String empresaID = await  UserPreferences().getEmpresaId();
                bool check = await areaController.checkArea(_areaController.text.trim(), empresaID);
                if(check){
                  AreaModels area = AreaModels(nombre: _areaController.text.trim(), departamentos: _departments);
                  bool save = await  areaController.saveArea(area, context);
                  LoadingDialog.hideLoadingDialog(context);
                  if(save) {
                    CustomAwesomeDialog(title: Texts.addSuccess, desc: '', btnOkOnPress: () {},
                      btnCancelOnPress: () {},).showSuccess(context);
                    Future.delayed(const Duration(milliseconds: 2500), () {
                      Navigator.of(context).pop();
                    });
                  }else{
                    CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: 'Error inesperado. Contacte a soporte',
                      btnOkOnPress: () {
                        Navigator.of(context).pop();
                      }, btnCancelOnPress: () {},).showError(context);
                  }
                }else{
                  LoadingDialog.hideLoadingDialog(context);
                  CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: Texts.errorNameArea,
                    btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
                }
              }catch(e){
                LoadingDialog.hideLoadingDialog(context);
                ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
                String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
                CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: error,
                  btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
              }
            }, btnCancelOnPress: (){}).showQuestion(context);
      }else{
        CustomSnackBar.showInfoSnackBar(context, 'Agregue por lo menos un departamento para continuar');
      }
    }else{
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
}