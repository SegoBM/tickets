import 'dart:async';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/ajustesGeneralesController.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/monedaController.dart';
import 'package:tickets/controllers/ConfigControllers/usuarioController.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/ajustesGenerales.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/monedas.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/unidad.dart';
import 'package:tickets/pages/Settings/GeneralSettings/account_settings.dart';
import 'package:tickets/pages/Settings/GeneralSettings/inventory_settings.dart';
import 'package:tickets/pages/Settings/GeneralSettings/sales_settings.dart';
import 'package:tickets/pages/Settings/GeneralSettings/shopping_settings.dart';
import 'package:tickets/pages/Settings/GeneralSettings/widgets_settings.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/tabBar/tab_item.dart';
import '../../../controllers/ConfigControllers/GeneralSettingsController/unidadController.dart';
import '../../../models/ConfigModels/empresa.dart';
import '../../../models/ConfigModels/usuarioPermiso.dart';
import '../../../shared/widgets/error/customNoData.dart';
import '../../../shared/widgets/tabBar/vertical_tab_bar.dart';
class GeneralSettingsScreen extends StatefulWidget {
  static String id = 'GeneralSettingsScreen';
  List<EmpresaModels> empresas = [];
  List<UsuarioPermisoModels> listPermisos;
  BuildContext context;
  GeneralSettingsScreen({super.key, required this.listPermisos, required this.empresas, required this.context});
  @override
  _GeneralSettingsScreenState createState() => _GeneralSettingsScreenState();
}
class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>(); late Size size; late BuildContext homeContext;
  final _key = GlobalKey(); late Timer timer;
  final unidadController =    TextEditingController(), valorController =        TextEditingController(),
      cantidadesController =  TextEditingController(), costosPrecioController = TextEditingController(),
      montosController =      TextEditingController(), monedaController =       TextEditingController(),
      abreviaMController =    TextEditingController(), abreviaturaUController = TextEditingController(),
      cambioController =      TextEditingController(), dateController =         TextEditingController();
  ScrollController scrollController =  ScrollController(), controllerUnidad =  ScrollController(),
                   controllerMoneda =  ScrollController();
  late ThemeData theme;double width = 0;
  List<String> listUsuariosString = []; List<MonedaModels> listMonedas = []; List<UnidadModels> listUnidades = [];List<EmpresaModels> listEmpresas = [];
  AjustesGeneralesModels? ajustesGeneralesModels;
  bool _isLoading = true, parametrosGenerales = false, compras = false, inventario = false, ventas = false, account = true;

  UnidadController unidadControllers = UnidadController();
  MonedaController monedaControllers = MonedaController();
  late String selectedEmpresa; late WidgetsSettings ws; late TabController tabController;
  UserPreferences userPreferences = UserPreferences(); UsuarioController usuarioController = UsuarioController();
  AjustesGeneralesController ajustesGeneralesController = AjustesGeneralesController();
  Map<String, AnimationController> _animationControllers = {};
  @override
  void initState() {
    getPermisos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSettings();
    });
    controllerMoneda = ScrollController();
    listEmpresas = widget.empresas;
    selectedEmpresa = listEmpresas.first.nombre;
    tabController = TabController(length: 2, vsync: this);
    const timeLimit = Duration(seconds: 10);
    timer = Timer(timeLimit, () {
      if(listUsuariosString.isEmpty){
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
    timer.cancel();
    unidadController.dispose();
    scrollController.dispose();
    controllerMoneda.dispose();
    usuarioController.dispose();
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    width = size.width-350; ws = WidgetsSettings(theme);
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.f4 : () async {},
      LogicalKeyboardKey.f5 : () async {
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if(listUsuariosString.isEmpty){
            setState(() {
              _isLoading = false;
            });
          }else{
            _isLoading = false;
          }
        });
      },
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey:_key,
        child: Scaffold(
          appBar: size.width > 600? MyCustomAppBarDesktop(title:Texts.generalSettings,context: widget.context,backButton: false) : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: size.width> 600? _bodyLandscape() : _bodyPortrait(),
            ),
          ),
        ));
  }
  Widget _bodyLandscape(){
    return SizedBox(width: size.width,height: size.height-60,
      child: VerticalTabs(tabsWidth: 150,
        selectedTabTextStyle: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold,
        fontSize: 13.5),indicatorColor: theme.colorScheme.secondary,
        unSelectedTabTextStyle: const TextStyle(color: Colors.grey),
        tabs: [
          if(parametrosGenerales) TabItem(title: "Generales", icon: Icons.settings),
          if(compras) TabItem(title: "Compras", icon: IconLibrary.iconShoppingCart),
          if(inventario) TabItem(title: "Inventario", icon: IconLibrary.iconInventory),
          if(ventas) TabItem(title: "Ventas", icon: Icons.point_of_sale_rounded),
          if(account) TabItem(title: "Contabilidad", icon: Icons.account_balance_rounded),
        ],
        contents: allForms()
    ),);
  }
  List<Widget> allForms(){
    return [
      if(parametrosGenerales) generalForm(),
      if(compras) ShoppingSettings(theme: theme, size: size, ajustesGeneralesModels: ajustesGeneralesModels,),
      if(inventario) InventorySettingsScreen(theme: theme, size: size),
      if(ventas) SalesSettingsScreen(size: size, theme: theme,),
      if(account) AccountSettingsScreen(size: size, theme: theme,),
    ];
  }
  Widget generalForm(){
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        ws.myContainer("Usuarios",usuariosSettings()),
        const SizedBox(height: 10,),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4,child: ws.myContainer("Generales",generales())),
            const SizedBox(width: 10,),
            Expanded(flex: 3,child: ws.myContainer2("Unidades",unidades(),null,
                Tooltip(message: Texts.gsUnitAdd, waitDuration: const Duration(milliseconds: 200),
                    child: InkWell(onTap: (){unidadDialog();},
                      child: Container(
                        decoration: BoxDecoration(color: theme.colorScheme.secondary,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),),
                        padding: const EdgeInsets.all(10.0),
                        child: const Icon(IconLibrary.iconAdd, size: 20,),
                      ),))),),
            //Expanded(flex: 3,child: myContainer("Cantidades",cantidad()))
          ],
        ),
        const SizedBox(height: 10),
      ],),));
  }
  void unidadDialog(){
     showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                      body: AlertDialog(
                        title: Text(Texts.gsUnitAdd, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                        content: Column(mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(children: [
                              textFieldUnidadNombre(null),
                              const SizedBox(width: 10,),
                              textFieldUnidadAbreviatura(null)
                            ]),
                            const SizedBox(height: 10,),
                            Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                              ws.buttonCancelar(() {
                                Navigator.of(context1).pop();unidadController.text = '';
                              }),
                              const SizedBox(width: 10,),
                              ws.buttonAceptar(() async {
                                await agregarUnidad(context1);
                              })
                            ],)
                          ],
                        ),
                      )
                    )
                ));
              }
          );
        }
     );
  }
  Future<void> monedaDialog() async{
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                            title: Text(Texts.gsCoinAdd, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                            content: Form(key: formKey,child: Column(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  textFieldMonedaNombre(null),
                                  const SizedBox(width: 10,),
                                  textFieldMonedaAbreviatura(null)
                                ]),
                                const SizedBox(height: 10,),
                                Row(children: [
                                  textFieldMonedaTipoCambio(),
                                  const SizedBox(width: 10,),
                                  ws.boxWithTextField('Ultima actualización', dateController, IconLibrary.iconCalendar, enable:false)
                                ],),
                                const SizedBox(height: 10,),
                                Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                  OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.inversePrimary),
                                      onPressed: (){
                                        Navigator.of(context1).pop();
                                        monedaController.text = '';abreviaMController.text = '';
                                        cambioController.text = '';dateController.text = '';
                                      }, child: const Text('Cancelar')),
                                  const SizedBox(width: 10,),
                                  ElevatedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.secondary),onPressed: () async {
                                    saveMoneda(context1);
                                  }, child: const Text('Guardar')),
                                ],)
                              ],
                            ),)
                        )
                    )
                ));
              }
          );
        }
    );
  }
  void unidadEditDialog(UnidadModels unidadModels){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsUnitEdit, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: Column(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                textFieldUnidadNombre(unidadModels.nombre),
                                const SizedBox(width: 10,),
                                textFieldUnidadAbreviatura(unidadModels.abreviatura)
                              ]),
                              const SizedBox(height: 10,),
                              Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.inversePrimary),
                                    onPressed: (){
                                      Navigator.of(context1).pop();
                                      unidadController.text = '';
                                      abreviaturaUController.text = '';
                                    },
                                    child: const Text('Cancelar')),
                                const SizedBox(width: 10,),
                                ElevatedButton(style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.secondary),onPressed: () async {
                                  await editarUnidad(context1, unidadModels);
                                }, child: const Text('Guardar')),
                              ],)
                            ],
                          ),
                        )
                    )
                ));
              }
          );
        }
    );
  }
  Future<void> agregarUnidad(BuildContext context1) async {
    if(unidadController.text.isNotEmpty){
      LoadingDialog.showLoadingDialog(context1, Texts.gsUnitSaveLoading);
      String userId = await userPreferences.getUsuarioID();
      UnidadModels? unidad = await unidadControllers.saveUnidad(UnidadModels(nombre: unidadController.text,
          abreviatura: abreviaturaUController.text), userId);
      if(unidad != null){
        CustomAwesomeDialog(title: Texts.gsUnitAddSuccess, desc: '', btnOkOnPress: (){},
          btnCancelOnPress: () {},).showSuccess(context1);
        await Future.delayed(const Duration(milliseconds: 2500), () {
          Navigator.of(context1).pop();
          LoadingDialog.hideLoadingDialog(context1);
          unidadController.text = ''; abreviaturaUController.text = '';
        });
        listUnidades.add(unidad);
        _triggerCardAnimationUnidad(unidad);
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 800), () {
          if (controllerUnidad.hasClients) {
            final position = controllerUnidad.position.maxScrollExtent;
            controllerUnidad.animateTo(
              position, duration: const Duration(seconds: 1), curve: Curves.easeOut,
            );
          }
        });
      }else{
        CustomAwesomeDialog(title: Texts.gsUnitErrorSave, desc: '',
          btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
          btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context1);
      }
    }else{
      CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);
    }
  }
  Future<void> editarUnidad(BuildContext context1, UnidadModels unidadModels) async {
    if(unidadController.text.isNotEmpty){
      LoadingDialog.showLoadingDialog(context1, Texts.gsUnitSaveLoading);
      String userId = await userPreferences.getUsuarioID();
      bool unidad = await unidadControllers.updateUnidad(UnidadModels(nombre: unidadController.text,
          abreviatura: abreviaturaUController.text, idUnidad: unidadModels.idUnidad), userId);
      if(unidad == true){
        CustomAwesomeDialog(title: Texts.gsUnitSaveSuccess, desc: '', btnOkOnPress: (){},
          btnCancelOnPress: () {},).showSuccess(context1);
        await Future.delayed(const Duration(milliseconds: 2500), () {
          Navigator.of(context1).pop();
          LoadingDialog.hideLoadingDialog(context1);
          unidadModels.nombre = unidadController.text;
          unidadModels.abreviatura = abreviaturaUController.text;
          setState(() {});
          unidadController.text = ''; abreviaturaUController.text = '';
        });
      }else{
        CustomAwesomeDialog(title: Texts.gsUnitErrorSave, desc: '',
          btnOkOnPress: (){LoadingDialog.hideLoadingDialog(context);},
          btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);},).showError(context1);
      }
    }else{
      CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);
    }
  }
  Widget textFieldMonedaNombre(String? exception){
    return ws.boxWithTextField('Moneda', monedaController, Icons.monetization_on_rounded,
        validator: (value){
          if(value == null || value.isEmpty){
            return Texts.completeField;
          }else if(exception != null && exception == value){
            return null;
          }else if(listMonedas.where((element) => element.nombre == value).isNotEmpty){
            return 'La moneda ya existe';
          }else if(value.length > 20){
            return 'El nombre es muy largo';
          }
          return null;
        });
  }
  Widget textFieldMonedaAbreviatura(String? exception){
    return ws.boxWithTextField('Abreviatura', abreviaMController,  Icons.euro_rounded,
        validator: (value){
          if(value == null || value.isEmpty) {
            return Texts.completeField;
          }else if(exception != null && exception == value){
            return null;
          }else if(listMonedas.where((element) => element.abreviatura == value).isNotEmpty){
            return 'La abreviatura ya existe';
          }else if(value.length > 6){
            return 'La abreviatura es muy larga';
          }
          return null;
        });
  }
  Widget textFieldMonedaTipoCambio(){
    return ws.boxWithTextField('Tipo de cambio', cambioController, Icons.currency_exchange_rounded,
        validator: (value){
          if(value == null || value.isEmpty) {
            return Texts.completeField;
          } else if (double.tryParse(value) == null) {
            return 'Ingresa un número válido';
          }
          return null;
        });
  }

  Widget textFieldUnidadNombre(String? exception){
    return ws.boxWithTextField('Unidad', unidadController, Icons.straighten_rounded,
        validator: (value){
          if(value == null || value.isEmpty){
            return Texts.completeField;
          }else if(exception != null && exception == value){
            return null;
          }else if(listUnidades.where((element) => element.nombre == value).isNotEmpty){
            return 'La unidad ya existe';
          }else if(value.length > 20){
            return 'El nombre es muy largo';
          }
          return null;
        });
  }
  Widget textFieldUnidadAbreviatura(String? exception){
    return ws.boxWithTextField('Abreviatura', abreviaturaUController,  Icons.euro_rounded,
        validator: (value){
          if(value == null || value.isEmpty) {
            return Texts.completeField;
          }else if(exception != null && exception == value){
            return null;
          }else if(listUnidades.where((element) => element.abreviatura == value).isNotEmpty){
            return 'La abreviatura ya existe';
          }else if(value.length > 6){
            return 'La abreviatura es muy larga';
          }
          return null;
        });
  }

  Future<void> monedaEditDialog(MonedaModels monedaModels) async{
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                            title: Text(Texts.gsUnitEdit, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                            content: Form(key: formKey,child: Column(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  textFieldMonedaNombre(monedaModels.nombre),
                                  const SizedBox(width: 10,),
                                  textFieldMonedaAbreviatura(monedaModels.abreviatura)
                                ]),
                                const SizedBox(height: 10,),
                                Row(children: [
                                  textFieldMonedaTipoCambio(),
                                  const SizedBox(width: 10,),
                                  ws.boxWithTextField('Ultima actualización', dateController, IconLibrary.iconCalendar, enable:false)
                                ],),
                                const SizedBox(height: 10,),
                                Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                  ws.buttonCancelar(() {
                                    Navigator.of(context1).pop();
                                    monedaController.text = '';abreviaMController.text = '';
                                    cambioController.text = '';dateController.text = '';
                                  }),
                                  const SizedBox(width: 10,),
                                  ws.buttonAceptar(() async {
                                    await editMoneda(context1, monedaModels);
                                  })
                                ],)
                              ],
                            ),)
                        )
                    )
                ));
              }
          );
        }
    );
  }
  Future<void> saveMoneda(BuildContext context1)async{
    if(formKey.currentState!.validate()){
      CustomAwesomeDialog(title: Texts.gsCoinWannaSave,
          desc: '', btnOkOnPress: () async {
            try{
              LoadingDialog.showLoadingDialog(context1, Texts.savingData);
              MonedaModels? moneda;
              String userId = await userPreferences.getUsuarioID();
              moneda = await monedaControllers.saveMoneda(MonedaModels(nombre: monedaController.text, abreviatura: abreviaMController.text,
                  tipoCambio: double.parse(cambioController.text), fechaActualizacion: dateController.text), userId);

              if(moneda != null){
                CustomAwesomeDialog(title: Texts.gsCoinSaveSuccess, desc: '', btnOkOnPress: (){},
                  btnCancelOnPress: () {},).showSuccess(context1);
                await Future.delayed(const Duration(milliseconds: 2500), () {
                  LoadingDialog.hideLoadingDialog(context1);
                  Navigator.of(context1).pop();
                  monedaController.text = ''; abreviaMController.text = '';
                  cambioController.text = ''; dateController.text = '';
                });
                listMonedas.add(moneda);

                _triggerCardAnimationMoneda(moneda);
                setState(() {});
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (controllerMoneda.hasClients) {
                    final position = controllerMoneda.position.maxScrollExtent;
                    controllerMoneda.animateTo(
                      position, duration: const Duration(seconds: 1), curve: Curves.easeOut,
                    );
                  }
                });
              }else{
                LoadingDialog.hideLoadingDialog(context1);
                CustomAwesomeDialog(title: Texts.gsCoinErrorSave, desc: '', btnOkOnPress: (){},
                  btnCancelOnPress: () {},).showError(context1);
              }
            }catch(e){
              Navigator.pop(context1);
              CustomSnackBar.showErrorSnackBar(context1, Texts.gsCoinErrorSave);
            }
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);
    }
  }
  Future<void> editMoneda(BuildContext context1, MonedaModels monedaModels)async{
    if(formKey.currentState!.validate()){
      CustomAwesomeDialog(title: Texts.gsCoinWannaEdit,
          desc: '', btnOkOnPress: () async {
            try{
              LoadingDialog.showLoadingDialog(context1, Texts.savingData);
              String userId = await userPreferences.getUsuarioID();
              bool put = await monedaControllers.updateMoneda(MonedaModels(idMoneda: monedaModels.idMoneda,
                  nombre: monedaController.text, abreviatura: abreviaMController.text,
                  tipoCambio: double.parse(cambioController.text), fechaActualizacion: dateController.text), userId);
              if(put == true){
                CustomAwesomeDialog(title: Texts.gsCoinEditSuccess, desc: '', btnOkOnPress: (){},
                  btnCancelOnPress: () {},).showSuccess(context1);
                await Future.delayed(const Duration(milliseconds: 2500), () {
                  LoadingDialog.hideLoadingDialog(context1);
                  Navigator.of(context1).pop();
                  monedaModels.nombre = monedaController.text;
                  monedaModels.abreviatura = abreviaMController.text;
                  monedaModels.tipoCambio = double.parse(cambioController.text);
                  setState(() {});
                  monedaController.text = ''; abreviaMController.text = '';
                  cambioController.text = ''; dateController.text = '';
                });
              }else{
                LoadingDialog.hideLoadingDialog(context1);
                CustomAwesomeDialog(title: Texts.gsCoinErrorEdit, desc: '', btnOkOnPress: (){},
                  btnCancelOnPress: () {},).showError(context1);
              }
            }catch(e){
              Navigator.pop(context1);
              CustomSnackBar.showErrorSnackBar(context1, Texts.gsCoinErrorEdit);
            }
          }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);
    }
  }
  Widget usuariosSettings(){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
      Row(children: [
        Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
          value:ajustesGeneralesModels != null? ajustesGeneralesModels!.permisosForzosos : false,
          onChanged:ajustesGeneralesModels != null? (value){
            CustomAwesomeDialog(title: "¿Estás seguro que deseas cambiar los permisos"
                " a ${ajustesGeneralesModels!.permisosForzosos? "NO" : ""} forzosos?",
                desc: '', btnOkOnPress: () async {
                  setPermisosForzosos(value);
                  setState(() {});
                }, btnCancelOnPress: (){}).showQuestion(context);
          }:null,),
        const SizedBox(width: 10,),
        SizedBox(width: size.width*.28,child: const Text("Permisos forzosos para creación de usuarios",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),)
      ],),
      Row(children: [
        Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
          value:ajustesGeneralesModels != null? ajustesGeneralesModels!.multiEmpresa : false,
          onChanged:ajustesGeneralesModels != null? (value){
            CustomAwesomeDialog(title: "¿Estás seguro que deseas ${ajustesGeneralesModels!.multiEmpresa? "DESACTIVAR" : "ACTIVAR"} la opción usuario MultiEmpresa",
                desc: '', btnOkOnPress: () async {
                  setMultiEmpresa(value);
                }, btnCancelOnPress: (){}).showQuestion(context);
          } : null,),
        const SizedBox(width: 10,),
        const Text("Usuarios multiempresa",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
      ],),
      const SizedBox(),
    ],);
  }
  Widget generales(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Row(children: [
        Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
          value:ajustesGeneralesModels != null? ajustesGeneralesModels!.multiMoneda : false,
          onChanged:ajustesGeneralesModels != null? (value){
            CustomAwesomeDialog(title: "¿Estás seguro que deseas ${ajustesGeneralesModels!.multiMoneda? "DESACTIVAR" : "ACTIVAR"}"
                " la opción de  multimoneda?",
                desc: '', btnOkOnPress: () async {
                  await setMultiMoneda(value);
                }, btnCancelOnPress: (){}).showQuestion(context);
          } : null,),
        const SizedBox(width: 10,),
        const Text("Multimoneda", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
      ],),
      AnimatedOpacity(opacity:ajustesGeneralesModels != null?( ajustesGeneralesModels!.multiMoneda? 1:.5):0.5, duration: const Duration(milliseconds: 500),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          Row(children: [
            Checkbox(checkColor: theme.colorScheme.onPrimary, fillColor: MaterialStateProperty.all(theme.colorScheme.secondary),
              value:ajustesGeneralesModels != null? ajustesGeneralesModels!.solicitarTipoDeCambio : false,
              onChanged: ajustesGeneralesModels!= null?(ajustesGeneralesModels!.multiMoneda?(value){
                CustomAwesomeDialog(title: "¿Estás seguro que deseas ${ajustesGeneralesModels!.solicitarTipoDeCambio? "DESACTIVAR" : "ACTIVAR"} la opción de solicitar tipo de cambio?",
                    desc: '', btnOkOnPress: () async {
                      await setTipoCambio(value);
                    }, btnCancelOnPress: (){}).showQuestion(context);
              } : null) : null),
            const SizedBox(width: 10,),
            const Text("Solicitar tipo de cambio", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
          ],),
          Tooltip(message: "Agregar moneda", waitDuration: const Duration(milliseconds: 200),
              child: InkWell(onTap: ajustesGeneralesModels!=null?(ajustesGeneralesModels!.multiMoneda? () async {
                dateController.text = DateTime.now().toString().split(" ")[0];
                await monedaDialog();
              } : null) : null,
                child: Container(
                  decoration: BoxDecoration(color: theme.colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),),
                  padding: const EdgeInsets.all(10.0), child: const Icon(IconLibrary.iconAdd, size: 20,),
                )))
        ],),
        const SizedBox(height: 5,),
        Container(height: 100,decoration: BoxDecoration(color: theme.colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,children: [
              SizedBox(height: 98,child: futureList(),)
            ],),
        )
      ],),)
    ],);
  }
  Future<void> setTipoCambio(bool? value) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsSaveLoading);
    String userID = await userPreferences.getUsuarioID();
    bool? saveTipoCambio =  await ajustesGeneralesController.saveAjustesSolicitarTipoDeCambio(value!, userID);
    LoadingDialog.hideLoadingDialog(context);
    if(saveTipoCambio != null){
      CustomAwesomeDialog(title: Texts.gsSaveSuccess, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showSuccess(context);
      ajustesGeneralesModels!.solicitarTipoDeCambio = saveTipoCambio;
      setState(() {});
    }else{
      CustomAwesomeDialog(title: Texts.gsErrorSave, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showError(context);
    }
  }
  Future<void> setMultiMoneda(bool? value) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsSaveLoading);
    String userID = await userPreferences.getUsuarioID();
    bool? saveMultiMoneda =  await ajustesGeneralesController.saveAjustesMultiMoneda(value!, userID);
    LoadingDialog.hideLoadingDialog(context);
    if(saveMultiMoneda != null){
      CustomAwesomeDialog(title: Texts.gsSaveSuccess, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showSuccess(context);
      ajustesGeneralesModels!.multiMoneda = saveMultiMoneda;
      setState(() {});
    }else{
      CustomAwesomeDialog(title: Texts.gsErrorSave, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showError(context);
    }
  }
  Future<void> setPermisosForzosos(bool? value) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsSaveLoading);
    String userID = await userPreferences.getUsuarioID();
    bool? savePermisosForzosos =  await ajustesGeneralesController.saveAjustesPermisosForzosos(value!, userID);
    LoadingDialog.hideLoadingDialog(context);
    if(savePermisosForzosos != null){
      CustomAwesomeDialog(title: Texts.gsSaveSuccess, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showSuccess(context);
      ajustesGeneralesModels!.permisosForzosos = savePermisosForzosos;
      setState(() {});
    }else{
      CustomAwesomeDialog(title: Texts.gsErrorSave, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showError(context);
    }
  }
  Future<void> setMultiEmpresa(bool? value) async {
    LoadingDialog.showLoadingDialog(context, Texts.gsSaveLoading);
    String userID = await userPreferences.getUsuarioID();
    bool? saveMultiEmpresa =  await ajustesGeneralesController.saveAjustesMultiEmpresa(value!, userID);
    LoadingDialog.hideLoadingDialog(context);
    if(saveMultiEmpresa != null){
      CustomAwesomeDialog(title: Texts.gsSaveSuccess, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showSuccess(context);
      ajustesGeneralesModels!.multiEmpresa = saveMultiEmpresa;
      setState(() {});
    }else{
      CustomAwesomeDialog(title: Texts.gsErrorSave, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showError(context);
    }
  }
  Widget futureList() {
    return FutureBuilder<List<MonedaModels>>(
      future: getDatosMonedas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: ws.buildLoadingIndicator(10, size));
        } else {
          final listProducto = snapshot.data ?? [];
          if (listProducto.isNotEmpty) {
            return Scrollbar(controller: controllerMoneda, thumbVisibility: true,
                child: RefreshIndicator(
                  onRefresh: () async {await getMonedas();},
                  child: FadingEdgeScrollView.fromScrollView(
                    gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controllerMoneda, itemCount: listMonedas.length,
                      itemBuilder: (context, index) {
                        return cardScaleMoneda(listMonedas[index]);
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
      },
    );
  }
  Widget cantidad(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      ws.textFieldCantidades("Decimales en cantidades", cantidadesController),
      const SizedBox(height: 10,),
      ws.textFieldCantidades("Decimales en costos y precios", costosPrecioController),
      const SizedBox(height: 10,),
      ws.textFieldCantidades("Decimales en montos", montosController),
    ],);
  }
  Widget unidades(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SizedBox(height: 5),
      Container(height: 160,decoration: BoxDecoration(color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,children: [
            SizedBox(height: 158,child: futureListUnidades(),)
          ]),
      )
    ]);
  }
  Widget futureListUnidades(){
    return FutureBuilder<List<UnidadModels>>(future: getDatosUnidades(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: ws.buildLoadingIndicator(10, size));
          } else {
            final listSnapshot = snapshot.data ?? [];
            if (listSnapshot.isNotEmpty) {
              return Scrollbar(controller: controllerUnidad, thumbVisibility: true,
                child: RefreshIndicator(
                  onRefresh: () async {await getUnidad();},
                  child: FadingEdgeScrollView.fromScrollView(
                    gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controllerUnidad, itemCount: listUnidades.length,
                      itemBuilder: (context, index) {
                        return cardScaleUnidad(listUnidades[index]);
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

  Widget cardMoneda(MonedaModels moneda){
    return MySwipeTileCard(horizontalPadding: 3, verticalPadding: 2, radius: 6,
        swipeThreshold:ajustesGeneralesModels != null? (ajustesGeneralesModels!.multiMoneda? 0.12 : 0.002):0.002, colorBasico: theme.colorScheme.background,
        containerRL: moneda.estatus == true? null: Row(children: [
          Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
        ],), colorRL: moneda.estatus == true? null : ColorPalette.ok,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Row(children: [
              Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
                ws.filaEspecial("Moneda", moneda.nombre),
                ws.filaEspecial("Abreviatura", "${moneda.abreviatura}", width: 105),
                ws.filaEspecial("Tipo de cambio", "\$${moneda.tipoCambio}"),
                ws.filaEspecial("Estatus", moneda.estatus!=null? (moneda.estatus==true? "Activo" : "Inactivo") : "Inactivo",
                color: moneda.estatus == true? ColorPalette.ok : ColorPalette.accentColor, width: 105),
              ]))
          ])
        ),
        onTapLR: (){
          if(ajustesGeneralesModels!.multiMoneda){
            if(moneda.nombre != "Pesos"){
              monedaController.text = moneda.nombre;
              abreviaMController.text = moneda.abreviatura!;
              cambioController.text = moneda.tipoCambio.toString();
              dateController.text = moneda.fechaActualizacion!.toString().split("T")[0];
              monedaEditDialog(moneda);
            }else{
              MyCherryToast.showWarningSnackBar(context, theme, 'No puedes editar la moneda "Pesos"');
            }
          }
        }, onTapRL: () async {
          if(ajustesGeneralesModels!.multiMoneda){
            if(moneda.estatus!){
              eliminarMoneda(moneda);
            }else{
              reactivarMoneda(moneda);
            }
          }
        });
  }
  Widget cardScaleUnidad(UnidadModels unidad){
    final controller = _animationControllers[unidad.idUnidad];
    final scaleAnimation = controller != null ? Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)) : const AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: cardUnidad(unidad));
        });
  }
  Widget cardScaleMoneda(MonedaModels moneda){
    final controller = _animationControllers[moneda.idMoneda];
    final scaleAnimation = controller != null ? Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)) : const AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: cardMoneda(moneda));
        });
  }
  Widget cardUnidad(UnidadModels unidad){
    return MySwipeTileCard(horizontalPadding: 3, verticalPadding: 2, radius: 6, colorBasico: theme.colorScheme.background,
        containerRL: unidad.estatus == true? null: Row(children: [
          Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
        ],),
        colorRL: unidad.estatus == true? null : ColorPalette.ok,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 10,
            vertical: 2),child: Row(children: [
          Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
            ws.filaEspecial("Unidad", unidad.nombre),
            ws.filaEspecial("Abreviatura", "${unidad.abreviatura}", width: 110),
            ws.filaEspecial("Estatus", unidad.abreviatura!=null? (unidad.estatus==true? "Activo" : "Inactivo") : "Inactivo"
                ,color: unidad.estatus == true? ColorPalette.ok : ColorPalette.accentColor, width: 100),
          ],),)
        ],),),
        onTapLR: (){
          unidadController.text = unidad.nombre;
          abreviaturaUController.text = unidad.abreviatura!;
          unidadEditDialog(unidad);
        }, onTapRL: (){
          if(unidad.estatus!){
            eliminarUnidad(unidad);
          }else{
            reactivarUnidad(unidad);
          }
        });
  }
  void eliminarUnidad(UnidadModels unidad){
    CustomAwesomeDialog(title: "¿Estás seguro que deseas desactivar la unidad \"${unidad.nombre}\"?",
        desc: '', btnOkOnPress: () async {
          LoadingDialog.showLoadingDialog(context, Texts.gsUnitDeactivateLoading);
          String userID = await userPreferences.getUsuarioID();
          bool delete = await unidadControllers.deleteUnidad(unidad.idUnidad!, userID);
          LoadingDialog.hideLoadingDialog(context);
          if(delete) {
            CustomAwesomeDialog(title: Texts.gsUnitDeactivateSuccess, desc: '',
              btnOkOnPress: () {}, btnCancelOnPress: () {},).showSuccess(context);
            unidad.estatus = false;
            setState(() {});
          }
        }, btnCancelOnPress: (){}).showQuestion(context);
  }
  void reactivarUnidad(UnidadModels unidad){
    CustomAwesomeDialog(title: "¿Estás seguro que deseas activar la unidad \"${unidad.nombre}\"?",
        desc: '', btnOkOnPress: () async {
          LoadingDialog.showLoadingDialog(context, Texts.gsUnitActivateLoading);
          String userID = await userPreferences.getUsuarioID();
          bool delete = await unidadControllers.activarUnidad(unidad.idUnidad!, userID);
          LoadingDialog.hideLoadingDialog(context);
          if(delete) {
            CustomAwesomeDialog(title: Texts.gsUnitActivateSuccess, desc: '',
              btnOkOnPress: () {}, btnCancelOnPress: () {},).showSuccess(context);
            unidad.estatus = true;
            setState(() {});
          }
        }, btnCancelOnPress: (){}).showQuestion(context);
  }

  Future<void> eliminarMoneda(MonedaModels moneda) async{
    if(moneda.nombre != "Pesos") {
      CustomAwesomeDialog(title: "¿Estás seguro que deseas desactivar la moneda \"${moneda.nombre}\"?",
          desc: '', btnOkOnPress: () async {
            String userID = await userPreferences.getUsuarioID();
            bool delete = await monedaControllers.deleteMoneda(moneda.idMoneda!, userID);
            if(delete){
              CustomAwesomeDialog(title: Texts.gsCoinDeactivateSuccess, desc: '', btnOkOnPress: (){},
                btnCancelOnPress: () {},).showSuccess(context);
              moneda.estatus = false;
              setState(() {});
            }else{
              CustomAwesomeDialog(title: Texts.gsCoinErrorDeactivate, desc: '', btnOkOnPress: (){},
                btnCancelOnPress: () {},).showError(context);
            }
            setState(() {});
          }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      MyCherryToast.showWarningSnackBar(context, theme, 'No puedes eliminar la moneda "Pesos"');
    }
  }
  Future<void> reactivarMoneda(MonedaModels moneda) async{
    CustomAwesomeDialog(title: "¿Estás seguro que deseas activar la moneda \"${moneda.nombre}\"?",
        desc: '', btnOkOnPress: () async {
          String userID = await userPreferences.getUsuarioID();
          bool delete = await monedaControllers.activarMoneda(moneda.idMoneda!, userID);
          if(delete){
            CustomAwesomeDialog(title: Texts.gsCoinActivateSuccess, desc: '', btnOkOnPress: (){},
              btnCancelOnPress: () {},).showSuccess(context);
            moneda.estatus = true;
            setState(() {});
          }else{
            CustomAwesomeDialog(title: Texts.gsCoinErrorActivate, desc: '', btnOkOnPress: (){},
              btnCancelOnPress: () {},).showError(context);
          }
          setState(() {});
        }, btnCancelOnPress: (){}).showQuestion(context);
  }
  Widget _bodyPortrait(){
    return const Column(children: [Text("data")]);
  }
  Future<List<MonedaModels>> getDatosMonedas() async {
    try {
      return listMonedas;
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }
  Future<List<UnidadModels>> getDatosUnidades() async {
    try {
      return listUnidades;
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }
  Future<List<String>> getDatosPrecios() async {
    try {
      return ["Público", "Mínimo"];
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }
  Future<void> getSettings() async {
    LoadingDialog.showLoadingDialog(context, Texts.gsLoading);
    await getMonedas();
    await getUnidad();
    await getAjustesGenerales();
    LoadingDialog.hideLoadingDialog(context);
  }
  Future<void> getMonedas() async {
    try{
      List<MonedaModels> monedaList = await monedaControllers.getMonedas();
      if(monedaList.isNotEmpty){
        monedaList.sort((a, b) {
          if (a.nombre == "Pesos") return -1;
          if (b.nombre == "Pesos") return 1;
          return a.nombre.compareTo(b.nombre);
        });
        listMonedas = monedaList;
        setState(() {});
      }
    }catch (e){
      print('Error al obtener monedas: $e');
    }
  }
  Future<void> getUnidad() async {
    try{
      List<UnidadModels> unidadList = await unidadControllers.getUnidad();
      if(unidadList.isNotEmpty){
        listUnidades = unidadList;
        setState(() {});
      }
    }catch (e){
      print('Error al obtener monedas: $e');
    }
  }
  Future<void> getAjustesGenerales() async {
    try{
      AjustesGeneralesModels? ajustesGenerales = await ajustesGeneralesController.getAjustesGenerales();
      if(ajustesGenerales != null){
        ajustesGeneralesModels = ajustesGenerales;
        cantidadesController.text = ajustesGeneralesModels!.cantidades.toString();
        costosPrecioController.text = ajustesGeneralesModels!.costosPrecios.toString();
        montosController.text = ajustesGeneralesModels!.montos.toString();
        setState(() {});
      }
    }catch (e){
      CustomAwesomeDialog(title: Texts.gsErrorGet, desc: '', btnOkOnPress: (){},
        btnCancelOnPress: () {},).showError(context);
      print('Error al obtener monedas: $e');
    }
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
  void _triggerCardAnimationMoneda(MonedaModels moneda) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationControllers[moneda.idMoneda!] = controller;
    Future.delayed(const Duration(milliseconds: 1600), () {
      controller.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.reverse();
      });
    });
  }
  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listPermisos;

    for(int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId == Texts.permissionsSettingsInventory) {
        inventario = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsGeneralSettings){
        parametrosGenerales = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsSettingsShopping){
        compras = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsSettingsSales){
        ventas = true;
      }
    }
  }
}