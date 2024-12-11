import 'dart:async';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/colorController.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/color.dart';
import 'package:tickets/pages/Settings/GeneralSettings/widgets_settings.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../controllers/ComprasController/MaterialesControllers/familia_controller.dart';
import '../../../controllers/ComprasController/SubFamiliaController/subFamiliaController.dart';
import '../../../models/ComprasModels/MaterialesModels/familia_model.dart';
import '../../../models/ComprasModels/MaterialesModels/sub_familia_model.dart';
import '../../../models/ConfigModels/GeneralSettingsModels/unidad.dart';
import '../../../shared/utils/color_palette.dart';
import '../../../shared/utils/icon_library.dart';
import '../../../shared/widgets/Fiscal/textFieldClaveSat.dart';
import '../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../shared/widgets/appBar/my_appBar.dart';
import '../../../shared/widgets/buttons/dropdown_decoration.dart';
import '../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../shared/widgets/error/customNoData.dart';

class InventorySettingsScreen extends StatefulWidget {
  ThemeData theme;
  Size size;
  InventorySettingsScreen({super.key, required this.theme, required this.size});

  @override
  _InventorySettingsScreenState createState() => _InventorySettingsScreenState();
}
class _InventorySettingsScreenState extends State<InventorySettingsScreen> with TickerProviderStateMixin{
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ThemeData theme;
  late Size size;
  bool _isLoading = true;
  List<FamiliaModel> listFamilia = []; List<ColorModels> listColores = [];

  Map<String, AnimationController> _animationControllers = {};
  ScrollController scrollController =  ScrollController(), controllerFamilia = ScrollController(), controllerUnidad =  ScrollController(),
                   controllerAlmacen = ScrollController();
  TextEditingController famTextController =     TextEditingController(), subFamiliaTextController =   TextEditingController(),
                        descFamiliaController = TextEditingController(), descSubFamilyController= TextEditingController();
  TextEditingController claveSatController = TextEditingController();
  SubFamiliaController subFamiliaController = SubFamiliaController();
  FamiliaController familiaController = FamiliaController();

  late Timer timer;
  late WidgetsSettings ws;
  UserPreferences userPreferences = UserPreferences();
  late String selectedStatus;
  final List<String> statuses = ['Inactivo','Activo','Bloqueado','Fuera de línea'];
  Map<int, String> estatusTextos = {
    0: "Inactivo", 1: "Activo",
    2: "Bloqueado", 3: "Fuera de línea"
  };
  Map<int, Color> estatusColores = {
    0: Colors.red, 1: Colors.green,
    2: Colors.orange, 3: const Color.fromARGB(255, 235, 92, 10),
  };

