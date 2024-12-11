import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/monedaController.dart';
import 'package:tickets/pages/Compras/pages/Proveedores/proveedor_registration_screen.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/ComprasController/ProveedorController/proveedorController.dart';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/models/ComprasModels/ProveedorModels/proveedor.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/monedas.dart';
import '../../../../shared/actions/handleException.dart';
import '../../../../shared/actions/key_raw_listener.dart';
import '../../../../shared/actions/my_show_dialog.dart';
import '../../../../shared/pdf/pw_pdf/generate_material_report.dart';
import '../../../../shared/utils/color_palette.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/utils/user_preferences.dart';
import '../../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../../shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/appBar/my_appBar.dart';
import '../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../shared/widgets/error/customNoData.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

const kDefaultArcheryTriggerOffset = 100.0;
class ProveedoresScreen extends StatefulWidget {
  static String id = 'ProveedoresScreen';
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  List<ProveedorModels> listProveedores = [];
  BuildContext context;
  ProveedoresScreen({super.key, required this.listUsuarioPermisos, required this.context});

  @override
  _ProveedorScreenState createState() => _ProveedorScreenState();
}

class _ProveedorScreenState extends State<ProveedoresScreen> {
  ScrollController scrollController = ScrollController(), scrollController2 = ScrollController();
  late Size size; late ThemeData theme; late BuildContext homeContext;
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final buttonKey1 = GlobalKey(), buttonKey2 = GlobalKey(), _key = GlobalKey(), buttonKey3 = GlobalKey(), buttonKey4 = GlobalKey(), buttonKey5 = GlobalKey(), buttonKey6 = GlobalKey();
  double width = 0; int _sortOrder = 0;
  List<String> selectedItems = [];
  List<ProveedorModels> listProveedores = [], listProveedoresTemp = [];
  List<String> listNombreString = [], listRFCString = [], listTelefonoString = [], listColoniaString = [], listCiudadString = [], listEstatusString = [];
  bool _isLoading = true, _pressed = false, addPro = false, editPro = false, deletePro = false;
  UserPreferences userPreferences = UserPreferences();
  Map<String, int> _sortOrders = {
    "nombre": 0,
    "rfc": 0,
    "telefono": 0,
    "colonia": 0,
    "ciudad": 0,
    "estatus": 0,
  };

  Map<String, Map<int, int Function(ProveedorModels, ProveedorModels)>> sortFunctions = {
    "nombre": {
      1: (ProveedorModels a, ProveedorModels b) => a.nombre.compareTo(b.nombre),
      2: (ProveedorModels a, ProveedorModels b) => b.nombre.compareTo(a.nombre)},
    "rfc": {
      1: (ProveedorModels a, ProveedorModels b) => a.rfc.compareTo(b.rfc),
      2: (ProveedorModels a, ProveedorModels b) => b.rfc.compareTo(a.rfc)},
    "telefono": {
      1: (ProveedorModels a, ProveedorModels b) => a.telefono.compareTo(b.telefono),
      2: (ProveedorModels a, ProveedorModels b) => b.telefono.compareTo(a.telefono)},
    "colonia": {
      1: (ProveedorModels a, ProveedorModels b) => a.colonia.compareTo(b.colonia),
      2: (ProveedorModels a, ProveedorModels b) => b.colonia.compareTo(a.colonia)},
    "ciudad": {
      1: (ProveedorModels a, ProveedorModels b) => a.ciudad.compareTo(b.ciudad),
      2: (ProveedorModels a, ProveedorModels b) => b.ciudad.compareTo(a.ciudad)},
    "estatus": {
      1: (ProveedorModels a, ProveedorModels b) => (a.estatus == true ? "ACTIVO" : "INACTIVO").compareTo(b.estatus! == true ? "ACTIVO" : "INACTIVO"),
      2: (ProveedorModels a, ProveedorModels b) => (b.estatus == true ? "ACTIVO" : "INACTIVO").compareTo(a.estatus! == true ? "ACTIVO" : "INACTIVO")},
  };

