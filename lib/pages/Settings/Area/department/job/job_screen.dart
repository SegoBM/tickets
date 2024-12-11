import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import '../../../../../controllers/ConfigControllers/puestoController.dart';
import '../../../../../models/ConfigModels/puesto.dart';
import '../../../../../shared/utils/icon_library.dart';
import '../../../../../shared/utils/texts.dart';
import '../../../../../shared/widgets/dialogs/customAlertDialog.dart';
import '../../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class JobScreen extends StatefulWidget {
  DepartamentoModels departamentoModels;
  JobScreen({super.key, required this.departamentoModels});
  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final GlobalKey jobKey = GlobalKey();
  final _departamentoController = TextEditingController();
  List<PuestoModels> _puestos = [];
  final _puestoController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late Size size;
  late ThemeData theme;
  late DepartamentoModels departamento;
  @override
  void initState() {
    departamento = widget.departamentoModels;
    _departamentoController.text = departamento.nombre;
    _puestos = departamento.puestos!;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return PressedKeyListener(keyActions: {
      LogicalKeyboardKey.escape: () {
        CustomAwesomeDialog(title: Texts.alertExit, desc: Texts.lostData,
            btnOkOnPress: (){Navigator.of(context).pop();}, btnCancelOnPress: (){}).showQuestion(context);
      },
      LogicalKeyboardKey.f1: () {_addDepartment();},
    }, Gkey: jobKey,
    child: Scaffold(
      appBar: size.width > 600 ? MyCustomAppBarDesktop(padding: 10.0,
          title: "Puestos", height: 45, suffixWidget: null,
          context: context, backButton: true, defaultButtons: false,
          borderRadius: const BorderRadius.all(Radius.circular(25))
      ) : null,
      body: Form(
          child: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: <Widget>[
                SizedBox(width: size.width * 0.40,
                    child: MyTextfieldIcon(labelText: "Departamento",
                      toUpperCase: true, textController: _departamentoController,
                      backgroundColor: theme.colorScheme.background,enabled: false,)
                ),
                const SizedBox(height: 10),
                _myContainerPermisos('Puestos', _puestos, size.width),
              ],
            ),
          ),)
      ),
    ));
  }

  Widget _myContainerPermisos(String text, List<PuestoModels> puestos, double width) {
    return Container(width: width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.primaryColor),
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(),
            Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),),
            IconButton(onPressed: () {_addDepartment();},
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
          Divider(thickness: 2, color: theme.colorScheme.secondary,),
          SizedBox(height: size.height - 295,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(controller: scrollController, itemCount: puestos.length,
                itemBuilder: (context, index) {
                  return _departmentWidget(index);
                },
              ),
            ),)
        ],)
    );
  }

  void _addDepartment() {
    showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context2) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context) =>
                        PressedKeyListener(keyActions: {
                          LogicalKeyboardKey.escape: () {
                            _puestoController.text = "";
                            Navigator.of(context).pop();
                          },
                          LogicalKeyboardKey.f4: () {saveJob(context);}
                        }, Gkey: jobKey,
                        child: Scaffold(backgroundColor: Colors.transparent, body: alertDialogAddJob(context))
                        )
                ));
              }
          );
        });
  }
  Widget _departmentWidget(int index) {
    return MySwipeTileCard(horizontalPadding: 0, colorBasico: theme.colorScheme.background,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            Text(_puestos[index].nombre, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.normal,),)
          ],),),
        onTapLR: () {editPuesto(index);},
        onTapRL: () {
          if(_puestos.length > 1){
            deletePuesto(index);
          }else{
            CustomSnackBar.showWarningSnackBar(context, Texts.errorDeleteMin);
          }
        });
  }
  void editPuesto(int index) {
    _puestoController.text = _puestos[index].nombre;
    showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context2) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context) =>
                        Scaffold(backgroundColor: Colors.transparent, body: alertDialogEditJob(context, index))
                ));
              }
          );
        });
  }
  void deletePuesto(int index) {
    CustomAwesomeDialog(title: Texts.askDeleteConfirm, desc: 'Puesto: ${_puestos[index].nombre}',
        btnOkOnPress: () async {
          try{
            LoadingDialog.showLoadingDialog(context, Texts.deletingData);
            PuestoController puestoController = PuestoController();
            bool delete = await puestoController.deletePuesto(_puestos[index].idPuesto!);
            LoadingDialog.hideLoadingDialog(context);
            if(delete){
              _puestos.removeAt(index);
              CustomAwesomeDialog(title: Texts.deleteSuccess, desc: '', btnOkOnPress: () {},
                  btnCancelOnPress: () {}).showSuccess(context);
            }else{
              CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected,
                  btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
            }
            setState(() {});
          }catch(e){
            LoadingDialog.hideLoadingDialog(context);
            ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
            String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
            CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: error,
                btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
          }
        }, btnCancelOnPress: () {}).showQuestion(context);
  }
  Widget alertDialogAddJob(BuildContext context) {
    return CustomAlertDialog(title: "Agregar Puesto",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Puesto", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,), toUpperCase: true,
                textController: _puestoController, suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: () {saveJob(context);},
      onPressedCancel: () {
        _puestoController.text = "";
        Navigator.of(context).pop();
      },
    );
  }
  void saveJob(BuildContext context){
    if (_puestoController.text.isNotEmpty) {
      Navigator.of(context).pop();
      _save(_puestoController.text.trim());
    } else {
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
  Widget alertDialogEditJob(BuildContext context, int index) {
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
      onPressedOk: () async {
        if (_puestoController.text.isNotEmpty) {
          if(_puestoController.text.length > 50){
            CustomSnackBar.showWarningSnackBar(context, "El nombre del puesto debe tener menos de 50 caracteres");
          }else{
            Navigator.of(context).pop();
            _edit(index);
          }
        } else {
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }
  void _edit(int index){
    CustomAwesomeDialog(title: Texts.askEditConfirm, desc: '',
        btnOkOnPress: () async {
      try{
        LoadingDialog.hideLoadingDialog(context);
        PuestoController puestoController = PuestoController();
        PuestoModels puestoModels = PuestoModels(
          idPuesto: _puestos[index].idPuesto,
          departamentoId: departamento.idDepartamento,
          estatus: true, nombre: _puestoController.text.trim(),);
        PuestoModels? update =await puestoController.updatePuesto(puestoModels.idPuesto!,puestoModels);
        LoadingDialog.hideLoadingDialog(context);
        if(update != null) {
          _puestos[index] = update;
          setState(() {});
          CustomAwesomeDialog(title: Texts.editSuccess, desc: '', btnOkOnPress: () {},
              btnCancelOnPress: () {}).showSuccess(context);
          _puestoController.text = "";
        }else{
          CustomAwesomeDialog(title: Texts.errorEditRegistry, desc: Texts.errorUnexpected,
              btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
        }
      }catch(e){
        LoadingDialog.hideLoadingDialog(context);
        ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
        String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
        CustomAwesomeDialog(title: Texts.errorEditRegistry, desc: error, btnOkOnPress: () {},
            btnCancelOnPress: () {}).showError(context);
      }
    }, btnCancelOnPress: (){}).showQuestion(context);
  }
  void _save(String puesto) {
    CustomAwesomeDialog(title: Texts.askSaveConfirm, desc: '', btnOkOnPress: () async {
          try{
            LoadingDialog.showLoadingDialog(context, Texts.savingData);
            PuestoModels puestoModels = PuestoModels(
              departamentoId: departamento.idDepartamento,
              estatus: true,
              nombre: puesto.trim(),);
            PuestoController puestoController = PuestoController();
            PuestoModels? save = await puestoController.savePuesto(puestoModels);
            LoadingDialog.hideLoadingDialog(context);
            if(save != null){
              _puestos.add(save);
              _puestoController.text = "";
              setState(() {});
              CustomAwesomeDialog(title: Texts.addSuccess, desc: '', btnOkOnPress: () {},
                  btnCancelOnPress: () {}).showSuccess(context);
            }else{
              CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: Texts.errorUnexpected,
                  btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
            }
          }catch(e){
            LoadingDialog.hideLoadingDialog(context);
            ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
            String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
            CustomAwesomeDialog(title: Texts.errorAddRegistry, desc: error, btnOkOnPress: () {},
                btnCancelOnPress: () {}).showError(context);
          }
        }, btnCancelOnPress: () {}).showQuestion(context);
  }
}