  Map<String, AnimationController> animationControllers = {};
  @override
  void initState() {
    selectedStatus = statuses[0];
    theme = widget.theme;
    size = widget.size;
    ws = WidgetsSettings(theme);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFamilias();
      getColores();
    });
    const timeLimit = Duration(seconds: 10);
    timer = Timer(timeLimit, () {
      if(listFamilia.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
        _isLoading = false;
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return inventarioForm();
  }

  Widget inventarioForm(){
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3,
                  child: ws.myContainer2("     Familias y subFamilias",familias(),null,
                  Tooltip(message: Texts.gsFamilyAdd, waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(onTap: (){
                        FamiliaModel familia = FamiliaModel(nombre: '', descripcion: '',
                            iDFamilia: '', estatus: 1, subFamilia: []);

                        famTextController.text = '';descFamiliaController.text = '';
                        familiaDialog(familia);
                      },
                        child: Container(
                          decoration: BoxDecoration(color: theme.colorScheme.secondary,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),),
                          padding: const EdgeInsets.all(10.0),
                          child: const Icon(IconLibrary.iconAdd, size: 20,),
                        ))))),
              const SizedBox(width: 10,),
              Expanded(flex: 3,child: ws.myContainer2("   Almacenes",almacenes(),null,
                  Tooltip(message: Texts.gsStoreAdd, waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(onTap: (){},
                        child: Container(
                          decoration: BoxDecoration(color: theme.colorScheme.secondary,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),),
                          padding: const EdgeInsets.all(10.0),
                          child: const Icon(IconLibrary.iconAdd, size: 20,),
                        ),))),),
            ],
          ),
          const SizedBox(height: 10,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3,child: ws.myContainer2("Colores",colores(),null,
                  Tooltip(message: Texts.gsColorAdd, waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(onTap: (){},
                        child: Container(
                          decoration: BoxDecoration(color: theme.colorScheme.secondary,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),),
                          padding: const EdgeInsets.all(10.0),
                          child: const Icon(IconLibrary.iconAdd, size: 20,),
                        ),))),),
              const SizedBox(width: 10,),
              const Expanded(flex: 4,child: SizedBox()),
            ],
          ),
        ],),));
  }
  Widget colores(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SizedBox(height: 5),
      Container(height: 160,decoration: BoxDecoration(color: theme.colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(height: 158,child: futureListColores(),)
            ]),
      )
    ]);
  }

  Widget futureListColores(){
    return FutureBuilder<List<ColorModels>>(future: getDatosColores(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ws.buildLoadingIndicator(10, size));
          } else {
            final listSnapshot = snapshot.data ?? [];
            if (listSnapshot.isNotEmpty) {
              return Scrollbar(controller: controllerUnidad, thumbVisibility: true,
                  child: RefreshIndicator(
                      onRefresh: () async {getColores();},
                      child: FadingEdgeScrollView.fromScrollView(
                        gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: controllerUnidad, itemCount: listColores.length,
                          itemBuilder: (context, index) {
                            return cardScaleColores(listColores[index]);
                          },
                        ),
                      )
                  ));
            } else {
              if (_isLoading) {
                return Center(child: ws.buildLoadingIndicator(10, size));
              } else {
                return SingleChildScrollView(child: Center(child: NoDataWidget()));
              }
            }
          }
        });
  }
  Widget cardScaleColores(ColorModels color){
    final controller = _animationControllers[color.colorID];
    final scaleAnimation = controller != null ? Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)) : const AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: cardColor(color));
        });
  }

  Widget cardColor(ColorModels color){
    return MySwipeTileCard(horizontalPadding: 3, verticalPadding: 2, radius: 6, colorBasico: theme.colorScheme.background,
        containerRL: color.estatus == true? null: Row(children: [
          Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
        ],),
        colorRL: color.estatus == true? null : ColorPalette.ok,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 10,
            vertical: 2),child: Row(children: [
          Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
            ws.filaEspecial("Nombre", color.nombre),
            ws.filaEspecialWidget(
                Container(width: 40, height: 15, decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                    color: Color(int.parse(color.hexadecimal!.replaceFirst('#', '0xff')))),
            ), "${color.hexadecimal}", width: 110),
            ws.filaEspecial("Estatus", color.estatus==true? "Activo" : "Inactivo",
                color: color.estatus == true? ColorPalette.ok : ColorPalette.accentColor, width: 100),
          ],),)
        ],),),
        onTapLR: (){
          //unidadController.text = unidad.nombre;
          //abreviaturaUController.text = unidad.abreviatura!;
          //unidadEditDialog(unidad);
        }, onTapRL: (){
          if(color.estatus!){
            //eliminarUnidad(unidad);
          }else{
            //reactivarUnidad(unidad);
          }
        });
  }
  void _triggerCardAnimationUnidad(UnidadModels unidad) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Guardar el controlador de la animación
    _animationControllers[unidad.idUnidad!] = controller;
    // Iniciar la animación
    Future.delayed(const Duration(milliseconds: 1600), () {
      controller.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.reverse();
      });
    });
  }
  Future<List<ColorModels>> getDatosColores() async {
    try {
      return listColores;
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }
  void familiaDialog(FamiliaModel familia){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsFamilyAdd, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: Form(key: formKey,child: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                textFieldFamiliaNombre(null),
                                const SizedBox(width: 10,),
                                textFieldFamiliaDescripcion()
                              ]),
                              const SizedBox(height: 5,),
                              MyTextFieldClaveSat(
                                  theme: theme, inputColor: theme.colorScheme.onPrimary,
                                  colorBorder: theme.primaryColor, controller: claveSatController
                              ),
                              const SizedBox(height: 5,),
                              myContainerSubFamilia(familia.subFamilia!, 500, setState1, false),
                              const SizedBox(height: 5,),
                              Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                ws.buttonCancelar(() {
                                  Navigator.of(context1).pop();
                                  famTextController.text = '';
                                  descFamiliaController.text = '';
                                }),
                                const SizedBox(width: 10,),
                                ws.buttonAceptar(() async {
                                  if(formKey.currentState!.validate()){
                                    if(familia.subFamilia!.isNotEmpty){
                                      LoadingDialog.showLoadingDialog(context1, Texts.gsFamilySaving);
                                      familia.nombre = famTextController.text;
                                      familia.descripcion = descFamiliaController.text.isNotEmpty? descFamiliaController.text : '';
                                      String userID = await userPreferences.getUsuarioID();
                                      FamiliaController famController = FamiliaController();
                                      FamiliaModel? post = await famController.saveFamilia(familia, userID);
                                      await Future.delayed(Duration(milliseconds: 500),(){
                                        LoadingDialog.hideLoadingDialog(context1);
                                      });
                                      if(post != null){
                                        CustomAwesomeDialog(title: Texts.gsFamilyAddSuccess, desc: '',
                                          btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
                                        Future.delayed(Duration(milliseconds: 2500), () {
                                          Navigator.of(context1).pop();
                                          famTextController.text = '';
                                          descFamiliaController.text = '';
                                          listFamilia.add(post);
                                          _triggerCardAnimationFamilia(post);
                                          setState(() {});
                                          Future.delayed(const Duration(milliseconds: 800), () {
                                            if (controllerFamilia.hasClients) {
                                              final position = controllerFamilia.position.maxScrollExtent;
                                              controllerFamilia.animateTo(
                                                position, duration: const Duration(seconds: 1), curve: Curves.easeOut,
                                              );
                                            }
                                          });
                                        });
                                      }
                                    }else{
                                      MyCherryToast.showWarningSnackBar(context1, theme, Texts.gsSubFamilyAddToContinue);
                                    }
                                  }else{
                                    MyCherryToast.showWarningSnackBar(context1, theme, Texts.completeFields);
                                  }
                                })
                              ]),
                            ],
                          ),)
                        ))
                ));
              }
          );
        });
  }
  Widget textFieldFamiliaNombre(String? exception){
    return ws.boxWithTextField('Nombre', famTextController, Icons.family_restroom_rounded,
        validator: (String? value){
          if(value == null || value.isEmpty){
            return Texts.completeField;
          }else if(exception != null && value == exception){
            return null;
          }else if(listFamilia.any((element) => element.nombre == value)){
            return 'Ya existe una familia con este \nnombre';
          }else if(value.length > 20){
            return 'El nombre no puede tener más \nde 20 caracteres';
          }
          return null;
        }, width: 245);
  }
  Widget textFieldFamiliaDescripcion(){
    return ws.boxWithTextField('Descripción', descFamiliaController, Icons.auto_stories_rounded,
        validator: (String? value){
          if(value == null || value.isEmpty){
            return null;
          }else if(value.length > 50){
            return 'La descripción no puede tener \nmás de 50 caracteres';
          }
          return null;
        }, width: 245);
  }
  Widget myContainerSubFamilia(List<SubFamiliaModel> listSubFamilia, double width, StateSetter setState1, bool edit){
    return Container(width: width,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor), padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            const SizedBox(),
            const Text("SubFamilias", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,),),
            IconButton(onPressed: (){
              subFamiliaDialog(listSubFamilia, setState1, edit);
            }, icon: const Icon(IconLibrary.iconAdd),
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
          SizedBox(height: size.height-373,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController, itemCount: listSubFamilia.length,
                itemBuilder: (context, index){
                  return cardSubFamilia(listSubFamilia[index], edit, setState1, listSubFamilia);
                },
              ),
            ),)
        ])
    );
  }
  void subFamiliaDialog(List<SubFamiliaModel> listSubFamilia, StateSetter setState2, bool edit, {String idFamilia = ''}){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsSubFamilyAdd, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                ws.boxWithTextField('Nombre', subFamiliaTextController, Icons.family_restroom_rounded),
                                const SizedBox(width: 10,),
                                ws.boxWithTextField('Descripción', descSubFamilyController,  Icons.auto_stories_rounded, validator: (String? value){return null;})
                              ]),
                              const SizedBox(height: 10,),
                              Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                ws.buttonCancelar(() {
                                  Navigator.of(context1).pop();
                                  subFamiliaTextController.text = '';
                                  descSubFamilyController.text = '';
                                }),
                                const SizedBox(width: 10,),
                                ws.buttonAceptar(() async {
                                  if(subFamiliaTextController.text.isNotEmpty){
                                    if(edit){
                                      subFamiliaAdd(context1, idFamilia, setState2, listSubFamilia);
                                    }else{
                                      SubFamiliaModel subFamilia = SubFamiliaModel(nombre: subFamiliaTextController.text,
                                          descripcion: descSubFamilyController.text, iDSubFamilia: '', estatus: 1);
                                      listSubFamilia.add(subFamilia);
                                      setState2(() {});
                                      Navigator.of(context1).pop();
                                      subFamiliaTextController.text = '';
                                      descSubFamilyController.text = '';
                                    }
                                  }else{
                                    MyCherryToast.showWarningSnackBar(context1, theme, Texts.completeField);
                                  }
                                })
                              ]),
                            ],
                          ),
                        ))
                ));
              }
          );
        });
  }
  Future<void> subFamiliaAdd(BuildContext context1, String idFamilia, StateSetter setState2, List<SubFamiliaModel> listSubFamilia) async {
    LoadingDialog.showLoadingDialog(context1, Texts.gsSubFamilySaving);
    String userID = await userPreferences.getUsuarioID();
    SubFamiliaModel? subFamiliaModel = await subFamiliaController.saveSubFamilia(
        SubFamiliaModel(iDSubFamilia: '', nombre: subFamiliaTextController.text,
            descripcion: descSubFamilyController.text, familiaId: idFamilia), userID);
    if(subFamiliaModel != null) {
      CustomAwesomeDialog(title: Texts.gsSubFamilyAddSuccess, desc: '',
        btnOkOnPress: () {}, btnCancelOnPress: () {},).showSuccess(context);
      await Future.delayed(Duration(milliseconds: 2500), () {
        Navigator.of(context1).pop();
        LoadingDialog.hideLoadingDialog(context1);
      });

      listSubFamilia.add(subFamiliaModel);
      setState2(() {});

      subFamiliaTextController.text = '';
      descSubFamilyController.text = '';
    }else{
      CustomAwesomeDialog(title: Texts.gsFamilyErrorAdd, desc: '',
        btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context1);},
        btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context1);},).showError(context);
    }
  }
  Future<void> subFamiliaEditDialog(SubFamiliaModel subFamiliaModel, bool edit, StateSetter setState) async {
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsSubFamilyEdit, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                ws.boxWithTextField('Nombre', subFamiliaTextController, Icons.family_restroom_rounded),
                                const SizedBox(width: 10,),
                                ws.boxWithTextField('Descripción', descSubFamilyController,  Icons.auto_stories_rounded, validator: (String? value){return null;})
                              ]),
                              const SizedBox(height: 10,),
                              Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                ws.buttonCancelar(() {
                                  Navigator.of(context1).pop();
                                  Future.delayed(const Duration(milliseconds: 100),(){
                                    subFamiliaTextController.text = '';
                                    descSubFamilyController.text = '';
                                  });
                                }),
                                const SizedBox(width: 10,),
                                ws.buttonAceptar(() async {
                                  if(subFamiliaTextController.text.isNotEmpty){
                                    if(edit){
                                      subFamiliaEdit(subFamiliaModel, context1, setState);
                                    }else{
                                      subFamiliaModel.nombre = subFamiliaTextController.text;
                                      subFamiliaModel.descripcion = descSubFamilyController.text;
                                      setState((){});
                                      Navigator.of(context1).pop();
                                    }
                                  }else{
                                    MyCherryToast.showWarningSnackBar(context1, theme, Texts.completeField);
                                  }
                                })
                              ]),
                            ],
                          ),
                        ))
                ));
              }
          );
        });
  }

  Future<void> subFamiliaEdit(SubFamiliaModel subFamiliaModel, BuildContext context1, StateSetter setState1) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsSubFamilySaving);
    String userID = await userPreferences.getUsuarioID();
    bool put = await subFamiliaController.updateSubFamilia(SubFamiliaModel(iDSubFamilia: subFamiliaModel.iDSubFamilia,
        nombre: subFamiliaTextController.text, descripcion: descSubFamilyController.text), userID);
    if(put){
      CustomAwesomeDialog(title: Texts.gsSubFamilyEditSuccess, desc: '',
        btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
      Future.delayed(const Duration(milliseconds: 2500), () {
        Navigator.of(context1).pop();
        LoadingDialog.hideLoadingDialog(context);
        subFamiliaModel.nombre = subFamiliaTextController.text;
        subFamiliaModel.descripcion = descSubFamilyController.text;
        setState1(() {});

        subFamiliaTextController.text = '';
        descSubFamilyController.text = '';
      });
    }else{
      CustomAwesomeDialog(title: Texts.gsFamilyErrorEdit, desc: '',
        btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
        btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context);
    }
  }
  void familiaEditDialog(FamiliaModel familiaModel){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsFamilyEdit, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                textFieldFamiliaNombre(familiaModel.nombre),
                                const SizedBox(width: 10,),
                                textFieldFamiliaDescripcion()
                              ]),
                              const SizedBox(height: 10,),
                              Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                ws.buttonCancelar(() {
                                  Navigator.of(context1).pop();
                                  Future.delayed(const Duration(milliseconds: 100),(){
                                    famTextController.text = '';descFamiliaController.text = '';
                                  });
                                }),
                                const SizedBox(width: 10,),
                                ws.buttonAceptar(() async {
                                  if(famTextController.text.isNotEmpty){
                                    LoadingDialog.showLoadingDialog(context, Texts.gsFamilySaving);
                                    FamiliaModel fam = familiaModel;
                                    fam.nombre = famTextController.text;
                                    fam.descripcion = descFamiliaController.text;
                                    String userID = await userPreferences.getUsuarioID();
                                    bool put = await familiaController.updateFamilia(fam, userID);
                                    if(put){
                                      CustomAwesomeDialog(title: Texts.gsFamilyEditSuccess, desc: '',
                                        btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
                                      Future.delayed(const Duration(milliseconds: 2500), () {
                                        Navigator.of(context1).pop();
                                        LoadingDialog.hideLoadingDialog(context);
                                        familiaModel.nombre = fam.nombre;
                                        familiaModel.descripcion = fam.descripcion;
                                        setState(() {});

                                        famTextController.text = '';
                                        descFamiliaController.text = '';
                                      });
                                    }else{
                                      CustomAwesomeDialog(title: Texts.gsFamilyErrorEdit, desc: '',
                                        btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
                                        btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context);
                                    }
                                  }else{
                                    MyCherryToast.showWarningSnackBar(context1, theme, Texts.completeField);
                                  }
                                })
                              ]),
                            ],
                          ),
                        ))
                ));
              }
          );
        });
  }
  Widget cardSubFamilia(SubFamiliaModel subFamilia, bool edit, StateSetter setState1, List<SubFamiliaModel> listSubfamilia){
    return MySwipeTileCard(horizontalPadding: 0, verticalPadding: 2, radius: 6, colorBasico: theme.colorScheme.background,
        containerRL: !edit? null: Row(children: [
          Icon(IconLibrary.iconArrows, color: theme.colorScheme.onPrimary,)
        ],), colorRL: !edit? null :  ColorPalette.accentColor,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 5,
            vertical: 5),child: Row(children: [
          Expanded(child: Wrap(alignment: WrapAlignment.start,spacing: 5,runSpacing: 2,children: [
            ws.filaEspecial("Familia", subFamilia.nombre, width: 130),
            ws.filaEspecial("Descripción", subFamilia.descripcion?? "",width: !edit? 315 : 205),
            if(edit)...[
              ws.filaEspecial("Estatus", estatusTextos[subFamilia.estatus]!, width: 115,
                  color: estatusColores[subFamilia.estatus]),
            ]
          ],),)
        ],),),
        onTapLR: (){
            CustomAwesomeDialog(title: Texts.gsSubFamilyWannaEdit, desc: 'SubFamilia: ${subFamilia.nombre}',
                btnOkOnPress: () {
                  subFamiliaTextController.text = subFamilia.nombre;
                  descSubFamilyController.text = subFamilia.descripcion?? '';

                  subFamiliaEditDialog(subFamilia, edit, setState1);
                }, btnCancelOnPress: () { },).showQuestion(context);
        }, onTapRL: (){
          if(edit){
            selectedStatus = estatusTextos[subFamilia.estatus]!;
            changeStatusDialogSubFamilia(subFamilia, setState1);
          }else{
            CustomAwesomeDialog(title: Texts.gsSubFamilyWannaDelete, desc: 'SubFamilia: ${subFamilia.nombre}',
              btnOkOnPress: () {
                listSubfamilia.remove(subFamilia);
                setState1(() {});
              }, btnCancelOnPress: () { },).showQuestion(context);
          }
        });
  }
  Widget familias(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Container(height: 160,decoration: BoxDecoration(color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,children: [
            SizedBox(height: 157,child: futureListFamilias(),)
          ],),
      )
    ],);
  }
  Widget futureListFamilias(){
    return FutureBuilder<List<FamiliaModel>>(future: getDatosFamilias(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ws.buildLoadingIndicator(10,size));
          } else {
            final listSnapshot = snapshot.data ?? [];
            if (listSnapshot.isNotEmpty) {
              return RefreshIndicator(onRefresh: getFamilias, color: theme.colorScheme.onPrimary,
                  child: Scrollbar(controller: controllerFamilia, thumbVisibility: true,
                  child: FadingEdgeScrollView.fromScrollView(
                    gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controllerFamilia, itemCount: listFamilia.length,
                      itemBuilder: (context, index) {
                        return cardScaleFamilia(listFamilia[index]);
                      },
                    ),
                  )));
            } else {
              if (_isLoading) {
                return Center(child: ws.buildLoadingIndicator(10,size));
              } else {
                return SingleChildScrollView(
                  child: Center(child: NoDataWidget()),
                );
              }
            }
          }
        });
  }

  Widget cardFamilia(FamiliaModel familia){
    return GestureDetector(child: MySwipeTileCard(
      horizontalPadding: 3, verticalPadding: 1.5, radius: 8, colorBasico: theme.colorScheme.background,
      containerRL: Row(children: [
        Icon(IconLibrary.iconArrows, color: theme.colorScheme.onPrimary,)
      ],), colorRL: ColorPalette.accentColor,
      containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 5,
          vertical: 2),child: Tooltip(message: "Descripción: ${familia.descripcion}", waitDuration: const Duration(milliseconds: 500),
          child: Row(children: [
            Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
              ws.filaEspecial("Familia", familia.nombre, width: 110),
              ws.filaEspecial("Descripción", familia.descripcion,width: 215),
              ws.filaEspecial("Estatus", estatusTextos[familia.estatus].toString(), width: 115,
                color: estatusColores[familia.estatus], textOverflow: null),
            ],),)
          ],))
    ), onTapLR: (){
      CustomAwesomeDialog(title: Texts.gsFamilyWannaEdit, desc: 'Familia: ${familia.nombre}',
        btnOkOnPress: () {
          famTextController.text = familia.nombre;
          descFamiliaController.text = familia.descripcion?? '';
          familiaEditDialog(familia);
        }, btnCancelOnPress:(){},).showQuestion(context);
    }, onTapRL: (){
        selectedStatus = estatusTextos[familia.estatus]!;
        changeStatusDialog(familia);
    }),
      onDoubleTap: () async {
        descFamiliaController.text = familia.descripcion;
        famTextController.text = familia.nombre;
        await subFamiliasEditDialog(familia);
      },);
  }
  Future<void> subFamiliasEditDialog(FamiliaModel familia) async {
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: MyCustomAppBarDesktop(padding: 10.0,height: 45, title: Texts.gsSubFamilysEdit,
                              suffixWidget: null, textColor: theme.colorScheme.onPrimary,
                              context: context, backButton: true, defaultButtons: false,
                              borderRadius: const BorderRadius.all(Radius.circular(25))
                          ),
                          content: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                ws.boxWithTextField('Nombre', famTextController, Icons.family_restroom_rounded, enable: false),
                                const SizedBox(width: 10,),
                                ws.boxWithTextField('Descripción', descFamiliaController,  Icons.auto_stories_rounded, enable: false)
                              ]),
                              const SizedBox(height: 10,),
                              myContainerSubFamilia(familia.subFamilia!, 500, setState1, true),
                              const SizedBox(height: 10,),
                            ],
                          ),
                        ))
                ));
              }
          );
        });
  }

  Future<List<FamiliaModel>> getDatosFamilias() async {
    try {
      return listFamilia;
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }

  Future<void> getFamilias() async {
    try{
      FamiliaController familiaController = FamiliaController();
      List<FamiliaModel> familiaList = await familiaController.getFamiliaComplete();
      if(familiaList.isNotEmpty){
        listFamilia = familiaList;
        setState(() {});
      }
    }catch (e){
      print('Error al obtener monedas: $e');
    }
  }
  Future<void> getColores() async {
    try{
      ColorController colorController = ColorController();
      List<ColorModels> colorList = await colorController.getColor();
      if(colorList.isNotEmpty){
        listColores = colorList;
        setState(() {});
      }
    }catch (e){
      print('Error al obtener monedas: $e');
    }
  }
  Widget almacenes(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Container(height: 160,decoration: BoxDecoration(color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,children: [
            SizedBox(height: 158,child: futureListAlmacenes(),)
          ],),
      )
    ],);
  }

  Widget futureListAlmacenes(){
    return FutureBuilder<List<FamiliaModel>>(future: getDatosFamilias(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ws.buildLoadingIndicator(10,size));
          } else {
            final listSnapshot = snapshot.data ?? [];
            if (listSnapshot.isNotEmpty) {
              return RefreshIndicator(onRefresh: getFamilias, color: theme.colorScheme.onPrimary,
                  child: Scrollbar(controller: controllerAlmacen, thumbVisibility: true,
                      child: FadingEdgeScrollView.fromScrollView(
                        gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: controllerAlmacen, itemCount: listFamilia.length,
                          itemBuilder: (context, index) {
                            return cardAlmacen();
                          },
                        ),
                      )));
            } else {
              if (_isLoading) {
                return Center(child: ws.buildLoadingIndicator(10,size));
              } else {
                return SingleChildScrollView(
                  child: Center(child: NoDataWidget()),
                );
              }
            }
          }
        });
  }

  Widget cardAlmacen(){
    return GestureDetector(child: Container(decoration: BoxDecoration(color: theme.colorScheme.background,
      borderRadius: const BorderRadius.all(Radius.circular(8)),),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9.1),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
        child: Tooltip(message: "Descripción: GAMMA #203", waitDuration: const Duration(milliseconds: 500),
            child: Row(children: [
              Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
                ws.filaEspecial("Almacen", 'Gamma', width: 120),
                ws.filaEspecial("Descripción", 'GAMMA #203',width: 215),
                ws.filaEspecial("Estatus", true != null? (true == 1? "Activo" : "Inactivo") : "Inactivo",
                    width: 105, color: true == false? ColorPalette.ok : ColorPalette.accentColor),
              ],),)
            ],))),
      onDoubleTap: (){

      },);
  }
  void changeStatusDialog(FamiliaModel familiaModel){
    showDialog(context: context, barrierDismissible: false,
    builder:(BuildContext context1){
      return StatefulBuilder(builder: (BuildContext context1, StateSetter setState1) {
        return ScaffoldMessenger(child: Builder(
            builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
          body: AlertDialog(
            title: Text(Texts.gsChangeStatus, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            content: MyDropdown(dropdownItems: statuses,
                suffixIcon: const Icon(IconLibrary.sellIcon),
                textStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onPrimary),
                selectedItem: selectedStatus, onPressed: (value){
                  if(value!=selectedStatus){
                    selectedStatus = value!;
                    setState1(() {});
                  }
                }),
            actions: <Widget>[
              ws.buttonCancelar(() {
                Navigator.of(context1).pop();
              }),
              ws.buttonAceptar((){
                CustomAwesomeDialog(title: Texts.gsChangeStatusWanna, desc: 'Familia: ${familiaModel.nombre}',
                  btnOkOnPress: () async {
                  cambiarEstatusFamilia(familiaModel, context1);
              }, btnCancelOnPress: () {  },).showQuestion(context);
              })
            ],
          ),)));
      }
      );
    });
  }
  void changeStatusDialogSubFamilia(SubFamiliaModel subFamiliaModel, StateSetter setState){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(builder: (BuildContext context1, StateSetter setState1) {
            return ScaffoldMessenger(child: Builder(
                builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                  body: AlertDialog(
                    title: Text(Texts.gsChangeStatus, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                    content: MyDropdown(dropdownItems: statuses,
                        suffixIcon: const Icon(IconLibrary.sellIcon),
                        textStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onPrimary),
                        selectedItem: selectedStatus, onPressed: (value){
                          if(value!=selectedStatus){
                            selectedStatus = value!;
                            setState1(() {});
                          }
                        }),
                    actions: <Widget>[
                      ws.buttonCancelar(() {
                        Navigator.of(context1).pop();
                      }),
                      ws.buttonAceptar((){
                        CustomAwesomeDialog(title: Texts.gsChangeStatusWanna, desc: 'SubFamilia: ${subFamiliaModel.nombre}',
                          btnOkOnPress: () async {
                            cambiarEstatusSubFamilia(subFamiliaModel, context1, setState);
                          }, btnCancelOnPress: () {  },).showQuestion(context);
                      })
                    ],
                  ),)));
          }
          );
        });
  }
  Future<void> cambiarEstatusFamilia(FamiliaModel familiaModel, BuildContext context1) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsChangeStatusLoading);
    String userID = await userPreferences.getUsuarioID();
    bool put = await familiaController.updateStatusFamilia(FamiliaModel(iDFamilia: familiaModel.iDFamilia,
        nombre: '', estatus: estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedStatus)), userID);
    if(put){
      CustomAwesomeDialog(title: Texts.gsChangeStatusSuccess, desc: '',
        btnOkOnPress:(){}, btnCancelOnPress:(){},).showSuccess(context);
      Future.delayed(const Duration(milliseconds: 2500), () {
        familiaModel.estatus = estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedStatus);
        Navigator.of(context1).pop();
        LoadingDialog.hideLoadingDialog(context);
        setState(() {});
      });
    }else{
      CustomAwesomeDialog(title: Texts.gsChangeStatusError, desc: '',
        btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
        btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context);
    }
  }
  Future<void> cambiarEstatusSubFamilia(SubFamiliaModel subFamiliaModel, BuildContext context1, StateSetter setState1) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsChangeStatusLoading);
    String userID = await userPreferences.getUsuarioID();
    bool put = await subFamiliaController.changeStatusSubFamilia(SubFamiliaModel(iDSubFamilia: subFamiliaModel.iDSubFamilia,
        nombre: '', estatus: estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedStatus)), userID);
    if(put){
      CustomAwesomeDialog(title: Texts.gsChangeStatusSuccess, desc: '',
        btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
      Future.delayed(const Duration(milliseconds: 2500), () {
        subFamiliaModel.estatus = estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedStatus);
        Navigator.of(context1).pop();
        LoadingDialog.hideLoadingDialog(context);
        setState1(() {});
      });
    }else{
      CustomAwesomeDialog(title: Texts.gsChangeStatusError, desc: '',
        btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
        btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context);
    }
  }
  Widget cardScaleFamilia(FamiliaModel familiaModel){
    final controller = animationControllers[familiaModel.iDFamilia];
    final scaleAnimation = controller != null ? Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)) : const AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: cardFamilia(familiaModel));
        });
  }

  void _triggerCardAnimationFamilia(FamiliaModel familiaModel) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400), vsync: this,
    );
    animationControllers[familiaModel.iDFamilia] = controller;
    Future.delayed(const Duration(milliseconds: 1600), () {
      controller.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.reverse();
      });
    });
  }
}