  @override
  void initState() {
    getProveedores();
    getPermisos();
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if(listProveedores.isEmpty){
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
    _searchController.dispose();
    scrollController.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context); width = size.width-350;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.f4 : () async {addProveedor();},
      LogicalKeyboardKey.f5 : () async {
        getProveedores();
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if(listProveedores.isEmpty){
            setState(() {
              _isLoading = false;
            });
          }else{
            _isLoading = false;
          }
        });
      },
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey:_key,
        child: Scaffold(
          appBar: size.width > 600? MyCustomAppBarDesktop(title:"Proveedores",context: widget.context,backButton: false,)
              : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: size.width> 600? _bodyLandscape() : _bodyPortrait(),
            ),
          ),
        ));
  }
  Widget _bodyLandscape(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Row(children: _filtros(),),
              const SizedBox(width: 10,),
            ],),
            const SizedBox(width: 10,),
            Row(children: [
              _customButtonAdd(),
              const SizedBox(width: 10,),
              _customButtonEdit(),
              const SizedBox(width: 10,),
              _customButtonDelete()
            ],)
          ],),
        const SizedBox(height: 5,),
        encabezados(),
        viewCard()
      ],
    );
  }

  Widget buildPopup({Size? viewSize}) {
    return SingleChildScrollView(
      key: const ValueKey<String>('datagrid_filtering_scrollView'),
      child: Container(
        width: 274.0, color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.sort), title: Text('Sort Ascending'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.sort), title: Text('Sort Descending'),
              onTap: () {},
            ),
            const Divider(indent: 8.0, endIndent: 8.0),
            ListTile(
              leading: Icon(Icons.clear),
              title: Text('Clear Filter'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.filter_alt),
              title: Text('Advanced Filter'),
              onTap: () {},
            ),
            const Divider(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('OK'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text('Cancel'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _customButtonAdd(){
    return Tooltip(message: "Agregar Proveedor", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: (){addProveedor();}, icon: const Icon(IconLibrary.iconAdd),
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
    return Tooltip(message: "Editar proveedor", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          ProveedorModels? proveedorSelected = await getProveedorSelected();
          if(proveedorSelected!=null) {
           // editUser(proveedorSelected);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, "No fue posible editar", "Seleccione un usuario para continuar");
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
    return Tooltip(message: "Desactivar proveedor", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          ProveedorModels? proveedorSelected = await getProveedorSelected();
          if(proveedorSelected!=null) {
           // deleteUser(proveedorSelected);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, "No fue posible desactivar", "Seleccione un usuario para continuar");
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


  void aplicarFiltro() {
    listProveedoresTemp = List.from(listProveedores);
    if(_searchController.text.isNotEmpty){
      listProveedoresTemp = listProveedoresTemp.where((proveedor) =>
      proveedor.nombre.toLowerCase().contains(_searchController.text.toLowerCase())
          || "${proveedor.nombre} ${proveedor.rfc} ${proveedor.telefono}".
      toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }
    setState(() {});
  }

  Future<ProveedorModels?> getProveedorSelected() async{
    ProveedorModels? proveedorSelected;
    try {proveedorSelected = listProveedoresTemp.firstWhere((element) => element.selected);}
    catch (e) {proveedorSelected = null;}
    return proveedorSelected;
  }

  List<Widget> _filtros(){
    return [
      SizedBox(width: 250, child:
      MyTextfieldIcon(labelText: "Buscar", textController: _searchController, focusNode: _focusNode,
        suffixIcon: const Icon(IconLibrary.iconSearch),floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold),backgroundColor: theme.colorScheme.secondary,formatting: false,
        colorLine: theme.colorScheme.primary, onChanged: (value){
          aplicarFiltro();
          setState(() {
            FocusScope.of(context).requestFocus(_focusNode);
          });
        },
      ),),
      const SizedBox(width: 10,),
      _tableViewButton(),
    ];
  }

  Widget _tableViewButton() {
    return Tooltip(child: SizedBox(
      height: 56, width: 45,
      child: IconButton(
        onPressed: (){
          _pressed = !_pressed;
          setState((){});
        },
        icon: _pressed ?  const Icon(Icons.list)  : const Icon(Icons.table_view),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
          shape: MaterialStateProperty.all <RoundedRectangleBorder> (
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),),
      ),
    ),message: _pressed? "Mostrar vista de tarjeta" : "Mostrar vista de tabla",
      waitDuration: const Duration(milliseconds: 500),
    );
  }


  Widget encabezados(){
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

  List<Widget> encabezadosCard() {
    return [
      const SizedBox(width: 15),
      if (!_pressed) ...[
        const SizedBox(width: 40),],
      SizedBox(width: width/6,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Nombre", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["nombre"]!)), onTap: () {orderBy("nombre");},),
          InkWell(key: buttonKey1, child: Icon(Icons.filter_alt,
            color: listNombreString.length != listProveedores.map((e) => e.nombre).toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey1.currentContext!, "nombre", listNombreString);},)
        ],)
      ],),),
      SizedBox(width: width/6, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("RFC", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["rfc"]!)), onTap: () {orderBy("rfc");},),
          InkWell(key: buttonKey2, child: Icon(Icons.filter_alt,
            color: listRFCString.length != listProveedores.map((e) => e.rfc).toSet().toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey2.currentContext!, "rfc", listRFCString);},)
        ],)
      ],),),
      SizedBox(width: width/6, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Telefono",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["telefono"]!)), onTap: () {orderBy("telefono");},),
          InkWell(key: buttonKey3, child: Icon(Icons.filter_alt,
            color: listTelefonoString.length != listProveedores.map((e) => e.telefono).toSet().toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey3.currentContext!, "telefono", listTelefonoString);},)
        ],)
      ],),),
      SizedBox(width: width/6, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Colonia",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["colonia"]!)), onTap: () {orderBy("colonia");},),
          InkWell(key: buttonKey4, child: Icon(Icons.filter_alt,
            color: listColoniaString.length != listProveedores.map((e) => e.colonia).toSet().toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey4.currentContext!, "colonia", listColoniaString);},)
        ],)
      ],),),
      SizedBox(width: width/6, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Ciudad",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["ciudad"]!)), onTap: () {orderBy("ciudad");},),
          InkWell(key: buttonKey5, child: Icon(Icons.filter_alt,
            color: listCiudadString.length != listProveedores.map((e) => e.ciudad).toSet().toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey5.currentContext!, "ciudad", listCiudadString);},)
        ],)
      ],),),
      SizedBox(width: width/6, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/12,child: const Text("Estatus",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(child: Icon(_sortIcon(_sortOrders["estatus"]!)), onTap: () {orderBy("estatus");},),
          InkWell(key: buttonKey6, child: Icon(Icons.filter_alt,
            color: listEstatusString.length != listProveedores.map((e) => e.estatus).toSet().toList().length ? ColorPalette.informationColor
                 : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey6.currentContext!, "estatus", listEstatusString);},
          )],)
      ],),),
          const SizedBox(width: 15),
    ];
  }
  Widget viewCard(){
    return Container(height: size.width>1200? size.height-160 : size.height-230,
      decoration: BoxDecoration(color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child:RefreshIndicator(
          onRefresh: () async {
            getProveedores();_isLoading = true;
            setState(() {});
            const timeLimit = Duration(seconds: 10);
            Timer(timeLimit, () {
              if(listProveedores.isEmpty){
                setState(() {
                  _isLoading = false;
                });
              }else{
                _isLoading = false;
              }
            });
          },
          color: theme.colorScheme.onPrimary,
        child: futureList(),
      ),
    );
  }

  Widget futureList(){
    return FutureBuilder<List<ProveedorModels>>(
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
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController2, itemCount: listProveedoresTemp.length,
                  itemBuilder: (context, index) {
                    return _card(listProveedoresTemp[index], index);
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

  Widget _card(ProveedorModels proveedor, int index) {
    return GestureDetector(onTap: (){
      if(proveedor.selected){
        proveedor.toggleSelected();
      }else{
        listProveedoresTemp.where((element) => element!= proveedor).forEach((element) {
          if(element.selected){
            element.toggleSelected();
          }
        });
        proveedor.toggleSelected();
      }
    },
      onDoubleTap: (){
      //editUser(proveedor);
      },
      onLongPress: (){if(proveedor.estatus!){
        //deleteUser(proveedor);
      }else{
        //reactiveUser(proveedor);
        }},
      child: _pressed!=true? mySwipeCard(proveedor, index) :
      mySwipeTable(proveedor, index),);
  }

  Widget mySwipeCard(ProveedorModels proveedor, int index){
    return GestureDetector(child:
    MySwipeTileCard(verticalPadding: 2,
        colorBasico:theme.colorScheme.background, iconColor: theme.colorScheme.onPrimary,
        containerRL: proveedor.estatus == true? null: Row(children: [
          Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
        ],),
        colorRL: proveedor.estatus == true? null : ColorPalette.ok,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Agrega bordes redondeados
                      ),
                      child: Container(
                        width: 100, height: 200, padding: const EdgeInsets.all(20.0),
                        child: Column(children: [
                          SizedBox(width: 140, height: 140,
                            child: PhotoView(
                              backgroundDecoration: BoxDecoration(color: theme.colorScheme.background),
                              imageProvider: const AssetImage('assets/proveedores2.png'),
                            ),
                          ),
                          Text(proveedor.nombre, textAlign: TextAlign.center, )
                        ],),
                      ),
                    ),
                  );
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/proveedores2.png'),
                ),
              ),
            ),
            SizedBox(width: width/6, child: Text(proveedor.nombre.trim()!=""? proveedor.nombre :"Sin Nombre", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
            SizedBox(width: width/6, child: Text(proveedor.rfc.trim()!=""? proveedor.rfc :"Sin RFC", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
            SizedBox(width: width/6, child: Text(proveedor.telefono.trim()!=""? proveedor.telefono :"Sin Telefono", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
            SizedBox(width: width/6, child: Text(proveedor.colonia.trim()!=""? proveedor.colonia :"Sin Colonia", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
            SizedBox(width: width/6, child: Text(proveedor.ciudad.trim()!=""? proveedor.ciudad :"Sin Ciudad", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
            SizedBox(width: width/6, child: Text(proveedor.estatus!= null?(proveedor.estatus!? "ACTIVO" : "INACTIVO") : "", textAlign: TextAlign.left,
              style: TextStyle(color: proveedor.estatus==true? ColorPalette.ok : Colors.red),)),
            const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
          ],
        ),
        onTapRL: () {
          // if(proveedor.estatus!){deleteUser(proveedor);}
          // else{reactiveUser(proveedor);}
        },
        onTapLR: () {}//{editUser(usuario);},
    ),
      onDoubleTap: (){
        generateAddProveedoresReport(proveedor, context);
      },);
  }

  Widget mySwipeTable(ProveedorModels proveedor, int index){
    return MySwipeTileCard(
      radius: 0, horizontalPadding: 2, verticalPadding: 0.5,
      colorBasico: index%2 == 0? theme.colorScheme.background : (theme.colorScheme == GlobalThemData.lightColorScheme
          ? ColorPalette.backgroundLightColor
          : ColorPalette.backgroundDarkColor), iconColor: theme.colorScheme.onPrimary,
      containerRL: proveedor.estatus == true? null: Row(children: [
        Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
      ],),
      colorRL: proveedor.estatus == true? null : ColorPalette.ok,
      containerB: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
          SizedBox(width: width/6, child: Text(proveedor.nombre.trim()!=""? proveedor.nombre :"Sin Nombre", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
          SizedBox(width: width/6, child: Text(proveedor.rfc.trim()!=""? proveedor.rfc :"Sin RFC", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
          SizedBox(width: width/6, child: Text(proveedor.telefono.trim()!=""? proveedor.telefono :"Sin Telefono", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
          SizedBox(width: width/6, child: Text(proveedor.colonia.trim()!=""? proveedor.colonia :"Sin Colonia", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
          SizedBox(width: width/6, child: Text(proveedor.ciudad.trim()!=""? proveedor.ciudad :"Sin Ciudad", textAlign: TextAlign.left,style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 11 ))),
          SizedBox(width: width/6, child: Text(proveedor.estatus!= null?(proveedor.estatus!? "ACTIVO" : "INACTIVO") : "", textAlign: TextAlign.left,
            style: TextStyle(color: proveedor.estatus==true? ColorPalette.ok : Colors.red, fontSize: 11),)),
          const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
        ],
      ),
      onTapRL: () {
      },
      onTapLR: () {
    },
    );
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
            BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            ),
          ),
        )
    ),);
  }
  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max,
              children: buttonList)
      ),
    );
  }

  Future<void> getProveedores() async{
    // Llama al método getProveedores del proveedoresProvider
    try{
      print("Obteniendo proveedores...");
      listProveedores = [];
      ProveedorController proveedorController = ProveedorController();
      List<ProveedorModels> proveedor = await proveedorController.getProveedores() ;
        setState(() {
          listProveedores = proveedor;
          listProveedoresTemp = List.from(listProveedores);
          listNombreString = getValue2(listProveedores, "nombre", false).toSet().toList();
          listRFCString = getValue2(listProveedores, "rfc", false).toSet().toList();
          listTelefonoString = getValue2(listProveedores, "telefono", true).toSet().toList();
          listColoniaString = getValue2(listProveedores, "colonia", true).toSet().toList();
          listCiudadString = getValue2(listProveedores, "ciudad", true).toSet().toList();
          listEstatusString = listProveedores.map((e) => e.estatus!= true? "ACTIVO" : "INACTIVO").toSet().toList();

          aplicarFiltro();
        });
    }catch(e){
      String error = await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomSnackBar.showErrorSnackBar(context, '${Texts.errorGettingData}. $error');
      print('Error al obtener proveedores: $e');
    }
  }

  Future<List<ProveedorModels>> _getDatos() async {
    try {
      return listProveedoresTemp;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  Widget _bodyPortrait(){
    return const Column(children: [
      Text("data")
    ],);
  }

  Future<void> addProveedor() async {
    if(addPro){
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      MonedaController monedaController = MonedaController();
      List<MonedaModels> monedas = await monedaController.getMonedasActivos();
      await myShowDialogScale(ProveedorRegistrationScreen(monedas: monedas,), context,width: size.width * 0.72);
      getProveedores();
      LoadingDialog.hideLoadingDialog(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }

  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    List<String> list = getValue2(listProveedores, column, column != "nombre" && column != "rfc");
    List<String> listSelected = getValue2(listProveedoresTemp, column, column != "nombre" && column != "rfc");
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
      context: context, position: position,
      constraints: const BoxConstraints(maxWidth: 274.0), surfaceTintColor: Colors.transparent,
      color: theme.colorScheme == GlobalThemData.lightColorScheme? Color(0xFFF8F8F8):Color(0xFF303030),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, padding: EdgeInsets.zero,
            child:MyPopupMenuButton(items: list, selectedItems: listSelected,)
        ),
      ],
      elevation: 8.0,
    );
    await aplicarFiltro2(result, column, listA);
  }

  String getValue(ProveedorModels proveedor, String column) {
    switch (column) {
      case "nombre":
        return proveedor.nombre;
      case "rfc":
        return proveedor.rfc;
      case "telefono":
        return proveedor.telefono;
      case "colonia":
        return proveedor.colonia;
      case "ciudad":
        return proveedor.ciudad;
      case "estatus":
        return proveedor.estatus! ? "ACTIVO" : "INACTIVO";
      default:
        return '';
    }
  }

  List<String> getValue2(List<ProveedorModels> proveedores, String column, bool removeDuplicates) {
    List<String> list = proveedores.map((proveedor) {
      switch (column) {
        case "nombre":
          return proveedor.nombre;
        case "rfc":
          return proveedor.rfc;
        case "telefono":
          return proveedor.telefono;
        case "colonia":
          return proveedor.colonia;
        case "ciudad":
          return proveedor.ciudad;
        case "estatus":
          return proveedor.estatus! ? "ACTIVO" : "INACTIVO";
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
        listA.addAll(getValue2(listProveedores, column, column != "nombre" && column != "rfc"));
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
      }
      setState(() {});
    }
  }
  void sortList(List<ProveedorModels> proveedores, String Function(ProveedorModels) getValue, int sortOrder) {
    proveedores.sort((a, b) {
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare : -compare;
    });
  }

  void applySort(String column) {
    // Establecer todos los valores en 0
    _sortOrders.updateAll((key, value) => 0);
    // Actualizar solo el valor que necesitas
    _sortOrders[column] = _sortOrder;
    sortList(listProveedoresTemp, (proveedor) => getValue(proveedor, column), _sortOrder);
  }

  void applySort2(){
    _sortOrders.forEach((key, value) {
      if (value != 0) {
        listProveedoresTemp.sort(sortFunctions[key]?[value]);
      }
    });
  }

  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for(int i = 0; i < listUsuarioPermisos.length; i++) {
      //
      if(listUsuarioPermisos[i].permisoId == Texts.permissionsProveedorAdd) {
        addPro = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsProveedorEdit) {
        editPro = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsProveedorDelete) {
        deletePro = true;
      }
    }
  }

  void orderBy(String s) {
    _sortOrders[s] = _sortOrders[s] == 0 || _sortOrders[s] == 2 ? 1 : 2;
    _sortOrders.updateAll((key, value) {
      if(key != s) {
        return 0;
      } else {
        return _sortOrders[key]?? 0;
      }
    });
    applySort2();
    setState(() {});
  }

  Future<void> resetList() async {
    listProveedoresTemp = filterList(listProveedores, listNombreString, (proveedor) => proveedor.nombre);
    listProveedoresTemp = filterList(listProveedoresTemp, listRFCString, (proveedor) => proveedor.rfc);
    listProveedoresTemp = filterList(listProveedoresTemp, listTelefonoString, (proveedor) => proveedor.telefono);
    listProveedoresTemp = filterList(listProveedoresTemp, listColoniaString, (proveedor) => proveedor.colonia);
    listProveedoresTemp = filterList(listProveedoresTemp, listCiudadString, (proveedor) => proveedor.ciudad);
    listProveedoresTemp = filterList(listProveedoresTemp, listEstatusString, (proveedor) => proveedor.estatus! ? "ACTIVO" : "INACTIVO");
    applySort2();
  }
  List<ProveedorModels> filterList(List<ProveedorModels> proveedores, List<String> strings, String Function(ProveedorModels) getValue) {
    return proveedores.where((proveedor) => strings.contains(getValue(proveedor))).toList();
  }
}
