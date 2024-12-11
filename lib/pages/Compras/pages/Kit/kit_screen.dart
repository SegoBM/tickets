import 'dart:async';
import 'dart:ui';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ComprasModels/KitModels/Kits.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../controllers/ComprasController/KitController/KitController.dart';
import '../../../../models/ConfigModels/usuarioPermiso.dart';
import '../../../../shared/actions/my_show_dialog.dart';
import '../../../../shared/utils/color_palette.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/appBar/my_appBar.dart';
import '../../../../shared/widgets/buttons/dropdown_decoration.dart';
import '../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/error/customNoData.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';
import '../../../Settings/GeneralSettings/widgets_settings.dart';
import 'kit_registrationScreen.dart';
import 'package:intl/intl.dart';

class KitScreen extends StatefulWidget {
  static String id = 'KitScreen';
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  BuildContext context;
  KitScreen({super.key, required this.listUsuarioPermisos, required this.context });

  @override
  _KitScreenState createState() => _KitScreenState();
}

class _KitScreenState extends State<KitScreen>{
  late Size size; late ThemeData theme;
  final FocusNode _focusNode = FocusNode();
  final _searchController = TextEditingController();
  ScrollController scrollController = ScrollController(), scrollController2 = ScrollController();
  double width = 0;
  List<String> listCodigo =[], listNombre=[], listDescripcion=[], listFecha=[];
  List<int> listEstatus=[];
  List<KitModels> listKit=[], listKitTemp=[];
  bool _isLoading = true, _pressed = false;
  bool addKits = false, deleteKits = false, editKits = false;
  int _sortOrder =0;
  late BuildContext homeContext;
  final _key=GlobalKey(), buttonKey1=GlobalKey(), buttonKey2=GlobalKey(), buttonKey3=GlobalKey(), buttonKey4=GlobalKey(), buttonKey5=GlobalKey();
  late WidgetsSettings ws;
  late String selectedEstatus;

  Map<int,String> estatusTextos={
    0: "INACTIVO",
    1: "DISPONIBLE",
    2: "BLOQUEADO",
    3: "DESCONTINUADO"
  };

  Map<int, Color> estatusColores ={
    0: Colors.red,
    1: Colors.green,
    2: Colors.orange,
    3: Color.fromARGB(255, 235, 92, 10),
  };

  Map<String, int> _sortOrders={
    "codigo" : 0,
    "nombre" : 0,
    "descripcion" : 0,
    "fecha" : 0,
    "estatus" : 0,
  };

  Map<String, Map<int, int Function (KitModels, KitModels)>> sortFuntions ={
    "codigo" : {
      1: (KitModels a, KitModels b) => a.codigo.compareTo(b.codigo),
      2: (KitModels a, KitModels b) => b.codigo.compareTo(a.codigo)
    },
    "nombre" :{
      1: (KitModels a, KitModels b) => a.nombre.compareTo(b.nombre),
      2: (KitModels a, KitModels b) => b.nombre.compareTo(a.nombre)
    },
    "descripcion" : {
      1: (KitModels a, KitModels b) => a.descripcion.compareTo(b.descripcion),
      2: (KitModels a, KitModels b) => b.descripcion.compareTo(a.descripcion)
    },
    "fecha" : {
      1: (KitModels a, KitModels b) => (a.fecha ?? DateTime(0)).compareTo(b.fecha ?? DateTime(0)),
      2: (KitModels a, KitModels b) => (b.fecha ?? DateTime(0)).compareTo(a.fecha ?? DateTime(0))
    },
    "estatus" : {
      1: (KitModels a, KitModels b) => a.estatus.compareTo(b.estatus),
      2: (KitModels a, KitModels b) => b.estatus.compareTo(a.estatus)
    }
  };

