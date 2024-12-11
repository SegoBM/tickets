import 'dart:async';
import 'dart:convert';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ComprasController/ServiciosProductosController/serviciosProductosController.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/serviciosProductos.dart';
import 'package:tickets/pages/Compras/pages/ServiciosProductos/serviciosProductos_edit_screen.dart';
import 'package:tickets/pages/Compras/pages/ServiciosProductos/serviciosProductos_registration_screen.dart';
import 'package:tickets/pages/Settings/GeneralSettings/widgets_settings.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../controllers/ConfigControllers/GeneralSettingsController/monedaController.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/monedas.dart';
import '../../../../models/ConfigModels/usuarioPermiso.dart';
import '../../../../shared/actions/handleException.dart';
import '../../../../shared/actions/my_show_dialog.dart';
import '../../../../shared/utils/color_palette.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/appBar/my_appBar.dart';
import '../../../../shared/widgets/buttons/dropdown_decoration.dart';
import '../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/error/customNoData.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

const kDefaultArcheryTriggerOffset = 100.0;
class ServiciosProductosScreen extends StatefulWidget {
  static String id = 'ServiciosProductosScreen';
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  BuildContext context;
  ServiciosProductosScreen({super.key, required this.listUsuarioPermisos, required this.context});

  @override
  _ServiciosProductosScreenState createState() => _ServiciosProductosScreenState();
}

class _ServiciosProductosScreenState extends State<ServiciosProductosScreen>{
  late Size size; late ThemeData theme;
  final FocusNode _focusNode = FocusNode();
  final _searchController = TextEditingController();
  ScrollController scrollController = ScrollController(), scrollController2 = ScrollController();
  double width = 0; int _sortOrder = 0;
  List<String> listCodigo = [], listDescripcion=[], listClasificacion=[], listCategoria=[];
  List<int> listEstatus = [];
  List<ServiciosProductosModels> listServiciosProductos = [], listServiciosProductosTemp = [];
  bool _isLoading = true, _pressed = false;
  bool addServicioProducto2 = false, editServicioProducto2 = false, deleteServicioProducto2 = false;
  List<String> listEstatus2 = ['INACTIVO', 'ACTIVO', 'BLOQUEADO', 'FUERA DE LÍNEA'];
  final _key=GlobalKey(), buttonKey1 = GlobalKey(), buttonKey2 = GlobalKey(), buttonKey3 = GlobalKey(), buttonKey4 = GlobalKey(), buttonKey5 = GlobalKey();
  late WidgetsSettings ws;
  late String selectedEstatus;
  ServiciosProductosController serviciosProductosController = ServiciosProductosController();
  Map<int, String> estatusTextos = {
    0: "INACTIVO",
    1: "ACTIVO",
    2: "BLOQUEADO",
    3: "FUERA DE LÍNEA"
  };

  Map<int, Color> estatusColores = {
    0: Colors.red,
    1: const Color.fromARGB(255, 25, 180, 22),
    2: Colors.orange,
    3: const Color.fromARGB(255, 235, 92, 10),
  };

  Map<String, int> _sortOrders = {
    "codigo": 0,
    "descripcion": 0,
    "clasificacion": 0,
    "categoria": 0,
    "estatus": 0,
  };

  Map<String, Map<int, int Function(ServiciosProductosModels, ServiciosProductosModels)>> sortFunctions = {
    "codigo" : {
      1: (ServiciosProductosModels a, ServiciosProductosModels b) => a.codigo.compareTo(b.codigo),
      2: (ServiciosProductosModels a, ServiciosProductosModels b) => b.codigo.compareTo(a.codigo)
    },
    "descripcion": {
      1: (ServiciosProductosModels a, ServiciosProductosModels b) => a.descripcion.compareTo(b.descripcion),
      2: (ServiciosProductosModels a, ServiciosProductosModels b) => b.descripcion.compareTo(a.descripcion)
    },
    "clasificacion": {
      1: (ServiciosProductosModels a, ServiciosProductosModels b) => a.clasificacion.compareTo(b.clasificacion),
      2: (ServiciosProductosModels a, ServiciosProductosModels b) => b.clasificacion.compareTo(a.clasificacion)
    },
    "categoria": {
      1: (ServiciosProductosModels a, ServiciosProductosModels b) => a.categoria.compareTo(b.categoria),
      2: (ServiciosProductosModels a, ServiciosProductosModels b) => b.categoria.compareTo(a.categoria)
    },
    "estatus": {
      1: (ServiciosProductosModels a, ServiciosProductosModels b) => a.estatus.compareTo(b.estatus),
      2: (ServiciosProductosModels a, ServiciosProductosModels b) => b.estatus.compareTo(a.estatus),
    }
  };

