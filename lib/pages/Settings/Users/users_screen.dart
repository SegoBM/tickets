import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/ajustesGeneralesController.dart';
import 'package:tickets/controllers/ConfigControllers/areaController.dart';
import 'package:tickets/controllers/ConfigControllers/usuarioController.dart';
import 'package:tickets/controllers/ConfigControllers/usuarioPermisoController.dart';
import 'package:tickets/models/ConfigModels/area.dart';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/pages/Settings/Users/user_edit_screen.dart';
import 'package:tickets/pages/Settings/Users/user_registration_screen.dart';
import 'package:tickets/pages/Settings/Users/user_registration_screen2.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Fiscal/textFieldClaveSat.dart';
import 'package:tickets/shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/drop_down_button/dropdown_container.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import '../../../controllers/ConfigControllers/PermisoController/permisoController.dart';
import '../../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';
import '../../../models/ConfigModels/empresa.dart';
import '../../../models/ConfigModels/usuario.dart';
import '../../../shared/Automations/st_mathod.dart';
import '../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../shared/widgets/error/customNoData.dart';
class UsersScreen extends StatefulWidget {
  static String id = 'UsersScreen';
  List<UsuarioPermisoModels> listUsuarioPermisos;
  List<EmpresaModels> empresas;
  BuildContext context;
  UsersScreen({super.key, required this.listUsuarioPermisos, required this.empresas, required this.context});
  @override
  _UsersScreenState createState() => _UsersScreenState();
}
class _UsersScreenState extends State<UsersScreen> {
  late Size size; final TextEditingController _searchController = TextEditingController();
  final TextEditingController textController = TextEditingController(); final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _searchFocusNode = FocusNode();
  ScrollController scrollController = ScrollController(), scrollController2 = ScrollController();
  late ThemeData theme; double width = 0;
  final List<String> items = ['Usuario', 'Administrador', 'SuperAdmin'];
  List<UsuarioModels> listUsuarios = [], listUsuariosTemp = [];
  List<String> listUsuariosString = [], listNombreString = [],
      listTipoUsuarioString = [], listDepartamentoString = [], listEstatusString = [],
      itemsDepartments = [], selectedItems = [], selectedDepartmentsItems = [];
  bool _isLoading = true, _pressed = true, addUserP = false,
      editUserP = false, deleteUserP = false, downloadUserP = false;
  late BuildContext homeContext;List<EmpresaModels> listEmpresas = [];
  late String selectedEmpresa;
  UserPreferences userPreferences = UserPreferences();
  UsuarioController usuarioController = UsuarioController();
  final _key = GlobalKey(), buttonKey1 = GlobalKey(), buttonKey2 = GlobalKey(), buttonKey3 = GlobalKey(),
    buttonKey4 = GlobalKey(), buttonKey5 = GlobalKey();
  int _sortOrder = 0;