  @override
  void initState() {
    getKits();
    getPermisos();
    const timeLimit = Duration(seconds:10);
    Timer(timeLimit, () {
      if (listKit.isEmpty) {
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
      LogicalKeyboardKey.f4: () async {addKit();},
      LogicalKeyboardKey.f5: () async {
        getKits();
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if (listKit.isEmpty) {
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
          MyCustomAppBarDesktop(title: "Kits", context: widget.context, backButton: false,) : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: size.width > 600 ? _bodyLandscape() : _bodyPortrait(),
            ),
          ),
        ));
  }

  Widget _bodyLandscape() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row( children:[
              Row(children: _filtros(),),
              const SizedBox(width: 10),
            ],),
            const SizedBox(width:10),
            Row( children:[
              _customButtonAdd(),
              const SizedBox(width: 10),
              _customButtonEdit(),
              const SizedBox(width: 10,),
              _customButtonChangeEstatus(),
            ],),
          ],),
        const SizedBox(height:5),
        encabezados(),
       viewCard(),
      ],
    );
  }

  Widget buildPopup({Size? viewSize}){
    return SingleChildScrollView(
      key: const ValueKey<String> ('datagrid_filtering_scrollView'),
      child: Container(
        width: 274.0, color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.sort), title: Text('Sort Ascending'),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.sort), title: Text('Sort Descending'),
              onTap: (){},
            ),
            const Divider(indent: 8.0, endIndent: 8.0),
            ListTile(
              leading: Icon(Icons.clear), title: Text('Clear Filter'),
              onTap: (){},
            ),
            ListTile(
              leading: Icon(Icons.filter_alt),
              title: Text('Advanced Filter'),
              onTap: (){},
            ),
            const Divider(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: (){},
                    child: Text('Ok'),
                  ),
                  OutlinedButton(
                      onPressed: (){},
                      child: Text('Cancel'),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customButtonAdd() {
    return Tooltip( message: 'Agregar un nuevo kit', waitDuration: const Duration (milliseconds: 500),
      child: SizedBox( height:50, width:50,
        child: IconButton(onPressed: (){addKit();}, icon: const Icon(IconLibrary.iconAdd),
         style: ButtonStyle(
           backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
           padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
           shape:  MaterialStateProperty.all <RoundedRectangleBorder> (
               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
           ),),
        ),
      ),);
  }

  Widget _customButtonEdit(){
    return Tooltip( message: "Editar el kit", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height:50, width:50,
         child: IconButton(onPressed: () async {
          //KitModels ? kitSelected = await getKitSelected();
          //if(kitSelected != null){
          //editKits(kitSelected);
          // } else {
          //MyCherryToast.showWarningSnackBar(context,
          // theme "No fue posible editar", "Seleccione un servicio o producto para continuar");
          //}
          }, icon: const Icon(IconLibrary.iconEdit),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>
                (theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder> (
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
         ),), ),
         ),);
  }

  Widget _customButtonChangeEstatus(){
    return Tooltip(message: "Cambiar estatus", waitDuration: const Duration (milliseconds:500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          //KitModels ? kitsSelected = await getKitSelected  await getKitSelected();
          // if(kitSelected != null){
          // if( kitSelected.estatus == 0){
          //MyCherryToast.showWarningSnackBar(context, theme, "El ");
          //} else {
          // changeEstatus(kitSelected);
          //}
          // } else {
          //MyCherryToast.showWarningSnackBar(context, theme, "No fue posible modificar el estatus", "Seleccione un kit para poder continuar");
          //}
          }, icon: const Icon(IconLibrary.iconArrows),
           style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
              padding: MaterialStateProperty.all<EdgeInsets>( const EdgeInsets.all(5)),
           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
           ),),
          ),
      ),);
  }

  void changeEstatus(KitModels kit){
    showDialog( context: context, barrierDismissible: false,
    builder:(BuildContext contex){
      return StatefulBuilder(builder:(BuildContext context, StateSetter setState){
         return ScaffoldMessenger(child: Builder(
           builder: (context) => Scaffold(backgroundColor: Colors.transparent,
            body: AlertDialog(
              title: Text('Cambiar estatus', style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
              content: MyDropdown(dropdownItems: listEstatus,
               suffixIcon: const Icon(IconLibrary.sellIcon),
               textStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onPrimary),
               selectedItem: selectedEstatus, onPressed: (value){
                if(value != selectedEstatus){
                  selectedEstatus = value!;
                  setState((){});
                }
              }),
              actions: <Widget>[
                ws.buttonCancelar((){
                  Navigator.of(context).pop();
                }),
                ws.buttonAceptar((){
                  CustomAwesomeDialog(title: '¿Desea cambiar el estatus?', desc: 'Kit: ${kit.nombre}',
                  btnOkOnPress: () async {
                     //changeEstatusKit(KitModels, context);
                  }, btnCancelOnPress: (){},).showQuestion(context);
                })
              ],
           ),)));
      });
    });
  }

  void aplicarFiltro(){
    listKitTemp = listKit;
    if(_searchController.text.isNotEmpty){
      listKitTemp = listKit.where((kits) =>
      kits.codigo.toLowerCase().contains(_searchController.text.toLowerCase())
          || "${kits.codigo} ${kits.descripcion} ${kits.nombre} ${kits.fecha}".
      toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }
    setState(() {});
  }

  List<Widget> _filtros() {
    return [
      SizedBox(width: 250,
        child: MyTextfieldIcon(labelText: "Buscar", textController: _searchController,
          suffixIcon: const Icon(IconLibrary.iconSearch), focusNode: _focusNode,
          floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
          backgroundColor: theme.colorScheme.secondary, formatting: false, colorLine: theme.colorScheme.primary,
          onChanged: (value) {
            aplicarFiltro();
            setState(() {
              FocusScope.of(context).requestFocus(_focusNode);
            });
          },
        ),
      ),
      const SizedBox(width: 10),
      _tableViewButton(),
    ];
  }

  Widget _tableViewButton() {
    return Tooltip(
      child: SizedBox(
        height:56, width:45,
        child: IconButton(
          onPressed: (){
            _pressed =! _pressed;
            setState(() {});
          },
          icon: _pressed ? Icon(Icons.list) : const Icon(Icons.table_view),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ),
      ), message: _pressed? "Mostrar vista de tarjeta" : "Mostrar vista de tabla",
      waitDuration: const Duration(milliseconds:500),
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
                horizontal: _pressed ? 0 : 10 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: encabezadosCard(),
            )));
  }

  IconData _sortIcon(int sortOrder){
    if(sortOrder == 0){
      return Icons.swap_vert;
    } else if (sortOrder == 1){
      return Icons.arrow_upward_rounded;
    } else {
      return Icons.arrow_downward_rounded;
    }
  }

  List<Widget> encabezadosCard(){
    Map<int,String> estatusTextos ={
      0: "INACTIVO",
      1: "DISPONIBLE",
      2: "BLOQUEADO",
      3: "DESCONTINUADO"
    };
    List<String> estatusStringsForDisplay = listEstatus.map((estatus) => estatusTextos[estatus] ?? estatus.toString()).toList();
    return [
      const SizedBox(width: 10,),
      if(!_pressed)...[
        const SizedBox(width: 30,),
      ],
      SizedBox(
        width: width /6,
        child: Row( mainAxisAlignment: MainAxisAlignment.center, children:[
          SizedBox(width: width /16, child: const Text("Código", textAlign: TextAlign.left, style: TextStyle( fontSize:14),),),
          Row(children:[
            InkWell(child: Icon(_sortIcon(_sortOrders["codigo"]!)), onTap: () {orderBy("codigo");},),
            InkWell(key: buttonKey1, child: Icon(Icons.filter_alt,
              color: listCodigo.length != listKit.map((e) => e.codigo).toList().length ?
              ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey1.currentContext!, "codigo", listCodigo);},)
          ],),
        ],),
      ),
      SizedBox(
          width: width /6,
          child: Row( mainAxisAlignment: MainAxisAlignment.center, children:[
            SizedBox( width: width /16, child: const Text("Nombre", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
            Row(children:[
              InkWell( child: Icon(_sortIcon(_sortOrders["nombre"]!)), onTap: () {orderBy("nombre");},),
              InkWell( key: buttonKey2, child: Icon(Icons.filter_alt,
                color: listNombre.length != listKit.map((e) => e.nombre).toList().length ?
                ColorPalette.informationColor : theme.colorScheme.onPrimary,),
                onTap: (){handleButtonPress(buttonKey2.currentContext!, " nombre", listNombre);},)
            ],),
          ],)
      ),
      SizedBox(
        width: width/2.8,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width/10, child: const Text("Descripción", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row( children:[
            InkWell( child: Icon(_sortIcon(_sortOrders["descripcion"]!)), onTap: () {orderBy("descripcion");},),
            InkWell(key: buttonKey3, child: Icon(Icons.filter_alt,
              color: listDescripcion.length != listKit.map((e) => e.descripcion).toList().length ?
              ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap:  (){handleButtonPress(buttonKey3.currentContext!, "descripcion", listDescripcion);},)
          ],),
        ],),
      ),
      SizedBox(
        width: width/6,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: width/16, child: const Text("Fecha", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row( children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["fecha"]!)), onTap: () {orderBy("fecha");},),
            InkWell(key: buttonKey4, child: Icon(Icons.filter_alt,
              color: listFecha.length != listKit.map((e) => e.fecha).toList().length ?
              ColorPalette.informationColor : theme.colorScheme.onPrimary,),
              onTap: () {handleButtonPress(buttonKey4.currentContext!, "fecha", listFecha);},),
          ],)
        ],),
      ),
      SizedBox(
        width: width/6,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(width: width/20, child: const Text("Estatus", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
          Row(children: [
            InkWell(child: Icon(_sortIcon(_sortOrders["estatus"]!)), onTap: (){orderBy("estatus");},),
            InkWell(key: buttonKey5, child: Icon(Icons.filter_alt,
                color: listEstatus.length != listKit.map((e) => e.estatus).toSet().toList().length ?
                ColorPalette.informationColor : theme.colorScheme.onPrimary),
              onTap: (){handleButtonPress(buttonKey5.currentContext!, "estatus", estatusStringsForDisplay);},)
          ],)
        ],),
      ),
      const SizedBox(width: 15,),
    ];
  }

  Widget viewCard(){
    return Container( height: size.width > 1200 ? size.height - 160 : size.height -230,
      decoration: BoxDecoration( color: theme.primaryColor,
       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RefreshIndicator(
        onRefresh: () async {
          getKits();
          _isLoading = true;
          setState(() {});
          const timeLimit = Duration(seconds: 10);
          Timer(timeLimit, () {
            if(listKit.isEmpty){
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
      )
    );
  }

  Widget futureList(){
    return FutureBuilder<List<KitModels>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: _buildLoadingIndicator(10));
        } else {
          final listProducto = snapshot.data ?? [];
          if (listProducto.isNotEmpty){
            return Scrollbar(
              thumbVisibility: true,
              controller: scrollController2,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController2,
                  itemCount: listKitTemp.length,
                  itemBuilder: (context, index){
                    return _card(listKitTemp[index], index);
                  },
                ),
              ),
            );
          } else {
            if( _isLoading){
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

  Widget _card(KitModels kit, int index){
    return GestureDetector(
      onSecondaryTap: () {
        //editKit;
      },
      onLongPress: (){
        changeEstatus(kit);
      },
      child: _pressed != true?
          mySwipeCard(kit, index) : mySwipeTable(kit, index),);
      //mySwipeTable(kit, index),);
  }

  Widget mySwipeCard(KitModels kit, int index){
    return MySwipeTileCard(
      colorBasico: theme.colorScheme.background, iconColor: theme.colorScheme.onPrimary,
      containerB: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            const Icon(IconLibrary.iconDrag, size:15, color: Colors.grey,),
            SizedBox( width: 30, height: 30, child: Container( decoration:
              BoxDecoration(color: theme.colorScheme.background),
                child:CircleAvatar( radius: 10.0, backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/kits.png')),),),
              SizedBox( width: width/9, child: Text(kit.codigo, textAlign: TextAlign.left,),),
              SizedBox( width: width/7, child: Text(kit.nombre, textAlign: TextAlign.left,),),
              SizedBox( width: width/3, child: Text(kit.descripcion, textAlign: TextAlign.left,),),
              SizedBox( width: width/6, child: Text(DateFormat('dd-MM-yyyy').format(kit.fecha!), textAlign: TextAlign.left,),),
              SizedBox( width: width/7, child: Text("${estatusTextos[kit.estatus]}", textAlign: TextAlign.left,
                style: TextStyle(color: estatusColores[kit.estatus],)),),
          ],
        ),
      ),
      onTapRL: (){
      },
      onTapLR: (){
      },
    );
  }

  Widget mySwipeTable(KitModels kit, int index){
    return MySwipeTileCard(
      radius: 0, horizontalPadding: 2, verticalPadding: 0.5,
      colorBasico: index % 2 == 0 ? theme.colorScheme.background :
      (theme.colorScheme == GlobalThemData.lightColorScheme
       ? ColorPalette.backgroundLightColor : ColorPalette.backgroundDarkColor) ,
      iconColor: theme.colorScheme.onPrimary,
      colorRL: null,
      colorLR: null,
      containerB: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            const Icon(IconLibrary.iconDrag, size: 15, color:Colors.grey,),
            SizedBox( width: width/9, child: Text(kit.codigo.trim() != ""? kit.codigo : "Sin codigo",
              textAlign: TextAlign.left, style: TextStyle (fontSize:11),)),
            SizedBox(width: width/8, child: Text(kit.nombre.trim() !="" ? kit.nombre : "Sin nombre",
              textAlign: TextAlign.left, style: TextStyle (fontSize: 11),)),
            SizedBox( width: width/3, child: Text(kit.descripcion.trim() !="" ? kit.descripcion : "Sin descripcion",
              textAlign: TextAlign.left, style: TextStyle (fontSize:11),)),
            SizedBox( width: width /6, child: Text( DateFormat('dd-MM-yyyy').format(kit.fecha!), textAlign: TextAlign.left,),),
            SizedBox(width: width/7, child: Text("${estatusTextos[kit.estatus]}",
              style: TextStyle(color: estatusColores[kit.estatus], fontSize: 11 )),),
          ],
        ),
      ),
      onTapRL: (){
        changeEstatus(kit);
      },
      onTapLR: (){
        //edit
      },
    );
  }

  Widget cardEsqueleto(double width) {
    return SizedBox(
      width: width, height: 65,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: buttonList)),
    );
  }

  Future<void> getKits() async {
    try {
      print("Obteniendo kits...");
      listKit = [];
      KitController kitController = KitController();
      List<KitModels> kits = await kitController.GetKit();
      print("Datos obtenidos: $kits");
      setState(() {
        listKit = kits;
        listKitTemp = List.from(listKit);
        listCodigo = listKit.map((e) => e.codigo).toList();
        listNombre = listKit.map((e) => e.nombre).toList();
        listDescripcion = listKit.map((e) => e.descripcion).toSet().toList();
        listFecha = listKit.map((e) => DateFormat('yyyy-MM-dd').format(e.fecha!)).toSet().toList();
        listEstatus = listKit.map((e) => e.estatus).toSet().toList();
        resetSortOrder();
        aplicarFiltro();
      });
    }catch (e) {
      print('Excepción atrapada: $e');
      String err = await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomSnackBar.showErrorSnackBar(context, '${Texts.errorGettingData}.$err');
    } finally {
      //Lo comente porque tambien dabe errores al salir de la pantalla
      //LoadingDialog.hideLoadingDialog(context);
    }
  }

  Future<List<KitModels>> _getDatos() async{
    try{
      return listKitTemp;
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

  Future<void> addKit() async {
    if(addKits){
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      await myShowDialogScale(KitRegistrationScreen(), context);
      await getKits();
      LoadingDialog.hideLoadingDialog(context);
    } else {
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }

  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    Map<int, String> estatusTextos ={
      0: "INACTIVO",
      1: "DISPONIBLE",
      2: "BLOQUEADO",
      3: "DESCONTINUADO"
    };
    List<String> list = getValue2(listKit, column, column != "codigo" && column != "nombre");
    if (column == "estatus"){
      list = list.map((e) => estatusTextos[int.parse(e)] ?? e).toList();
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
      color: theme.colorScheme == GlobalThemData.lightColorScheme? Color(0xFFF8F8F8) : Color(0xFF303030),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(enabled: false, padding: EdgeInsets.zero,
          child: MyPopupMenuButton(items: list, selectedItems: [],),
        ),
      ],
    );
    print("$column");
    print("$listA");
    await aplicarFiltro2(result, column, listA);
  }

  String getValue(KitModels kit, String column){
    switch(column){
      case "codigo":
        return kit.codigo;
      case "nombre":
        return kit.nombre;
      case "descripcion":
        return kit.descripcion;
      case "fecha":
        return DateFormat('yyyy-MM-dd').format(kit.fecha!);
      case "estatus":
        return kit.estatus.toString();
      default:
        return '';
    }
  }

  List<String> getValue2(List<KitModels> kit, String column, bool removeDuplicates) {
    List<String> list = kit.map((kit) {
      switch (column) {
        case "codigo":
          return kit.codigo;
        case "nombre":
          return kit.nombre;
        case "descripcion":
          return kit.descripcion;
        case "fecha":
          return DateFormat('yyyy-MM-dd').format(kit.fecha!);
        case "estatus":
          return kit.estatus.toString();
        default:
          return '';
      }
    }).toList();

    return removeDuplicates ? list.toSet().toList() : list;
  }

  Future<void> aplicarFiltro2(String? result, String column, List<String> listA) async {
    if (result != null){
      print("Applying filter on column: $column with result: $result");
      if(result == "AZ" || result == "ZA"){
        _sortOrder = result == "AZ" ? 1 : 2;
        applySort(column);
      } else if (result == "ClearAll"){
        _searchController.clear();
        listA.clear();
        listA.addAll(getValue2(listKit, column, column != "codigo" && column != "nombre"));
        if(column == "estatus"){
          listEstatus.clear();
          listEstatus.addAll([0,1,2,3]);
          listKitTemp.clear();
          listKitTemp.addAll(listKit);
        } else {
          listKitTemp.clear();
          listKitTemp.addAll(listKit);
        }
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
        if (column == "estatus"){
          Map<String, int> reverseEstatusTextos = {
            "INACTIVO" : 0,
            "ACTIVO" : 1,
            "BLOQUEADO" : 2,
            "FUERA DE LÍNEA" : 3
          };
          print("Before conversion: $listA");
          List<String> convertedList = listA.map((text) {
            if (reverseEstatusTextos.containsKey(text)){
              return reverseEstatusTextos[text]!.toString();
            } else {
              print("Warning: '$text' no esta en el mapa de estados.");
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

  void sortList(List<KitModels> kit, String Function(KitModels) getValue, int sortOrder){
    kit.sort((a,b){
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare : -compare;
    });
  }

  void applySort(String column){
    _sortOrders.updateAll((key, value) => 0);
    _sortOrders[column] = _sortOrder;
    sortList(listKitTemp, (kit) => getValue(kit,column), _sortOrder);
  }

  void applySort2(){
    _sortOrders.forEach((key, value){
      if(value != 0){
        listKitTemp.sort(sortFuntions[key]?[value]);
      }
    });
  }

  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for (int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId ==
          "a62521ea-9a8f-4268-9afa-8e6a54aa9fbb") {
        addKits= true;
      } else if (listUsuarioPermisos[i].permisoId ==
          "153084ed-ac4f-432b-92a3-f39c36c475b1") {
        editKits = true;
      } else if (listUsuarioPermisos[i].permisoId ==
          "540d59f5-ae1e-48eb-8dc9-e86b9a2ca2e8") {
        deleteKits = true;
      }
    }
  }

  void orderBy(String s){
    _sortOrders[s] = _sortOrders [s] == 0 || _sortOrders[s] == 2 ? 1 : 2;
    _sortOrders.updateAll((key, value) {
      if(key != s){
        return 0;
      } else {
        return _sortOrders [key] ?? 0;
      }
    });
    applySort2();
    setState(() {
    });
  }

  Future<void> resetList() async {
    listKitTemp = filterList(listKit, listCodigo, (kit) => kit.codigo);
    listKitTemp = filterList(listKitTemp, listNombre, (kit) => kit.nombre);
    listKitTemp = filterList(listKitTemp, listDescripcion, (kit) => kit.descripcion);
    listKitTemp = filterList(listKitTemp, listFecha,
            (kit) => DateFormat('yyyy-MM-dd').format(kit.fecha!));
    listKitTemp = filterList(listKitTemp, listEstatus.map((e) => e.toString()).toList(),
        (kit) => kit.estatus.toString());
    applySort2();
  }

  List<KitModels> filterList(List<KitModels> kit, List<String> strings, String Function(KitModels) getValue){
    return kit.where((kit) => strings.contains(getValue(kit))).toList();
  }

  void resetSortOrder(){
    _sortOrders.updateAll((key, value) => 0);
  }


}