  @override
  void initState() {
    selectedEstatus = listEstatus2[0];
    getServiciosProductos();
    getPermisos();
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if (listServiciosProductos.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
    ws = WidgetsSettings(theme);
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
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    width = size.width - 350;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()>{
      LogicalKeyboardKey.f4: () async {addServiciosProductos();},
      LogicalKeyboardKey.f5: () async {
        getServiciosProductos();
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if (listServiciosProductos.isEmpty) {
            setState(() {
              _isLoading = false;
            });
          } else {
            _isLoading = false;
          }
        });
      },
      LogicalKeyboardKey.f8: () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _key,
        child: Scaffold(
          appBar: size.width > 600 ?
          MyCustomAppBarDesktop(title: "Servicios y Productos", context: widget.context,
            backButton: false,) : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: size.width > 600 ? _bodyLandscape() : _bodyPortrait(),
            ),
          ),
        ));
   }

  Widget _bodyLandscape() {
    return Column( crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Row(children:  _filtros(),),
              const SizedBox(width: 10,),
            ],),
            const SizedBox(width: 10,),
            Row( children: [
              _customButtonAdd(),
              const SizedBox(width: 10,),
              _customButtonEdit(),
              const SizedBox(width: 10,),
              _customButtonChangeEstatus(),
            ],),
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
              leading: Icon(Icons.clear), title: Text('Clear Filter'), onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.filter_alt), title: Text('Advanced Filter'),  onTap: () {},
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

  Widget _customButtonAdd() {
    return Tooltip(message: "Agregar servicio/producto", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: (){addServiciosProductos();}, icon: const Icon(IconLibrary.iconAdd),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }

  Future<ServiciosProductosModels?> getServicioProductoSelected() async{
    ServiciosProductosModels? servicioSelected;
    try {
      servicioSelected = listServiciosProductosTemp.firstWhere((element) => element.selected);
    } catch (e) {
      servicioSelected = null;
    }
    return servicioSelected;
  }

  Widget _customButtonEdit() {
    return Tooltip(message: "Editar servicio/producto", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          ServiciosProductosModels? servicioSelected = await getServicioProductoSelected();
          if(servicioSelected != null){
            editServiciosProductos(servicioSelected);
          } else {
            MyCherryToast.showWarningSnackBar(context, theme, "No fue posible editar", "Seleccione un servicio o producto para poder continuar");
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

  Widget _customButtonChangeEstatus(){
     return Tooltip(message: "Cambiar estatus", waitDuration: const Duration(milliseconds:500),
      child: SizedBox(height:50, width:50,
        child: IconButton(onPressed:() async {
          ServiciosProductosModels ? productosSelected = await getServicioProductoSelected();
          if (productosSelected != null) {
            cambiarEstatus(productosSelected);
          } else {
            MyCherryToast.showWarningSnackBar(
                context, theme, "Seleccione un servicio o producto");
          }
          },icon: const Icon(Icons.wifi_protected_setup_sharp,),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color> (theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets> (const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
          ),
      ),);
  }

  void cambiarEstatus(ServiciosProductosModels serviciosProductosModels){
   showDialog(context: context, barrierDismissible: false,
    builder: (BuildContext context){
     return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
       return ScaffoldMessenger(child: Builder (
         builder: (context) => Scaffold(backgroundColor: Colors.transparent,
          body: AlertDialog(
            title: Text('Cambiar estatus', style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            content: MyDropdown(
                dropdownItems: listEstatus2,
                suffixIcon: const Icon(IconLibrary.iconArrows,),
                textStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onPrimary),
                selectedItem: selectedEstatus,
                onPressed: (value) {
                  if(value != selectedEstatus) {
                    selectedEstatus = value!;
                    setState(() {});
                  }
                }
            ),
            actions: <Widget>[
              ws.buttonCancelar((){
                Navigator.of(context).pop();
              }),
              ws.buttonAceptar((){
                CustomAwesomeDialog(title: '¿Desea cambiar el estatus?',
                    desc: 'Servicio/Producto: ${serviciosProductosModels.concepto}',
                btnOkOnPress: () async {
                  cambiarEstatusServicio(serviciosProductosModels, context);
                }, btnCancelOnPress: (){}, ).showQuestion(context);
              })
            ],
         ),)));
     });
    });
  }

  void aplicarFiltro() {
    listServiciosProductosTemp = listServiciosProductos;
    if(_searchController.text.isNotEmpty){
      listServiciosProductosTemp = listServiciosProductosTemp.where((serviciosProductos) =>
      serviciosProductos.codigo.toLowerCase().contains(_searchController.text.toLowerCase())
          || "${serviciosProductos.codigo} ${serviciosProductos.descripcion} ${serviciosProductos.clasificacion}".
      toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }
    setState(() {});
  }

  List<Widget> _filtros() {
    return [
      SizedBox(width: 250, child: MyTextfieldIcon(labelText: "Buscar", textController: _searchController,
          suffixIcon: const Icon(IconLibrary.iconSearch), focusNode: _focusNode,
          floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
          backgroundColor: theme.colorScheme.secondary, formatting: false, colorLine: theme.colorScheme.primary,
          onChanged: (value) {
            aplicarFiltro();
            setState(() {
              FocusScope.of(context).requestFocus(_focusNode);
            });
          },
        ),),
      const SizedBox(width: 10),
      _tableViewButton(),
    ];
  }

  Widget _tableViewButton() {
    return Tooltip(
      child: SizedBox(
        height: 56, width: 45,
        child: IconButton(
          onPressed: () {
            _pressed = !_pressed;
            setState(() {});
          },
          icon: _pressed ? const Icon(Icons.list) : const Icon(Icons.table_view),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ),
      ), message: _pressed? "Mostrar vista de tarjeta" : "Mostrar vista de tabla",
      waitDuration: const Duration(milliseconds: 500),
    );
  }

  Widget encabezados() {
    return Container(
        height: 40,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _pressed ? 0 : 10,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    Map<int, String> estatusTextos = {
      0: "INACTIVO",
      1: "ACTIVO",
      2: "BLOQUEADO",
      3: "FUERA DE LÍNEA"
    };

    List<String> estatusStringsForDisplay = listEstatus.map((estatus) => estatusTextos[estatus] ?? estatus.toString()).toList();
    return [
    const SizedBox(width: 15,),
    if(!_pressed)...[
    const SizedBox(width: 40,),
    ],
      SizedBox(
        width: width / 5,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width / 10, child: const Text("Código", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["codigo"]!)), onTap: () {orderBy("codigo");},),
            InkWell(key: buttonKey1, child: Icon(Icons.filter_alt, color: listCodigo.length != listServiciosProductos.map((e) => e.codigo).toList().length ? ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey1.currentContext!, "codigo", listCodigo);},)
          ],)
        ],),
      ),
      SizedBox(
        width: width / 5,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width / 10, child: const Text("Descripción", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["descripcion"]!)), onTap: () {orderBy("descripcion");},),
            InkWell(key: buttonKey2, child: Icon(Icons.filter_alt,
              color: listDescripcion.length != listServiciosProductos.map((e) => e.descripcion).toList().length ? ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey2.currentContext!, "descripcion", listDescripcion);},)
          ],)
        ],),
      ),
      SizedBox(
        width: width / 5,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(width: width / 10, child: const Text("Clasificación", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["clasificacion"]!)), onTap: () {orderBy("clasificacion");},),
            InkWell(key: buttonKey3, child: Icon(Icons.filter_alt,
              color: listClasificacion.length != listServiciosProductos.map((e) => e.clasificacion).toSet().toList().length ? ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey3.currentContext!, "clasificacion", listClasificacion);},)
          ],)
        ],),
      ),
      SizedBox(
        width: width / 5,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(width: width / 10, child: const Text("Categoría", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["categoria"]!)), onTap: () {orderBy("categoria");},),
            InkWell(key: buttonKey4, child: Icon(Icons.filter_alt,
              color: listCategoria.length != listServiciosProductos.map((e) => e.categoria).toSet().toList().length ? ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey4.currentContext!, "categoria", listCategoria);},)
          ],)
        ],),
      ),
      SizedBox(
        width: width / 5,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(width: width / 12, child: const Text("Estatus", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["estatus"]!)), onTap: () {orderBy("estatus");},),
            InkWell(key: buttonKey5, child: Icon(Icons.filter_alt,
              color: listEstatus.length != listServiciosProductos.map((e) => e.estatus).toSet().toList().length ? ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey5.currentContext!, "estatus", estatusStringsForDisplay );},)
          ],)
        ],),
      ),
      const SizedBox(width: 5,),
    ];
  }

  Widget viewCard() {
    return Container( height: size.width > 1200 ? size.height - 160 : size.height - 230,
      decoration: BoxDecoration( color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RefreshIndicator(
        onRefresh: () async {
          getServiciosProductos();
          _isLoading = true;
          setState(() {});
          const timeLimit = Duration(seconds: 10);
          Timer(timeLimit, () {
            if (listServiciosProductos.isEmpty) {
              setState(() {
                _isLoading = false;
              });
            } else {
              _isLoading = false;
            }
          });
        },
        color: theme.colorScheme.onPrimary,
        child: futureList(),
      ),
    );
  }

  Widget futureList() {
    return FutureBuilder<List<ServiciosProductosModels>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: _buildLoadingIndicator(10));
        } else {
          final listProducto = snapshot.data ?? [];
          if (listProducto.isNotEmpty) {
            return Scrollbar(
              thumbVisibility: true,
              controller: scrollController2,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController2,
                  itemCount: listServiciosProductosTemp.length,
                  itemBuilder: (context, index) {
                    return _card(listServiciosProductosTemp[index], index);
                  },
                ),
              ),
            );
          } else {
            if (_isLoading) {
              return Center(child: _buildLoadingIndicator(10));
            } else {
              return SingleChildScrollView(
                child: Center(child: NoDataWidget()),
              );
            }
          }
        }
      },
    );
  }

  Widget _card(ServiciosProductosModels servicioProductos, int index) {
    return GestureDetector(
      onTap: (){
        if(servicioProductos.selected){
          servicioProductos.toggleSelected();
        }else {
          listServiciosProductosTemp.where((element) => element!= servicioProductos).forEach((element) {
            if(element.selected){
              element.toggleSelected();
            }
          });
          servicioProductos.toggleSelected();
        }
      },
      onDoubleTap: () {
        editServiciosProductos(servicioProductos);},
      onLongPress: (){
        cambiarEstatus(servicioProductos);
        },
      child: _pressed!=true?
      mySwipeCard(servicioProductos, index) : mySwipeTable(servicioProductos, index),);
  }

  Widget mySwipeCard(ServiciosProductosModels serviciosProductos, int index) {
    return ValueListenableBuilder<bool>(
      valueListenable: serviciosProductos.selectedNotifier,
      builder: (context, isSelected, child) {
        return MySwipeTileCard(
          verticalPadding: 2,
          colorBasico: !isSelected ? theme.colorScheme.background : theme.colorScheme.secondary,
          iconColor: theme.colorScheme.onPrimary,
          containerB: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
                SizedBox(
                  width: 40,
                  height: 35,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          surfaceTintColor: theme.colorScheme.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
                          child: Container(
                            width: 200,
                            height: 200,
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: PhotoView(
                                    backgroundDecoration: BoxDecoration(color: theme.colorScheme.background),
                                    imageProvider: imageFromBase64String2(serviciosProductos.foto),
                                  ),
                                ),
                                Text(serviciosProductos.codigo, textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: imageFromBase64String(serviciosProductos.foto),
                  ),
                ),
                SizedBox(width: width / 7, child: Text(serviciosProductos.codigo, textAlign: TextAlign.left,),),
                SizedBox(width: width / 5, child: Text(serviciosProductos.descripcion, textAlign: TextAlign.left,),),
                SizedBox(width: width / 5, child: Text(serviciosProductos.clasificacion, textAlign: TextAlign.left,),),
                SizedBox(width: width / 7, child: Text(serviciosProductos.categoria, textAlign: TextAlign.left,),),
                SizedBox(
                  width: width / 10,
                  child: Text(
                    "${estatusTextos[serviciosProductos.estatus]}",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: estatusColores[serviciosProductos.estatus]),
                  ),
                ),
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              ],
            ),
          ),
          onTapRL: () {
            cambiarEstatus(serviciosProductos);
          },
          iconRL: Icons.wifi_protected_setup_sharp,
          onTapLR: () {
            editServiciosProductos(serviciosProductos);
          },
        );
      },
    );
  }

  Widget mySwipeTable(ServiciosProductosModels serviciosProductos, int index){
    return ValueListenableBuilder<bool> (
      valueListenable: serviciosProductos.selectedNotifier,
      builder: (context, isSelected, child) {
      return MySwipeTileCard( radius: 0, horizontalPadding: 2, verticalPadding: 0.5,
        colorBasico: !isSelected? (index % 2 == 0? theme.colorScheme.background :(theme.colorScheme == GlobalThemData.lightColorScheme
            ? ColorPalette.backgroundLightColor
            : ColorPalette.backgroundDarkColor)) : theme.colorScheme.secondary, iconColor: theme.colorScheme.onPrimary,
        containerRL: serviciosProductos.estatus >=1? null: Row(children: [
          Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)
        ],),
        colorRL: serviciosProductos.estatus >= 1 ? null : ColorPalette.ok,
        containerB: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              SizedBox(width: width / 6,
                  child: Text(
                    serviciosProductos.codigo.trim() != "" ? serviciosProductos
                        .codigo : "Sin código",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11),)),
              SizedBox(width: width / 5,
                  child: Text(serviciosProductos.descripcion.trim() != ""
                      ? serviciosProductos.descripcion
                      : "Sin descripción",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11),)),
              SizedBox(width: width / 5,
                child: Text(serviciosProductos.clasificacion.trim() != ""
                    ? serviciosProductos.clasificacion
                    : "Sin clasificación",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 11),),),
              SizedBox(width: width / 7,
                  child: Text(serviciosProductos.categoria.trim() != ""
                      ? serviciosProductos.categoria
                      : "Sin categoria",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11),)),
              SizedBox(width: width / 10,
                child: Text("${estatusTextos[serviciosProductos.estatus]}",
                    style: TextStyle(
                        color: estatusColores[serviciosProductos.estatus],
                        fontSize: 11)),),
              const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
            ],
          ),
        ),
        onTapRL: () {
          cambiarEstatus(serviciosProductos);
        },
        iconRL: Icons.wifi_protected_setup_sharp,
        onTapLR: () {
          editServiciosProductos(serviciosProductos);
        },
      );
    });
  }

  Widget cardEsqueleto(double width) {
    return SizedBox(
      width: width, height: 65,
      child: Card(
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10),),
          color: theme.backgroundColor,
          borderOnForeground: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Shimmer.fromColors(
              baseColor: theme.primaryColor,
              highlightColor: theme.brightness == Brightness.light
                  ? const Color.fromRGBO(195, 193, 186, 1.0)
                  : const Color.fromRGBO(46, 61, 68, 1),
              enabled: true,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding( padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: buttonList)),
    );
  }

  Future<void> getServiciosProductos() async {
    try {
      print("Obteniendo servicios y productos...");
      listServiciosProductos = [];
      List<ServiciosProductosModels> servicioProductos = await serviciosProductosController.GetServiciosProductos();
      print('Datos obtenidos: $servicioProductos');
      setState(() {
        listServiciosProductos = servicioProductos;
        listServiciosProductosTemp = List.from(listServiciosProductos);
        listCodigo = listServiciosProductos.map((e) => e.codigo).toList();
        listDescripcion = listServiciosProductos.map((e) => e.descripcion).toList();
        listClasificacion = listServiciosProductos.map((e) => e.clasificacion).toSet().toList();
        listCategoria = listServiciosProductos.map((e) => e.categoria).toSet().toList();
        listEstatus = listServiciosProductos.map((e) => e.estatus).toSet().toList();
        resetSortOrder();
        aplicarFiltro();
      });
    } catch (e) {
      String error = await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomSnackBar.showErrorSnackBar(context, '${Texts.errorGettingData}. $error');
      print('Error al obtener servicios y productos: $e');
    } finally {
      LoadingDialog.hideLoadingDialog(context);
    }
  }

  Future<List<ServiciosProductosModels>> _getDatos() async {
    try {
      return listServiciosProductosTemp;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  Widget _bodyPortrait() {
    return const Column(
      children: [Text("data")],
    );
  }

  Future<void> addServiciosProductos() async {
    if (addServicioProducto2) {
      try {
        LoadingDialog.showLoadingDialog(context, Texts.loadingData);
        MonedaController monedaController = MonedaController();
        List<MonedaModels> monedas = await monedaController.getMonedasActivos();
        LoadingDialog.hideLoadingDialog(context);
        await myShowDialogScale(
            ServiciosProductosRegistrationScreen(monedas: monedas,), context,         );
      } catch (error){
        LoadingDialog.hideLoadingDialog(context);
        CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
      }
        getServiciosProductos();
    } else {
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }

  Future<void> editServiciosProductos(ServiciosProductosModels serviciosProductos) async {
    if (editServicioProducto2) {
      CustomAwesomeDialog(
        title: Texts.askEditConfirm,
        desc: 'Producto: ${serviciosProductos.concepto}',
        btnOkOnPress: () async {
          try {
            LoadingDialog.showLoadingDialog(context, Texts.loadingData);
            MonedaController monedaController = MonedaController();
            List<MonedaModels> monedas = await monedaController.getMonedasActivos();
            ServiciosProductos productoObtenido = await serviciosProductosController.getServiciosProductosID(serviciosProductos.idServiciosProductos!);
            print(serviciosProductos.idServiciosProductos);
            LoadingDialog.hideLoadingDialog(context);
            if (productoObtenido != null) {
              await myShowDialogScale(
               ServiciosProductosEditScreen(serviciosProductos: serviciosProductos,monedas: monedas,
                   proveedoresList: productoObtenido.proveedoresList, listaPrecioPSMK: productoObtenido.listaPrecioPSMK),context);
              getServiciosProductos();
              resetSortOrder();
            } else {
              CustomAwesomeDialog(
                title: Texts.errorGettingData,
                desc: 'Error inesperado, contacte a soporte',
                btnOkOnPress: () {},
                btnCancelOnPress: () {},
              ).showError(context);
            }
          } catch (e) {
            LoadingDialog.hideLoadingDialog(context);
            ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
            String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
            CustomAwesomeDialog(
              title: Texts.errorGettingData,
              desc: error,
              btnOkOnPress: () {},
              btnCancelOnPress: () {},
            ).showError(context);
            print('Error al obtener datos: $e');
          }
        },
        btnCancelOnPress: () {},
      ).showQuestion(context);
    } else {
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }

  Future<void> cambiarEstatusServicio(ServiciosProductosModels serviciosProductosModels, BuildContext context) async {
    LoadingDialog.showLoadingDialog(context, 'Actualizando el estatus...');
    bool put = await serviciosProductosController.updateEstatusServicio(
        serviciosProductosModels.idServiciosProductos!,
        estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedEstatus));
    print('${serviciosProductosController.updateEstatusServicio}');
    if(put){
      CustomAwesomeDialog(title: 'Estatus actualizado correctamente', desc: '', btnOkOnPress: () {},
        btnCancelOnPress: (){},).showSuccess(context);
      Future.delayed(const Duration(milliseconds: 2500), (){
        serviciosProductosModels.estatus = estatusTextos.keys.firstWhere((k) => estatusTextos[k] == selectedEstatus);
        Navigator.of(context).pop();
        LoadingDialog.hideLoadingDialog(context);
        setState(() {});
      });
    } else {
      CustomAwesomeDialog(title: 'Error al cambiar el estatus', desc: '',
      btnOkOnPress: (){LoadingDialog.hideLoadingDialog(context);},
      btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context); },).showError(context);
      }
  }

  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    Map<int, String> estatusTextos = {
      0: "INACTIVO",
      1: "ACTIVO",
      2: "BLOQUEADO",
      3: "FUERA DE LÍNEA"
    };
    List<String> list = getValue2(listServiciosProductos, column, column != "codigo" && column !="descripcion");
    List<String> listSelected = getValue2(listServiciosProductosTemp, column, column != "codigo" && column != "descripcion");
    if (column == "estatus") {
      list = list.map((e) => estatusTextos[int.parse(e)] ?? e).toList();
      listSelected = listSelected.map((e) => estatusTextos[int.parse(e)] ?? e).toList();
    }
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
      color: theme.colorScheme == GlobalThemData.lightColorScheme? Color(0xFFF8F8F8): Color(0xFF303030),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, padding: EdgeInsets.zero,
            child: MyPopupMenuButton(items: list, selectedItems: listSelected,)
        ),
      ],
    );
    print("$column");
    print("$listA");
    await aplicarFiltro2(result, column, listA);
  }

  String getValue(ServiciosProductosModels serviciosProductos, String column){
    switch(column){
      case "codigo":
        return serviciosProductos.codigo;
      case "descripcion":
        return serviciosProductos.descripcion;
      case "clasificacion":
        return serviciosProductos.clasificacion;
      case "categoria":
        return serviciosProductos.categoria;
      case "estatus":
        return serviciosProductos.estatus.toString();
      default:
        return '';
    }
  }

  List<String> getValue2(List<ServiciosProductosModels> serviciosProductos, String column, bool removeDuplicates){
    List<String> list = serviciosProductos.map((serviciosProductos) {
      switch (column){
        case "codigo":
          return serviciosProductos.codigo;
        case "descripcion":
          return serviciosProductos.descripcion;
        case "clasificacion":
          return serviciosProductos.clasificacion;
        case "categoria":
          return serviciosProductos.categoria;
        case "estatus":
          return serviciosProductos.estatus.toString();
        default:
          return '';
      }
    }).toList();
    return removeDuplicates ? list.toSet().toList() : list;
  }

  Future<void> aplicarFiltro2(String? result, String column, List<String> listA) async {
    if (result != null) {
      print("Applying filter on column: $column with result: $result");
      if (result == "AZ" || result == "ZA") {
        _sortOrder = result == "AZ" ? 1 : 2;
        applySort(column);
      } else if (result == "ClearAll") {
        _searchController.clear();
        listA.clear();
        listA.addAll(getValue2(listServiciosProductos, column, column != "codigo" && column != "descripcion"));
        if (column == "estatus") {
          listEstatus.clear();
          listEstatus.addAll([0, 1, 2, 3]);
          listServiciosProductosTemp.clear();
          listServiciosProductosTemp.addAll(listServiciosProductos);
        } else {
          listServiciosProductosTemp.clear();
          listServiciosProductosTemp.addAll(listServiciosProductos);
        }
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
        if (column == "estatus") {
          Map<String, int> reverseEstatusTextos = {
            "INACTIVO": 0,
            "ACTIVO": 1,
            "BLOQUEADO": 2,
            "FUERA DE LÍNEA": 3
          };
          print("Before conversion: $listA");
          List<String> convertedList = listA.map((text) {
            if (reverseEstatusTextos.containsKey(text)){
              return reverseEstatusTextos[text]!.toString();
            } else {
              print("Warning: '$text' no está en el mapa de estados." );
              return '';
            }
          }).toList();
          convertedList = convertedList.where((element) => element.isNotEmpty).toList();
          print("After conversion: $convertedList");
          listEstatus.clear();
          listEstatus.addAll(convertedList.map(int.parse));
          await resetList();
        }
        await resetList();
      }
      setState(() {});
    }
  }

  void sortList(List<ServiciosProductosModels> serviciosProductos, String Function(ServiciosProductosModels) getValue, int sortOrder){
    serviciosProductos.sort((a,b){
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare : -compare;
    });
  }

  void applySort(String column){
    _sortOrders.updateAll((key, value) => 0);
    _sortOrders[column] = _sortOrder;
    sortList(listServiciosProductosTemp, (serviciosProductos) => getValue(serviciosProductos, column), _sortOrder);
  }

  void applySort2(){
    _sortOrders.forEach((key, value) {
      if(value !=0){
        listServiciosProductosTemp.sort(sortFunctions[key]?[value]);
      }
    });
  }

  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for (int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId == Texts.permissionsServiciosProductosAdd) {
        addServicioProducto2 = true;
      } else if (listUsuarioPermisos[i].permisoId == Texts.permissionsServiciosProductosEdit) {
        editServicioProducto2 = true;
      } else if (listUsuarioPermisos[i].permisoId == Texts.permissionsServiciosProductosDelete) {
        deleteServicioProducto2 = true;
      }
    }
  }

  void orderBy(String s){
    _sortOrders[s] = _sortOrders[s] == 0 || _sortOrders[s] == 2 ? 1 : 2;
    _sortOrders.updateAll((key, value) {
      if(key != s){
        return 0;
      }else  {
        return _sortOrders[key]?? 0;
      }
    });
    applySort2();
    setState(() {
    });
  }

  Future<void> resetList() async {
      listServiciosProductosTemp = filterList(listServiciosProductos, listCodigo, (serviciosProductos) => serviciosProductos.codigo);
      listServiciosProductosTemp = filterList(listServiciosProductosTemp, listDescripcion, (serviciosProductos) => serviciosProductos.descripcion);
      listServiciosProductosTemp = filterList(listServiciosProductosTemp, listClasificacion, (serviciosProductos) => serviciosProductos.clasificacion);
      listServiciosProductosTemp = filterList(listServiciosProductosTemp, listCategoria, (serviciosProductos) => serviciosProductos.categoria);
      listServiciosProductosTemp = filterList(listServiciosProductosTemp, listEstatus.map((e) => e.toString()).toList(), (serviciosProductos) => serviciosProductos.estatus.toString());
      applySort2();
  }

  List<ServiciosProductosModels> filterList(List<ServiciosProductosModels> serviciosProductos, List<String> strings, String Function (ServiciosProductosModels) getValue){
    return serviciosProductos.where((servicioProducto) => strings.contains(getValue(servicioProducto))).toList();
  }

  void resetSortOrder(){
    _sortOrders.updateAll((key, value) => 0);
  }

  Widget imageFromBase64String(String? base64String) {
    try {
      if(base64String == null){
        return const CircleAvatar(
          backgroundImage: AssetImage('assets/servicios.png'),
        );
      }else{
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        Image image = Image.memory(uint8List);
        return Container(
          child: image,
        );
      }
    } catch (e) {
      print("Error decoding Base64: $e");
      return const CircleAvatar(
        backgroundImage: AssetImage('assets/servicios.png'),
      );
    }
  }

  ImageProvider imageFromBase64String2(String? base64String) {
    try {
      if(base64String == null){
        return const AssetImage('assets/servicios.png');
      } else {
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        return MemoryImage(uint8List);
      }
    } catch (e) {
      print("Error decoding Base64: $e");
      return const AssetImage('assets/imagenError.png');
    }
  }

}