  Map<String, int> sortOrders = {
    "userName": 0,
    "nombre": 0,
    "tipoUsuario": 0,
    "departamento": 0,
    "estatus": 0,
  };
  Map<String, Map<int, int Function(UsuarioModels, UsuarioModels)>> sortFunctions = {
    "userName": {
      1: (UsuarioModels a, UsuarioModels b) => a.userName.compareTo(b.userName),
      2: (UsuarioModels a, UsuarioModels b) => b.userName.compareTo(a.userName)
    },
    "nombre": {
      1: (UsuarioModels a, UsuarioModels b) => a.nombre.compareTo(b.nombre),
      2: (UsuarioModels a, UsuarioModels b) => b.nombre.compareTo(a.nombre)
    },
    "tipoUsuario": {
      1: (UsuarioModels a, UsuarioModels b) => a.tipoUsuario.compareTo(b.tipoUsuario),
      2: (UsuarioModels a, UsuarioModels b) => b.tipoUsuario.compareTo(a.tipoUsuario)
    },
    "departamento": {
      1: (UsuarioModels a, UsuarioModels b) => a.nombreDepartamento!.compareTo(b.nombreDepartamento!),
      2: (UsuarioModels a, UsuarioModels b) => b.nombreDepartamento!.compareTo(a.nombreDepartamento!)
    },
    "estatus": {
      1: (UsuarioModels a, UsuarioModels b) => (a.estatus! == true ? "ACTIVO" : "INACTIVO").compareTo(b.estatus! == true ? "ACTIVO" : "INACTIVO"),
      2: (UsuarioModels a, UsuarioModels b) => (b.estatus! == true ? "ACTIVO" : "INACTIVO").compareTo(a.estatus! == true ? "ACTIVO" : "INACTIVO")
    },
  };
  TextEditingController claveSatController = TextEditingController();
  @override
  void initState() {
    listEmpresas = widget.empresas;
    selectedEmpresa = listEmpresas.first.nombre;
    getUsuarios();
    getPermisos();
    const timeLimit = Duration(seconds: 30);
    Timer(timeLimit, () {
      if(listUsuarios.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
      }
      _isLoading = false;
    });
    super.initState();
  }
  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    scrollController2.dispose();
    usuarioController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context); width = size.width-350;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.f2 : () async {
        UsuarioModels? usuarioSelected = await getUsuarioSelected();
        if(usuarioSelected!=null) {
          deleteUser(usuarioSelected);
        }else{
          MyCherryToast.showWarningSnackBar(context, theme, Texts.errorEditing, Texts.selectUser);
        }
      },
      LogicalKeyboardKey.f3 : () async {
        UsuarioModels? usuarioSelected = await getUsuarioSelected();
        if(usuarioSelected!=null) {
          editUser(usuarioSelected);
        }else{
          MyCherryToast.showWarningSnackBar(context, theme, Texts.errorEditing, Texts.selectUser);
        }
      },
      LogicalKeyboardKey.f4 : () async {addUser();},
      LogicalKeyboardKey.f5 : () async {
        getUsuarios();
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if(listUsuarios.isEmpty){setState(() {_isLoading = false;});}
          else{_isLoading = false;}
        });
      },
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey:_key,
        child: Scaffold(
          appBar: size.width > 600? MyCustomAppBarDesktop(title: Texts.user,context: widget.context,
              backButton: true, backButtonWidget: empresasButton()) : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: size.width > 600? _bodyLandscape() : _bodyPortrait(),
            ),
          ),
        ));
  }
  Future<UsuarioModels?> getUsuarioSelected() async{
    UsuarioModels? usuarioSelected;
    try {usuarioSelected = listUsuariosTemp.firstWhere((element) => element.selected);}
    catch (e) {usuarioSelected = null;}
    return usuarioSelected;
  }
  Widget empresasButton() {
    return SizedBox(width: 120,child: MyDropdown(dropdownItems: listEmpresas.map((e) => e.nombre).toList(),
        suffixIcon: const Icon(IconLibrary.iconBusiness),
        textStyle:  const TextStyle(fontSize: 13),
        selectedItem: selectedEmpresa, onPressed: (value){
          if(value!=selectedEmpresa){
            CustomAwesomeDialog(title: Texts.askChangeCompany, desc: 'Empresa: $value', btnOkOnPress: () async {
              selectedEmpresa = value!;
              EmpresaModels empresaModels = listEmpresas.firstWhere((element) => element.nombre == value);
              await userPreferences.changeCompanyId(empresaModels.idEmpresa!, empresaModels.nombre);
              getUsuarios();
            }, btnCancelOnPress: (){}).showQuestion(context);
          }
        }),);
  }
  Widget _bodyLandscape(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Row(children: _filtros(),),
              const SizedBox(width: 5,),
            ],),
            const SizedBox(width: 5,),
            Row(children: [
              _customButtonAdd(),
              const SizedBox(width: 5,),
              _customButtonEdit(),
              const SizedBox(width: 5,),
              _customButtonDelete()
            ],)
          ],),
        const SizedBox(height: 5,),
        encabezados(),
        viewCard()
      ],
    );
  }
  Widget _customButtonAdd(){
    return Tooltip(message: Texts.userAddRegistry, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
      child: IconButton(onPressed: () async {
        if(_pressed){
          addUser();
        }else{
          if(addUserP){
            LoadingDialog.showLoadingDialog(context, Texts.loadingData);
            List<AreaModels> listArea = await _getAreas();
            List<SubmoduloPermisos> listSubmoduloPermisos = await _getSubmoduloPermiso();
            AjustesGeneralesController ajustesGeneralesController = AjustesGeneralesController();
            List<bool> listAjustes = await ajustesGeneralesController.getAjustesUsuarios();

            await Future.delayed(const Duration(milliseconds: 150), () {
              LoadingDialog.hideLoadingDialog(context);
            });
            var result = await myShowDialogScale(UserRegistrationScreen2(listSubmoduloPermisos: listSubmoduloPermisos,
              areas: listArea, listEmpresas: listEmpresas, listAjustesUsuarios: listAjustes,), context, width: size.width*.70,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0),));
            if(result == true){
              getUsuarios();
            }
          }else{
            CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
          }
        }
      }, icon: const Icon(IconLibrary.iconAdd),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
          shape: MaterialStateProperty.all <RoundedRectangleBorder> (
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),),
      ),
    ),);
  }
  Widget _customButtonEdit(){
    return Tooltip(message: Texts.userEdit, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          UsuarioModels? usuarioSelected= await getUsuarioSelected();
          if(usuarioSelected!=null) {
            editUser(usuarioSelected);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, Texts.errorEdit, Texts.selectUser);
          }
        }, icon: const Icon(IconLibrary.iconEdit),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }
  Widget _customButtonDelete(){
    return Tooltip(message: Texts.userDeactivate, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          UsuarioModels? usuarioSelected = await getUsuarioSelected();
          if(usuarioSelected!=null) {
            deleteUser(usuarioSelected);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, Texts.errorUserDeactivate, Texts.selectUser);
          }
        }, icon: const Icon(IconLibrary.iconDelete),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }
  void aplicarFiltro(){ //applyFilter
    listUsuariosTemp = listUsuarios;
    if(_searchController.text.isNotEmpty){
      listUsuariosTemp = listUsuariosTemp.where((usuario) =>
      usuario.userName.toLowerCase().contains(_searchController.text.toLowerCase())
          || "${usuario.nombre} ${usuario.apellidoPaterno} ${usuario.apellidoMaterno}".
      toLowerCase().contains(_searchController.text.toLowerCase())
      || usuario.nombreDepartamento!.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }
    setState(() {});
  }
  List<Widget> _filtros(){
    return [
      SizedBox(width: 250, child: MyTextfieldIcon(labelText: Texts.search, textController: _searchController,
        suffixIcon: const Icon(IconLibrary.iconSearch),floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold),backgroundColor: theme.colorScheme.secondary,formatting: false,
        colorLine: theme.colorScheme.primary, focusNode: _searchFocusNode,
        onChanged: (value){
          aplicarFiltro();
          setState(() {
            FocusScope.of(context).requestFocus(_searchFocusNode);
          });
        },
      ),),
      const SizedBox(width: 5,),
      _tableViewButton(),
    ];
  }
  Widget _tableViewButton() {
    return Tooltip(message: _pressed? Texts.showViewCard : Texts.showViewTable,
      waitDuration: const Duration(milliseconds: 500),child: SizedBox(height: 56, width: 45,
      child: IconButton(
        onPressed: (){
          _pressed = !_pressed;
          setState((){});
        },
        icon: _pressed ?  const Icon(Icons.list)  : const Icon(Icons.table_view),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
          shape: MaterialStateProperty.all <RoundedRectangleBorder> (
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),),
      ),
    ),
    );
  }
  Widget encabezados ( ){
    return Container(height: 40,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: _pressed?0:10,),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: encabezadosCard(),
            ))
    );
  }
  IconData _sortIcon(int sortOrder){
    if(sortOrder == 0){
      return Icons.swap_vert;
    }else if(sortOrder == 1){
      return Icons.arrow_upward_rounded;
    }else{
      return Icons.arrow_downward_rounded;
    }
  }
  List<Widget> encabezadosCard(){
    return [
      const SizedBox(width: 15,),
      if(!_pressed)...[
        const SizedBox(width: 40,),
      ],
      SizedBox(width: width/5,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text(Texts.user, textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(sortOrders["userName"]!)),onTap: (){orderBy("userName");},),
          InkWell(key: buttonKey1,child: Icon(Icons.filter_alt,
            color: listUsuariosString.length != listUsuarios.map((e) => e.userName).toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey1.currentContext!, "userName", listUsuariosString);},)
        ],)
      ],),),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text(Texts.name, textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(sortOrders["nombre"]!)), onTap: (){orderBy("nombre");},),
          InkWell(key: buttonKey2,child: Icon(Icons.filter_alt,
            color: listNombreString.length != listUsuarios.map((e) => e.nombre).toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey2.currentContext!, "nombre", listNombreString);},)
        ],)
      ],),),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text(Texts.typeUser,  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(sortOrders["tipoUsuario"]!)),onTap: (){orderBy("tipoUsuario");},),
          InkWell(key: buttonKey3,child: Icon(Icons.filter_alt,
            color: listTipoUsuarioString.length != listUsuarios.map((e) => e.tipoUsuario).toSet().toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),onTap: (){handleButtonPress(buttonKey3.currentContext!, "tipoUsuario", listTipoUsuarioString);},)
        ],)
      ],),),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text(Texts.department,  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(sortOrders["departamento"]!)), onTap: (){orderBy("departamento");}),
          InkWell(key: buttonKey4,child: Icon(Icons.filter_alt,
            color: listDepartamentoString.length!=listUsuarios.map((e) => e.nombreDepartamento).toSet().toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey4.currentContext!, "departamento", listDepartamentoString);},)
        ],)
      ],),),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/12,child: const Text(Texts.status,  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(mainAxisAlignment: MainAxisAlignment.end,children: [
          InkWell(child: Icon(_sortIcon(sortOrders["estatus"]!)), onTap: (){orderBy("estatus");
          },),
          InkWell(key: buttonKey5,child: Icon(Icons.filter_alt,
            color: listEstatusString.length!=listUsuarios.map((e) => e.estatus).toSet().toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey5.currentContext!, "estatus", listEstatusString);},
          )
        ],)
      ],),),
      const SizedBox(width: 15,),
    ];
  }
  List<UsuarioModels> filterList(List<UsuarioModels> usuarios, List<String> strings, String Function(UsuarioModels) getValue) {
    return usuarios.where((usuario) => strings.contains(getValue(usuario))).toList();
  }
  Widget viewCard(){
    return Container(height: size.width>1200? size.height-160 : size.height-230,
      decoration: BoxDecoration(color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child:RefreshIndicator(
        onRefresh: () async {
          getUsuarios();_isLoading = true;
          setState(() {});
          const timeLimit = Duration(seconds: 10);
          Timer(timeLimit, () {
            if(listUsuarios.isEmpty){
              setState(() {_isLoading = false;});
            }else{_isLoading = false;}
          });
        },
        color: theme.colorScheme.onPrimary, child: futureList(),
      ),
    );
  }
  Widget futureList(){
    return FutureBuilder<List<UsuarioModels>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: _buildLoadingIndicator(10));
        } else {
          final listProducto = snapshot.data ?? [];
          if (listProducto.isNotEmpty) {
            return Scrollbar(
              thumbVisibility: true, controller: scrollController2,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController2, itemCount: listUsuariosTemp.length,
                  itemBuilder: (context, index) {
                    return _card(listUsuariosTemp[index], index);
                  },
                ),
              ),
            );
          } else {
            if(_isLoading){
              return Center(child: _buildLoadingIndicator(10));
            }else{
              return SingleChildScrollView(child: Center(child: NoDataWidget()),);
            }
          }
        }
      },
    );
  }
  Widget _card(UsuarioModels usuario, int index) {
    return GestureDetector(onTap: (){
      if(usuario.selected){
        usuario.toggleSelected();
      }else{
        listUsuariosTemp.where((element) => element!= usuario).forEach((element) {
          if(element.selected){
            element.toggleSelected();
          }
        });
        usuario.toggleSelected();
      }
    },
      onDoubleTap: (){editUser(usuario);},
      onLongPress: (){if(usuario.estatus!){deleteUser(usuario);}
      else{reactiveUser(usuario);}},
      child: _pressed!=true? mySwipeCard(usuario, index) :
      mySwipeTable(usuario, index),);
  }

  Widget mySwipeCard(UsuarioModels usuario, int index){
    return ValueListenableBuilder<bool>(
        valueListenable: usuario.selectedNotifier,
        builder: (context, isSelected, child) {
          return MySwipeTileCard(verticalPadding: 2,
            colorBasico:!isSelected? theme.colorScheme.background:theme.colorScheme.secondary, iconColor: theme.colorScheme.onPrimary,
            containerRL: usuario.estatus == true? null : Row(children: [
              Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
            ],),
            colorRL: usuario.estatus == true? null : ColorPalette.ok,
            containerB: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
                SizedBox(width: 40, height: 35,
                  child: GestureDetector(
                      onTap: () {
                        showDialog(context: context,
                          builder: (context) => Dialog(
                            surfaceTintColor: theme.colorScheme.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
                            child: Container(
                              width: 200, height: 200, padding: const EdgeInsets.all(20.0),
                              child: Column(children: [
                                SizedBox(width: 140, height: 140,
                                  child: PhotoView(
                                    backgroundDecoration: BoxDecoration(color: theme.colorScheme.background),
                                    imageProvider: imageFromBase64String2(usuario.imagen),
                                  ),
                                ),
                                Text(usuario.userName, textAlign: TextAlign.center, )
                              ],),
                            ),
                          ),
                        );
                      }, child: imageFromBase64String(usuario.imagen)
                  ),
                ),
                SizedBox(width: width / 5, child: Text(usuario.userName, textAlign: TextAlign.left,)),
                SizedBox(width: width / 5, child: Text(usuario.nombre, textAlign: TextAlign.left,)),
                SizedBox(width: width / 5, child: Text(usuario.tipoUsuario.toUpperCase(), textAlign: TextAlign.left,)),
                SizedBox(width: width / 5, child: Text(usuario.nombreDepartamento??"", textAlign: TextAlign.left,)),
                SizedBox(width: width / 5, child: Text(usuario.estatus!= null?(usuario.estatus!? "ACTIVO" : "INACTIVO") : "", textAlign: TextAlign.left,
                  style: TextStyle(color: usuario.estatus==true? ColorPalette.ok : Colors.red),)),
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              ],
            ),
            onTapRL: () {
              if(usuario.estatus!){deleteUser(usuario);}
              else{reactiveUser(usuario);}
            }, onTapLR: () {editUser(usuario);},
          );
        });
  }
  Widget imageFromBase64String(String? base64String) {
    try {
      if(base64String == null){
        return const CircleAvatar(
          backgroundImage: AssetImage('assets/avatar.png'),
        );
      }else{
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        return Container(
            padding: const EdgeInsets.all(5.0), // Ajusta este valor para cambiar el tamaño de la imagen
            decoration: BoxDecoration(shape: BoxShape.circle,color: theme.colorScheme.secondary),
            child: Image.memory(uint8List)
        );
      }
    } catch (e) {
      return const CircleAvatar(
        backgroundImage: AssetImage('assets/avatar.png'),
      );
    }
  }
  ImageProvider imageFromBase64String2(String? base64String) {
    try {
      if(base64String == null){
        return const AssetImage('assets/avatarxl.png'); // Reemplaza esto con la ruta a tu imagen predeterminada
      } else {
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        return MemoryImage(uint8List);
      }
    } catch (e) {
      return const AssetImage('assets/avatarxl.png'); // Reemplaza esto con la ruta a tu imagen de error
    }
  }
  Widget mySwipeTable(UsuarioModels usuario, int index){
    return ValueListenableBuilder<bool>(
        valueListenable: usuario.selectedNotifier,
        builder: (context, isSelected, child) {
          return MySwipeTileCard(radius: 0, horizontalPadding: 2, verticalPadding: 0.5,
            colorBasico: !isSelected? (index%2 == 0? theme.colorScheme.background : (theme.colorScheme == GlobalThemData.lightColorScheme
                ? ColorPalette.backgroundLightColor
                : ColorPalette.backgroundDarkColor)):theme.colorScheme.secondary, iconColor: theme.colorScheme.onPrimary,
            containerRL: usuario.estatus == true? null: Row(children: [
              Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
            ],),
            colorRL: usuario.estatus == true? null : ColorPalette.ok,
            containerB: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
                SizedBox(width:width/5, child: Text(usuario.userName, textAlign: TextAlign.left, style: TextStyle(fontSize: 11),)),
                SizedBox(width:width/5, child: Text(usuario.nombre, textAlign: TextAlign.left, style: TextStyle(fontSize: 11),)),
                SizedBox(width:width/5, child: Text(usuario.tipoUsuario.toUpperCase(), textAlign: TextAlign.left, style: TextStyle(fontSize: 11),)),
                SizedBox(width:width/5, child: Text(usuario.nombreDepartamento??"", textAlign: TextAlign.left, style: TextStyle(fontSize: 11),)),
                SizedBox(width:width/5, child: Text(usuario.estatus!= null?(usuario.estatus!? "ACTIVO" : "INACTIVO") : "", textAlign: TextAlign.left,
                  style: TextStyle(color: usuario.estatus==true? ColorPalette.ok : Colors.red, fontSize: 11),)),
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              ],
            ),
            onTapRL: () {
              if(usuario.estatus!){deleteUser(usuario);}
              else{reactiveUser(usuario);}
            },
            onTapLR: () {editUser(usuario);},
          );
        });
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 65,child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
        color: theme.backgroundColor, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Shimmer.fromColors(
            baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
            ),
          ),
        )
    ),);
  }

  Widget tableEsqueleto(double width){
    return SizedBox(width: width, height: 30,child: Container(
        decoration: BoxDecoration(color: theme.backgroundColor, ),
        child: Shimmer.fromColors(
          baseColor: theme.primaryColor,
          highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
          const Color.fromRGBO(46, 61, 68, 1),
          enabled: true,
          child: Container(margin: const EdgeInsets.all(2),decoration:
          BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2),),
          ),
        ),
    ),);
  }
  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    List<Widget> buttonList2 = List.generate(n*3, (index) {
      return tableEsqueleto(size.width);
    });
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(padding: EdgeInsets.symmetric(horizontal: !_pressed? 5 : 1),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max,
              children: !_pressed? buttonList : buttonList2)
      ),
    );
  }
  void editUser(UsuarioModels user){
    if(editUserP){
      CustomAwesomeDialog(title: Texts.askEditConfirm, desc: 'Usuario: ${user.userName}', btnOkOnPress: () async {
        try{
          LoadingDialog.showLoadingDialog(context, Texts.loadingData);
          UsuarioPermisoController usuarioPermisoController = UsuarioPermisoController();
          //Lista de areas, seguir aqui
          List<AreaModels> listArea = await _getAreas();
          List<String> getEmpresasIDs = await _getEmpresasIDs(user);
          List<SubmoduloPermisos> listSubmoduloPermisos = await _getSubmoduloPermiso();
          List<UsuarioPermisoModels> listPermisos = await usuarioPermisoController.getUsuariosPermiso(user.idUsuario!);

          await Future.delayed(const Duration(milliseconds: 150), () {
            LoadingDialog.hideLoadingDialog(context);
          });
          print(user.puestoId);
          if(listSubmoduloPermisos.isNotEmpty){
            await myShowDialogScale(UserEditScreen(listSubmoduloPermisos: listSubmoduloPermisos, usuario: user,
              listUsuarioPermisos: listPermisos,areas: listArea,listEmpresas: listEmpresas,
              listEmpresasIDs: getEmpresasIDs,), context,width: size.width*.70);
            getUsuarios();
            resetSortOrder();
          }else {
            CustomAwesomeDialog(title: Texts.errorGettingData,
                desc: 'Error inesperado contacte a soporte', btnOkOnPress: () {},
                btnCancelOnPress: () {}).showError(context);
          }
        }catch(e){
          await Future.delayed(const Duration(milliseconds: 150), () {
            LoadingDialog.hideLoadingDialog(context);
          });
          ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
          String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
          CustomAwesomeDialog(title: Texts.errorGettingData,
              desc: error, btnOkOnPress: () {},
              btnCancelOnPress: () {}).showError(context);
          print('Error al obtener datos: $e');
        }
      },
        btnCancelOnPress: () {},).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void deleteUser(UsuarioModels user){
    if(deleteUserP){
      CustomAwesomeDialog(title: Texts.askInactiveUserConfirm, desc: 'Usuario: ${user.userName}', btnOkOnPress: () async {
        if(user.idUsuario != null) {
          LoadingDialog.showLoadingDialog(context, Texts.savingData);
          UsuarioController usuarioController = UsuarioController();
          bool delete = await usuarioController.deleteUsuario(user.idUsuario!);
          await Future.delayed(const Duration(milliseconds: 150), () {
            LoadingDialog.hideLoadingDialog(context);
          });
          if (delete) {
            CustomAwesomeDialog(title: Texts.userDeactivateSuccess, desc: '', btnOkOnPress: () {},
                btnCancelOnPress: () {}).showSuccess(context);
            user.estatus = false;
            setState(() {});
          } else {
            CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected,
                btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
          }
        }else {
          CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected,
              btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
        }
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void reactiveUser(UsuarioModels user){
    if(editUserP){
      CustomAwesomeDialog(title: Texts.askReactiveUserConfirm, desc: 'Usuario: ${user.userName}', btnOkOnPress: () async {
        if(user.idUsuario != null) {
          LoadingDialog.showLoadingDialog(context, Texts.savingData);
          UsuarioController usuarioController = UsuarioController();
          bool reactive = await usuarioController.reactiveUsuario(user.idUsuario!);
          await Future.delayed(const Duration(milliseconds: 150), () {
            LoadingDialog.hideLoadingDialog(context);
          });
          if (reactive) {
            CustomAwesomeDialog(title: Texts.reactiveUserSuccess, desc: '', btnOkOnPress: () {},
                btnCancelOnPress: () {}).showSuccess(context);
            user.estatus = true;
            setState(() {});
          } else {
            CustomAwesomeDialog(title: Texts.errorReactiveUser, desc: Texts.errorUnexpected, btnOkOnPress: () {},
                btnCancelOnPress: () {}).showError(context);
          }
        }else {
          CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected, btnOkOnPress: () {},
              btnCancelOnPress: () {}).showError(context);
        }
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  Future<void> getUsuarios() async{
    // Llama al método getUsuarios del usuarioProvider
    try{
      String empresaID = await userPreferences.getEmpresaId();
      selectedEmpresa = widget.empresas.firstWhere((element) => element.idEmpresa == empresaID).nombre;
      listUsuarios = [];
      listUsuarios = await usuarioController.getUsuariosActivos(empresaID);;
      List<String> departamentos = listUsuarios.map((usuario) => usuario.nombreDepartamento!).toList();
      listUsuariosString = listUsuarios.map((e) => e.userName).toList();
      listNombreString = listUsuarios.map((e) => e.nombre).toList();
      listTipoUsuarioString = listUsuarios.map((e) => e.tipoUsuario).toSet().toList();
      listDepartamentoString = listUsuarios.map((e) => e.nombreDepartamento!).toSet().toList();
      listEstatusString = listUsuarios.map((e) => e.estatus!= true? "ACTIVO" : "INACTIVO").toSet().toList();
      resetSortOrder();
      // Elimina los duplicados
      departamentos = departamentos.toSet().toList();
      itemsDepartments = departamentos;
      aplicarFiltro();

      Future.delayed(const Duration(milliseconds: 150), () {
        print("Usuarios descargados");
        setState(() {});
      });
    }catch(e){
      String error = await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomSnackBar.showErrorSnackBar(context, '${Texts.errorGettingData}. $error');
      print('Error al obtener usuarios: $e');
    }
  }
  Future<List<UsuarioModels>> _getDatos() async {
    try {
      return listUsuariosTemp;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }
  Widget _bodyPortrait(){
    return const Column(children: [Text("data")],);
  }
  Future<List<SubmoduloPermisos>> _getSubmoduloPermiso() async {
    List<SubmoduloPermisos> listPermisos = [];
    try {
      PermisoController permisoController = PermisoController();
      listPermisos = await permisoController.getPermisoSubmodulos();
    } catch (e) {
      print('Error al obtener usuarios: $e');
    }
    return listPermisos;
  }
  Future<List<AreaModels>> _getAreas() async {
    List<AreaModels> listAreas = [];
    try {
      AreaController areaController = AreaController();
      listAreas = await areaController.getAreasAgrupadas();
    } catch (e) {
      print('Error al obtener area: $e');
    }
    return listAreas;
  }
  Future<List<String>> _getEmpresasIDs(UsuarioModels usuarioModels) async {
    List<String> listEmpresasIDs = [];
    try {
      listEmpresasIDs = await usuarioController.getEmpresasIDs(usuarioModels.idUsuario!);
      print(listEmpresasIDs.first);
    } catch (e) {
      print('Error al obtener empresas: $e');
    }
    return listEmpresasIDs;
  }
  Future<void> addUser() async {
    if(addUserP){
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      List<AreaModels> listArea = await _getAreas();
      List<SubmoduloPermisos> listSubmoduloPermisos = await _getSubmoduloPermiso();
      AjustesGeneralesController ajustesGeneralesController = AjustesGeneralesController();
      List<bool> listAjustes = await ajustesGeneralesController.getAjustesUsuarios();
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      var result = await myShowDialogScale(UserRegistrationScreen(listSubmoduloPermisos: listSubmoduloPermisos,
        areas: listArea, listEmpresas: listEmpresas, listAjustesUsuarios: listAjustes,), context,width: size.width*.70);
      if(result == true){
        getUsuarios();
      }
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for(int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId == Texts.permissionsUserAdd) {
        addUserP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsUserEdit){
        editUserP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsUserDelete) {
        deleteUserP = true;
      }
    }
  }
  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    List<String> list = getValue2(listUsuarios, column, column != "userName" && column != "nombre");
    List<String> listSelected = getValue2(listUsuariosTemp, column, column != "userName" && column != "nombre");
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    var result = await showMenu(
      context: context, position: position, elevation: 8.0,
      constraints: const BoxConstraints(maxWidth: 274.0), surfaceTintColor: Colors.transparent,
      color: theme.colorScheme == GlobalThemData.lightColorScheme? const Color(0xFFF8F8F8):const Color(0xFF303030),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, padding: EdgeInsets.zero,
            child:MyPopupMenuButton(items: list, selectedItems: listSelected,)
        ),
      ],
    );
    await aplicarFiltro2(result, column, listA);
  }
  String getValue(UsuarioModels usuario, String column) {
    switch (column) {
      case "userName":
        return usuario.userName;
      case "nombre":
        return usuario.nombre;
      case "tipoUsuario":
        return usuario.tipoUsuario;
      case "departamento":
        return usuario.nombreDepartamento!;
      case "estatus":
        return usuario.estatus! ? "ACTIVO" : "INACTIVO";
      default:
        return '';
    }
  }
  List<String> getValue2(List<UsuarioModels> usuarios, String column, bool removeDuplicates) {
    List<String> list = usuarios.map((usuario) {
      switch (column) {
        case "userName":
          return usuario.userName;
        case "nombre":
          return usuario.nombre;
        case "tipoUsuario":
          return usuario.tipoUsuario;
        case "departamento":
          return usuario.nombreDepartamento!;
        case "estatus":
          return usuario.estatus! ? "ACTIVO" : "INACTIVO";
        default:
          return '';
      }
    }).toList();
    return removeDuplicates ? list.toSet().toList() : list;
  }
  Future<void> aplicarFiltro2(String? result, String column, List<String> listA) async {
    if(result != null){
      if(result == "AZ" || result == "ZA") {
        _sortOrder = result == "AZ" ? 1 : 2;
        applySort(column);
      }else if(result == "ClearAll"){
        _searchController.clear();
        listA.clear();
        listA.addAll(getValue2(listUsuarios, column, column != "userName" && column != "nombre"));
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
      }
      setState(() {});
    }
  }
  void sortList(List<UsuarioModels> usuarios, String Function(UsuarioModels) getValue, int sortOrder) {
    usuarios.sort((a, b) {
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare : -compare;
    });
  }
  void applySort(String column) {
    // Establecer todos los valores en 0
    sortOrders.updateAll((key, value) => 0);
    // Actualizar solo el valor que necesitas
    sortOrders[column] = _sortOrder;
    sortList(listUsuariosTemp, (usuario) => getValue(usuario, column), _sortOrder);
  }
  void applySort2(){
    sortOrders.forEach((key, value) {
      if (value != 0) {
        listUsuariosTemp.sort(sortFunctions[key]?[value]);
      }
    });
  }
  void orderBy(String s) {
    sortOrders[s] = sortOrders[s] == 0 || sortOrders[s] == 2 ? 1 : 2;
    sortOrders.updateAll((key, value) {
      if(key != s) {
        return 0;
      } else {
        return sortOrders[key]?? 0;
      }
    });
    applySort2();
    setState(() {});
  }
  void resetSortOrder(){
    sortOrders.updateAll((key, value) => 0);
  }
  Future<void> resetList() async {
    listUsuariosTemp = filterList(listUsuarios, listUsuariosString, (usuario) => usuario.userName);
    listUsuariosTemp = filterList(listUsuariosTemp, listNombreString, (usuario) => usuario.nombre);
    listUsuariosTemp = filterList(listUsuariosTemp, listTipoUsuarioString, (usuario) => usuario.tipoUsuario);
    listUsuariosTemp = filterList(listUsuariosTemp, listDepartamentoString, (usuario) => usuario.nombreDepartamento!);
    listUsuariosTemp = filterList(listUsuariosTemp, listEstatusString, (usuario) => usuario.estatus! ? "ACTIVO" : "INACTIVO");
  }
}
class CustomInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^(?!.*[,-]{2})[0-9]+([,-][0-9]+)*$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}