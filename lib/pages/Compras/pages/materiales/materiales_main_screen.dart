import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/monedaController.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/familia_model.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/sub_familia_model.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/monedas.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/error/customNoData.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Compras/pages/materiales/edit_material_screen.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/pdf/pw_pdf/generate_material_report.dart';
import 'package:tickets/shared/widgets/buttons/custom_button.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../controllers/ComprasController/MaterialesControllers/familia_controller.dart';
import '../../../../controllers/ComprasController/MaterialesControllers/materialesController.dart';
import '../../../../controllers/ComprasController/SubFamiliaController/subFamiliaController.dart';
import '../../../../models/ComprasModels/MaterialesModels/materiales.dart';
import '../../../../shared/actions/my_show_dialog.dart';
import '../../../../shared/utils/color_palette.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'alta_materiales_screen.dart';
import 'keys_dialogs/clave_unidad_dialog.dart';
class ListaMaterialesScreen extends StatefulWidget  {
  BuildContext context;
  ListaMaterialesScreen({super.key, required this.context});
  @override
  State<ListaMaterialesScreen> createState() => _ListaMaterialesScreenState();
  static String id = 'lista_materiales_screen';
}

class _ListaMaterialesScreenState extends State<ListaMaterialesScreen> with SingleTickerProviderStateMixin {
  late ThemeData theme; late Size size;
  final FocusNode _focusNode = FocusNode();
  final buttonKey1 = GlobalKey(), buttonKey2 = GlobalKey(), _key = GlobalKey(),
  buttonKey3 = GlobalKey(), buttonKey4 = GlobalKey(), buttonKey5 = GlobalKey();
  List<MaterialesModels> materialList = [] , listMaterialesTemp = [];
  List<String> familiaNombreString = [], subFamiliaNombreString = [], codigoProductoString = [];
  List<int>  estatusString = [];
  List<int> listStatuses =[];
  final _searchController = TextEditingController();
  ScrollController materialesScrollController = ScrollController();
  ScrollController scrollController = ScrollController();
  MaterialesController materialesController = MaterialesController();
  final _searchBarContoller = TextEditingController();
  final  _listViewScrollController  = ScrollController();
  bool _pressed = true;
  bool _isLoading = true ;
  bool deleteMaterial = false;
  late Uint8List imageBytes;
  int _sortOrder = 0 ;
  double width = 0; double height = 10;

  final Map<String, int > _sortOrders = {
    "familiaNombre":0,
    "subFamiliaNombre":0,
    "codigoProducto":0,
    "estatus":0,
  };
  final Map<String, int> statusMap = {
    "INACTIVO": 0,
    "ACTIVO": 1,
    "BLOQUEADO": 2,
    "FUERA DE LINEA": 3,
  };
  Map<int, Color> statusColor ={
    0: Colors.red,
    1: Colors.green,
    2: Colors.orange,
    3: const Color.fromARGB(255, 235, 92, 10),
  };

  String getStatusName (int status){
    return statusMap.entries.firstWhere((entry) => entry.value == status).key;
  }

  Map< String,Map< int, int Function( MaterialesModels, MaterialesModels )> > sortFunctions = {
    "familiaNombre": {
      1:( MaterialesModels a, MaterialesModels b ) => a.familiaNombre.toString().compareTo(b.familiaNombre.toString()),// asendente
      2:( MaterialesModels a, MaterialesModels b ) => b.familiaNombre.toString().compareTo(a.familiaNombre.toString())// desendente
    },
    "subFamiliaNombre":{
      1:( MaterialesModels a, MaterialesModels b ) => a.subFamiliaNombre.toString().compareTo(b.subFamiliaNombre.toString()),
      2:( MaterialesModels a, MaterialesModels b ) => b.subFamiliaNombre.toString().compareTo(a.subFamiliaNombre.toString()),
    },
    "codigoProducto":{
      1:(MaterialesModels a, MaterialesModels b) =>a.codigoProducto.compareTo(b.codigoProducto),//codigo
      2:(MaterialesModels a, MaterialesModels b) =>b.codigoProducto.compareTo(a.codigoProducto),
    },
    "estatus":{
      1:(MaterialesModels a, MaterialesModels b) =>a.estatus.compareTo(b.estatus),
      2:(MaterialesModels a, MaterialesModels b) =>b.estatus.compareTo(a.estatus),
    },
  };

  @override
  void initState() {
    getMaterials();
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if(materialList.isEmpty){setState(() {_isLoading = false;});}
      else{_isLoading = false;}
    });
      super.initState();
  }

  @override
  void dispose() {
    _searchBarContoller.dispose();
    materialesScrollController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context); width = size.width;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.f2 : () async {
        MaterialesModels? materialSelected = await getMaterialSelected();
        if(materialSelected!=null) {
          _deleteMaterial(materialSelected);
        }else{
          MyCherryToast.showWarningSnackBar(context, theme, "No fue posible editar", "Seleccione un usuario para continuar");
        }
      },
      LogicalKeyboardKey.f3 : () async {
        MaterialesModels? materialSelected = await getMaterialSelected();
        if(materialSelected!=null) {
          goToEditMaterials(materialSelected);
        }else{
          MyCherryToast.showWarningSnackBar(context, theme, "No fue posible editar", "Seleccione un usuario para continuar");
        }
      },
      LogicalKeyboardKey.f4 : () async {await addMaterials();},
      LogicalKeyboardKey.f5 : () async {
        getMaterials();
        _isLoading = true;
        setState(() {});
        const timeLimit = Duration(seconds: 10);
        Timer(timeLimit, () {
          if(materialList.isEmpty){setState(() {_isLoading = false;});}
          else{_isLoading = false;}
        });
      },
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey:_key,
        child: Scaffold(
          appBar: size.width > 600? MyCustomAppBarDesktop(title:"Materiales",context: widget.context,backButton: true,rute:'TicketsHome',)
              : null,
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: size.width> 600? _landScapeBody():_portraitBody(),
              //_landScapeBody() : _portraitBody
            ),
          ),
        ));
  }
  Widget _landScapeBody() {
    // This is the body of the screen when the device is in landscape mode or desktop
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _header(),
          _head(),
          _bodyContainer(),
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
              leading: const Icon(Icons.sort), title: const Text('Sort Ascending'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.sort), title: const Text('Sort Descending'),
              onTap: () {},
            ),
            const Divider(indent: 8.0, endIndent: 8.0),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Filter'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Advanced Filter'),
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
                    child: const Text('OK'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _portraitBody(){
    return const Column(children: [
      Text("data")
    ],);
  }
//el cuerpo principal se dividira en varias parte para poder tener un mejor control de los widgets
  /*
   [header] tendra los botones de accion para filtrado, bsuqueda alta de material
   body y header haran el fullbody de la pantalla
   */
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(size.width > 1200 )...[
            Row(children: [
              _searchBar(),
              const SizedBox(width: 5,),
              _tableViewButton(),
              const SizedBox( width: 5 ),
              _reportGenerator(),

            ],),
            Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _addMaterialButtonCompras(),
                const SizedBox( width: 5),
                _edit(),
                const SizedBox( width: 5),
                _delete(),
            ],)
          ] else... [
            Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _searchBar(),
              const SizedBox(width: 5,),
              _tableViewButton(),
              const SizedBox(width: 5),
              _reportGenerator(),
            ], ),
              _addMaterialButtonCompras(),
          ]
        ],
      )
    );
  }


  Widget _tableViewButton() {
    return Tooltip(message: _pressed? "Mostrar vista de tarjeta" : "Mostrar vista de tabla",
      waitDuration: const Duration(milliseconds: 500),child: SizedBox(height: 50, width: 50,
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),),
        ),
      ),
    );
  }

  Widget _bodyContainer(){
    return Container(
      height: size.height - 160,
      // size.width>1200? size.height-160 : size.height-230,
      decoration: BoxDecoration( color: theme.primaryColor ,
      borderRadius: const BorderRadius.vertical( bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical:5),
      child: RefreshIndicator(
        onRefresh: () async {
          getDatos(); _isLoading =true;
          setState(() {});
          const timeLimit =  Duration(seconds: 10);
          Timer(timeLimit, () {
            if(materialList.isEmpty){
              setState(() {
                _isLoading = false;
              });
            }else{
              _isLoading = false;
            }
          });
        },
          color: theme.colorScheme.secondary,
        child: futureList()
      ),
    );
  }
// sera el contenedor el cual tendra la lista de materiales

  Widget _squelingtonLoader(int n){
    List< Widget > buttonList = List.generate(n,(index) => cardSquelington( size.width ));
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding( padding: const EdgeInsets.symmetric( horizontal:0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: buttonList
          )
      ),
    );
  }

  Widget cardSquelington(double width){
    return SizedBox( width: width,  height:  36,
      child: Card(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(0) ),
        color: theme.backgroundColor,
        borderOnForeground: true,
        child: Shimmer.fromColors(
          baseColor: theme.primaryColor,
          highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
        const Color.fromRGBO(46, 61, 68, 1),
          enabled: true,
          child: Container( margin: const EdgeInsets.all(03) ,
              decoration: BoxDecoration( color: Colors.grey, borderRadius: BorderRadius.circular(0) )
          ),
        ),
      ),
    );
  }

 Future<List<MaterialesModels>> getDatos() async {
    try{
      return listMaterialesTemp;
    } catch ( e ) {
      print('Error al obtener permisos: $e');
      return [];
    }
 }
 Future<MaterialesModels?> getMaterialSelected() async {
    MaterialesModels? materialSelected;
    try{materialSelected = listMaterialesTemp.firstWhere((element) => element.selected);
    } catch (e){materialSelected = null;print(e);}
   return materialSelected;
 }

  // esta sera la lista de los materiales que se encuentran en la base de datos ( estara en el body)
  Widget _card( MaterialesModels materialItem,int index ) {
    return ValueListenableBuilder<bool>(
        valueListenable: materialItem.selectedNotifier,
        builder: (context, isSelected, child){
          return GestureDetector(
            child: MySwipeTileCard(
              verticalPadding: 2,
              colorBasico: !isSelected? theme.colorScheme.background:theme.colorScheme.secondary,
              iconColor: theme.colorScheme.onPrimary,
              containerB: Padding(padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: size.width/5-20,
                        child:  Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FAMILIA:',
                              style: TextStyle(fontWeight: FontWeight.bold, ),),
                            Text(materialItem.familiaNombre.toString(),
                                style: const TextStyle(fontWeight: FontWeight.normal)),
                            const SizedBox(height: 10,),
                            const Text('CÓDIGO:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(materialItem.codigoProducto,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width/5-20,
                        child:  Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SUB FAMILIA:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(materialItem.subFamiliaNombre.toString(),
                                style: const TextStyle(fontWeight: FontWeight.normal))
                          ],
                        ),
                      ),
                      SizedBox(width: size.width/5-20,
                        child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CÓDIGO:',style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(materialItem.codigoProducto, style: const TextStyle(fontWeight: FontWeight.normal)),
                              const SizedBox(height: 10,),
                              const Text('DESCRIPCIÓN:',style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(materialItem.descripcion,style: const TextStyle(fontWeight: FontWeight.normal))
                            ]
                        ),),
                      SizedBox(width: size.width/5-20,
                        child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTATUS:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(getStatusName(materialItem.estatus),
                                  style:  TextStyle(fontWeight: FontWeight.bold, color: statusColor[materialItem.estatus])),
                              const SizedBox(height: 10,),
                              const Text('PRECIO:',style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(materialItem.precioVenta.toString(), style: const TextStyle(fontWeight: FontWeight.normal)),
                            ]
                        ),),
                      SizedBox( width: width*.1 - 60, height: size.height*.1,
                        child: GestureDetector(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context)=>Dialog(
                                    surfaceTintColor: theme.colorScheme.background,
                                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10)),
                                    child: Container(
                                      width: 300, height: 300, padding: const EdgeInsets.all(15),
                                      child: Column( mainAxisSize: MainAxisSize.max , mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            SizedBox( width: size.width*.2, height: size.height*.3 ,
                                              child: PhotoView(
                                                imageProvider: imagenBase64String2(materialItem.foto),
                                              ),
                                            ),
                                            Text(" ${materialItem.codigoProducto} ",
                                              style: TextStyle( color: theme.colorScheme.onPrimary,
                                                  fontSize: 15, fontWeight: FontWeight.normal
                                              ),
                                            ),
                                          ]),
                                    )
                                )
                            );
                          },
                          child: Container(width:100, height:100 ,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.secondary,
                                backgroundBlendMode: BlendMode.color,
                              ),
                              child: imagenBase64String(materialItem.foto)),
                        ),
                      ),
                    ]),
              ),
              onTapLR: (){ goToEditMaterials(materialItem); },
              onTapRL: (){ print( "Delete trigger" );_deleteMaterial(materialItem); },
            ),
          );
        }
    );
  }
bool charge = true;
  //snapshot.connectionState ==  ConnectionState.waiting
  Widget futureList (){
    return FutureBuilder<List<MaterialesModels>>(
      future:  getDatos(),
      builder: ( context, snapshot  ){
        if(snapshot.connectionState ==  ConnectionState.waiting){
          return Center( child: _squelingtonLoader(18));
        } else {
          final listMat = snapshot.data ?? [];
          if( listMat.isNotEmpty  ){
            return Scrollbar(
              thumbVisibility: true, controller: _listViewScrollController,
                child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(
                        controller: _listViewScrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: listMaterialesTemp.length,
                        itemBuilder: ( context, index ){
                          return _view( listMaterialesTemp[index], index );
                        }
                    )
                ),
            );
          } else {
            if( _isLoading ){
              return Center( child: _squelingtonLoader(10));
            } else {
              return SingleChildScrollView( child: Center( child: NoDataWidget() ));
            }

          }
        }
      }
    );
  }

  Widget _view( MaterialesModels  materials, int index ){
    return  GestureDetector(
      onTap: (){
        if( materials.selected ){
          materials.toggleSelected();
        } else {
          listMaterialesTemp.where((element) => element != materials).forEach((element) {
            if( element.selected ){
              element.toggleSelected();
            }
          });
          materials.toggleSelected();
        }
      },
      onDoubleTap: (){goToEditMaterials(materials);},
      child: _pressed !=true? _card(materials, index) : _table(materials, index),
    );
  }

  Widget _table( MaterialesModels mats, int index ){
    return ValueListenableBuilder<bool>(
        valueListenable: mats.selectedNotifier,
        builder:( context, isSelected, child ){
         return  MySwipeTileCard(radius: 0, horizontalPadding: 2, verticalPadding: 0.5 ,
            colorBasico: !isSelected? (index%2 == 0 ?  theme.colorScheme.background : ( theme.colorScheme == GlobalThemData.lightColorScheme
                ? ColorPalette.backgroundLightColor
                : ColorPalette.backgroundDarkColor)): theme.colorScheme.secondary, iconColor: theme.colorScheme.onPrimary,
            containerB: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
                SizedBox(width: size.width/5.2, child: Text(mats.familiaNombre.toString().trim(), textAlign: TextAlign.left,),),
                SizedBox(width: size.width/5.2, child: Text(mats.subFamiliaNombre.toString(), textAlign: TextAlign.left,)),
                SizedBox(width: size.width/5.2, child: Text(mats.codigoProducto.toString(), textAlign: TextAlign.left,),),
                SizedBox(width: size.width/5.2, child: Text(getStatusName(mats.estatus), textAlign: TextAlign.left, style: TextStyle( color: statusColor[mats.estatus]  ),),),
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              ],
            ),
            onTapLR: (){goToEditMaterials(mats);},
            onTapRL: (){print( "Delete trigger" );_deleteMaterial(mats);},
          );
        }
    );
  }


  ImageProvider imagenBase64String2(String base64String){
    try{
      if( base64String  == null ){
        return const AssetImage('assets/materia.jpg',);
      } else {
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8list = Uint8List.fromList(bytes);
        return MemoryImage(uint8list);
      }
    } catch (e){
      return const AssetImage('assets/materia.jpg');
    }
  }

  Widget imagenBase64String(String base64String){
    try{
      if( base64String  != null && base64String.isNotEmpty ){
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8list = Uint8List.fromList(bytes);
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary
          ),
          child: Image.memory(
            scale: 2.0,
            uint8list,
            fit: BoxFit.cover,
            width: 100,
            height: 90,
          ),
        );

      } else {
        return  ClipRRect(
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/materia.jpg', fit: BoxFit.fill,),
        );
      }
    } catch (e) {
      return   Container(
          width: size.width/12-10,height: size.width/12-10,
          color: theme.colorScheme.background ,
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
              borderRadius: BorderRadiusDirectional.circular(5),
              child: Image.asset(
                  'assets/materia.jpg',
                  fit: BoxFit.cover,  height: 95, width: 95
              )
          )
         );
    }
  }
  
  
  Widget _searchBar() {
    return SizedBox(width: 250,
      child: MyTextfieldIcon(textStyle: TextStyle(color: theme.colorScheme.onPrimary,
        fontSize: 14, fontWeight: FontWeight.normal), focusNode: _focusNode,
        textColor: theme.colorScheme.onPrimary, labelText: 'Buscar material', textController: _searchController,
        floatingLabelStyle: TextStyle( color: theme.colorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.normal),
        suffixIcon: const Icon(Icons.search), backgroundColor: theme.colorScheme.secondary,
        onChanged: (value){
        applyFilter();
        },
      ),
    );
  }

  Widget _reportGenerator(){
    return Tooltip(message: 'Generar reporte de materiales',
      child: SizedBox(height: 50, width: 50,
        child: IconButton(
          onPressed:() async {
            MaterialesModels? materialSelected = await getMaterialSelected();
            if(materialSelected != null){
              generateMaterialsReport( context, materialSelected! );
            } else {
              MyCherryToast.showWarningSnackBar(context, theme, "No fue posible generar el reporte", "Seleccione un material para continuar");
            }},
          icon: const Icon(Icons.picture_as_pdf_outlined),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
            ),),
        ),
      ),
    );
  }

  Widget _edit (){
    return Tooltip(message: 'Editar',
      child:SizedBox(height: 50, width: 50,
        child: IconButton(
          onPressed:() async {
            MaterialesModels? materialSelected = await getMaterialSelected();
            if(materialSelected != null){
              goToEditMaterials(materialSelected);
            } else {
              MyCherryToast.showWarningSnackBar(context, theme, "No fue posible editar", "Seleccione un material para continuar");
            }
          },
          icon: const Icon(Icons.edit),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),
    );
  }

  Widget _delete (){
    return Tooltip(message: 'Eliminar',
      child: SizedBox(height: 50, width: 50,
        child: IconButton(
          onPressed:() async {
            MaterialesModels? materialSelected = await getMaterialSelected();
            if(materialSelected != null){
              _deleteMaterial(materialSelected);
            } else {
              MyCherryToast.showWarningSnackBar(context, theme, "No fue posible eliminar", "Seleccione un material para continuar");
            }

          },
          icon: const Icon(Icons.delete),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),
    );
  }

// Buttons from the header
  Widget _addMaterialButtonCompras() {
    return Tooltip(message: "Agregar material", waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {await addMaterials();}, icon: const Icon(IconLibrary.iconAdd),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }


  Widget _head(){
    return Container(height: 40,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: _pressed?0:20,),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _sortInHeaders(),
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

 List<Widget> _sortInHeaders (){
   Map<int, String> estatusTextos = {
     0: "INACTIVO",
     1: "ACTIVO",
     2: "BLOQUEADO",
     3: "FUERA DE LÍNEA"
   };
   List<String> statusDisplay = listStatuses.map((e) => estatusTextos[e] ?? e.toString()).toList();
   return [
     if(_pressed)...[
       const SizedBox(width: 15),
     ],
     SizedBox(width: width/5.3,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
       SizedBox(width: width/11,child: const Text("Familia", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
       Row(children: [
         InkWell(
           child:
           Icon(_sortIcon(_sortOrders["familiaNombre"]!)),
           onTap: (){ orderBy("familiaNombre"); },),
         InkWell(key: buttonKey1, child:Icon(Icons.filter_alt,
           color: familiaNombreString.length != materialList.map((e) => e.familiaNombre).toSet().toList().length? ColorPalette.informationColor
               : theme.colorScheme.onPrimary,
           ),
           onTap: (){handleButtonPress(buttonKey1.currentContext!,"familiaNombre",familiaNombreString);},
         )
       ],)
     ],),),
     SizedBox(
       width: width/5.3,
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
       SizedBox(
         width: width/11,
         child: const Text("Subfamilia",
           textAlign: TextAlign.left,
           style: TextStyle(fontSize: 14),),),
       Row(children: [
         InkWell(
           child:
           Icon(
               _sortIcon(_sortOrders["subFamiliaNombre"]!)),
           onTap: (){
             orderBy("subFamiliaNombre");
             },),
         InkWell(
           key: buttonKey2,
           child: Icon(Icons.filter_alt,
           color: subFamiliaNombreString.length!=materialList.map((e)=> e.subFamiliaNombre).toSet().toList().length?ColorPalette.informationColor
               :theme.colorScheme.onPrimary,
           ),
           onTap: () {
             handleButtonPress( buttonKey2.currentContext!, "subFamiliaNombre", subFamiliaNombreString);
             },)
       ],)
     ],),),
     SizedBox(
       width: width/5.3,
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
       SizedBox(width: width/11,
         child: const Text(
           "Tipo Poducto",
           textAlign: TextAlign.left,
           style: TextStyle(fontSize: 14),
         ),
       ),
       Row(children: [
         InkWell(
           child:
           Icon(
               _sortIcon(_sortOrders["codigoProducto"]!)),
           onTap: (){
             orderBy("codigoProducto");
             },),
         InkWell(
           key: buttonKey3,
           child: Icon(Icons.filter_alt,
           color: codigoProductoString.length != materialList.map((e) => e.codigoProducto).toSet().toList().length? ColorPalette.informationColor
               : theme.colorScheme.onPrimary,),onTap: (){
             handleButtonPress(buttonKey3.currentContext!, "codigoProducto", codigoProductoString); // "nombre"
             },)
       ],)
     ],),),
     SizedBox(
       width: width/5.4,
       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
       SizedBox(
         width: width/18,
         child: const Text("Estatus",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
       Row(children: [
         InkWell(
             child:
             Icon(_sortIcon(_sortOrders["estatus"]!)),
             onTap: (){orderBy("estatus");
             }),
         InkWell(
           key: buttonKey4,
           child: Icon(Icons.filter_alt,
           color: listStatuses.length!=materialList.map((e) => e.estatus).toList().length? ColorPalette.informationColor
               : theme.colorScheme.onPrimary,),
           onTap: () {
             handleButtonPress(buttonKey4.currentContext!, "estatus", statusDisplay);
             },)
       ],)
     ],),),
     SizedBox(width: getWidth(_pressed, size)),
   ];
 }


  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    Map<int, String> estatusTextos = {0:"INACTIVO",1:"ACTIVO",2:"BLOQUEADO",3:"FUERA DE LÍNEA"};
    List<String> list = getValue2(materialList, column, column == "estatus");
    List<String> listSelected = getValue2(listMaterialesTemp, column,column== "estatus");
    if(column =="estatus"){
      list = list.map((e)=> estatusTextos[int.parse(e)]??e ).toList();
      listSelected = listSelected.map((e)=>estatusTextos[int.parse(e)]?? e).toList();
    }
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button .localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
          button .localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size
    );
    var result = await showMenu(
      context: context, position: position, elevation: 8.0,
      constraints: const BoxConstraints(maxWidth: 274), surfaceTintColor: Colors.transparent,
      color:theme.colorScheme == GlobalThemData.lightColorScheme?  const Color(0xFFF8F8F8):const Color(0xFF303030),
      items: < PopupMenuEntry< String > >[
        PopupMenuItem <String> ( enabled: false, padding: EdgeInsets.zero,
          child: MyPopupMenuButton(items: list , selectedItems: listSelected ),
        )
      ],

    );
    await appySort2(result, column, listA);
  }

  Future<void> getMaterials() async{
    // Llama al metodo getProveedores del proveedoresProvider
    try{
      print("Obteniendo Materiales...");
      materialList = [];
      MaterialesController materialesController = MaterialesController();
      List<MaterialesModels> materiales = await materialesController.getMateriales([0,1,2,3]);
      setState(() {
        materialList = materiales;
        listMaterialesTemp = List.from(materialList);
        familiaNombreString = materialList.map((e)=>e.familiaNombre.toString()).toSet().toList();
        subFamiliaNombreString = materialList.map((e)=>e.subFamiliaNombre.toString()).toSet().toList();
        codigoProductoString = materialList.map((e)=>e.codigoProducto ).toSet().toList();
        listStatuses = materialList.map((e) =>e.estatus).toList();
        resetSortOrder();
        applyFilter();
      });
    }catch(e){
      String error = await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomSnackBar.showErrorSnackBar(context, '${Texts.errorGettingData}. $error');
      print('Error al obtener materiales: $error');
    }
  }

  String getValue( MaterialesModels material,  String column){
    switch (column){
      case "familiaNombre":
        return material.familiaNombre.toString();
      case "subFamiliaNombre":
        return material.subFamiliaNombre.toString();
      case "codigoProducto":
        return material.codigoProducto;
      case "estatus" :
        return material.estatus.toString();
      default:
        return '';
    }
  }

  List<String> getValue2(List<MaterialesModels> materiales, String column, bool removeDuplicates) {
    List<String> list = materiales.map((material) {
      switch (column) {
        case "familiaNombre":
          return material.familiaNombre.toString();
        case "subFamiliaNombre":
          return material.subFamiliaNombre.toString();
        case "codigoProducto":
          return material.codigoProducto;
        case "estatus":
          return material.estatus.toString();
        default:
          return '';
      }
    }).toList();
    return removeDuplicates ? list.toSet().toList() : list;
  }

  Future<void> appySort2(String? result, String column, List<String> listA) async {
    if(result != null){
      if(result == "AZ" || result == "ZA") {
        _sortOrder = result == "AZ" ? 1 : 2;
        applySort(column);
      }else if(result == "ClearAll"){
        _searchController.clear();
        listA.clear();
        listA.addAll(getValue2(materialList, column, column!="estauts"));
        if(column == "estatus"){
          listStatuses.clear();
          listStatuses.addAll([0, 1, 2, 3]);
          listMaterialesTemp.clear();
          listMaterialesTemp.addAll(materialList);
        }else{
          listMaterialesTemp.clear();
          listMaterialesTemp.addAll(materialList);
        }
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        if(column=="estatus"){
          Map<String, int> reverseEstatusTextos = {
            "INACTIVO": 0,
            "ACTIVO": 1,
            "BLOQUEADO": 2,
            "FUERA DE LÍNEA": 3
          };
          List<String> convertedList = listA.map((text) {
            if (reverseEstatusTextos.containsKey(text)){
              return reverseEstatusTextos[text]!.toString();
            } else {
              print("Warning: '$text' no está en el mapa de estados." );
              return '';
            }
          }).toList();
          convertedList = convertedList.where((element) => element.isNotEmpty).toList();
          listStatuses.clear();
          listStatuses.addAll(convertedList.map(int.parse));
          await resetList();
        }
        await resetList();
      }
      setState(() {});
    }
  }

sortList( List<MaterialesModels> materials, String  Function(MaterialesModels) getValue, int sortOrder ){
  materials.sort((a,b){
    int compare = getValue(a).compareTo(getValue(b));
    return  sortOrder == 1 ? compare: -compare;
  });
}

  void applySort(String column) {
    // Establecer todos los valores en 0
    _sortOrders.updateAll((key, value) => 0);
    // Actualizar solo el valor que necesitas
    _sortOrders[column] = _sortOrder;
    sortList(listMaterialesTemp, (materiales) => getValue(materiales, column), _sortOrder);
  }
  void applySort2(){
    _sortOrders.forEach((key, value) {
      if (value != 0) {
        listMaterialesTemp.sort(sortFunctions[key]?[value]);
      }
    });
  }
  Future<void> applyFilter2(String? result, String column, List<String> listA) async {
    if(result != null){
      if(result == "AZ" || result == "ZA") {
        _sortOrder = result == "AZ" ? 1 : 2;
        applySort(column);
      }else if(result == "ClearAll"){
        _searchController.clear();
        listA.clear();
        listA.addAll(getValue2(materialList, column, column!="estatus"));
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
      }
      setState(() {});
    }
  }

  void applyFilter (){
    listMaterialesTemp = List.from(materialList);
    if( _searchController.text.isNotEmpty ){
      listMaterialesTemp = listMaterialesTemp.where((material) =>
      material.familiaNombre.toString().toLowerCase().contains(_searchController.text.toLowerCase())
          || "${ material.familiaNombre} ${material.subFamiliaNombre} ${material.codigoProducto} "
          .toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      debounce(() {
        setState(() {
          _focusNode.requestFocus();
        });
      }, 500);
    }
  }

  void orderBy(String s) {
    _sortOrders[s] = _sortOrders[s] == 0 || _sortOrders[s] ==2  ? 1 : 2;
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

  void resetSortOrder(){
    _sortOrders.updateAll((key, value) => 0);
  }

  List<MaterialesModels> filterList(List<MaterialesModels> materiales, List<String> strings, String Function(MaterialesModels) getValue) {
    return materiales.where((material) => strings.contains(getValue(material))).toList();
  }

  Future<void> resetList() async {
    listMaterialesTemp = filterList( materialList,familiaNombreString,(materiales) => materiales.familiaNombre.toString());
    listMaterialesTemp = filterList( listMaterialesTemp,subFamiliaNombreString, (materiales) => materiales.subFamiliaNombre.toString());
    listMaterialesTemp = filterList( listMaterialesTemp,codigoProductoString,(materiales) => materiales.codigoProducto);
    listMaterialesTemp = filterList( listMaterialesTemp, listStatuses.map((e)=> e.toString()).toList(), (materiales) => materiales.estatus.toString());
  }

  Future<void> addMaterials() async {
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      List<FamiliaModel> listFamilia = await _getFamilia();
      List<MonedaModels> listMonedas = await _getMonedas();
      // List<MaterialesModels> listMatSupliier = await _getMaterialSupplier();
      print("Familia: ${listFamilia.length}");
      await  myShowDialogScale( AltaMaterialesScreen(familia: listFamilia, moneda: listMonedas,),
        context,width: size.width *.70,);
      LoadingDialog.hideLoadingDialog(context);
      await getMaterials();
      setState(() {});
  }

  Future<void> _deleteMaterial(MaterialesModels materiales) async {
    try{
      if (!deleteMaterial) {
        print("Attempting to delete material with ID: ${materiales.idMaterial}");
        CustomAwesomeDialog(
          title: '¿Estas seguro que deseas desacticar el material?',
          desc: 'Material ${materiales.familiaNombre}',
          btnOkOnPress: () async {
              if (materiales.idMaterial != null) {
                LoadingDialog.showLoadingDialog(context, "Eliminando ${materiales.idMaterial}");
                MaterialesController materialesController = MaterialesController();
                bool delete = await materialesController.deleteMterial(materiales.idMaterial!);
                LoadingDialog.hideLoadingDialog(context);
                if (delete) {
                  print("Material deleted successfully");
                  CustomAwesomeDialog(
                    title: '${materiales.familiaNombre} desactivado',
                    desc: 'El material se ha desactivado correctamente correctamente',
                    btnOkOnPress: ()async  {
                      await getMaterials();
                      setState(() {});
                    },
                    btnCancelOnPress: () {},
                  ).showSuccess(context);
                } else {
                  print("Failed to delete material");
                  CustomAwesomeDialog(
                    title: 'Error al eliminar ${materiales.familiaNombre}',
                    desc: 'No se ha podido eliminar el material',
                    btnOkOnPress: () {},
                    btnCancelOnPress: () {},
                  ).showError(context);
                }}

          },
          btnCancelOnPress: () {},
        ).showQuestion(context);
      } else {
        print("deleteMaterial is set to false");
      }
    } catch (e){
      print(e);
    }

  }

    Future<void> goToEditMaterials ( MaterialesModels material,) async {
      List<FamiliaModel> listFamilia = await _getFamilia();
      List<MonedaModels> monedas = await _getMonedas();
    CustomAwesomeDialog(
        title: '¿Estas seguro que deseas editar el registro?',
        desc: 'Material: ${material.familiaNombre}',
        btnOkOnPress: () async {
          await myShowDialogScale( EditMateriaScreen(material: material, familia: listFamilia, ), context,width: size.width *.70);
          await getMaterials();
          setState(() {});
          },

        btnCancelOnPress: (){ },
    ).showQuestion(context);
  }
  double getWidth( bool pressed, Size size  ){
    if( pressed || size.width < 1200 ){
      return 5;
    } else {
      return 97;
    }
  }

  Future<List<FamiliaModel>> _getFamilia() async {
    List<FamiliaModel> listFamilia = [];

    try{
      FamiliaController familiaController = FamiliaController();
      listFamilia = await familiaController.getFamiliaComplete();
    } catch(e){
      print('error al obtener Familia $e');
    }
    return listFamilia;
  }

  Future<List< MonedaModels >> _getMonedas ()async {
    List<MonedaModels> listaMonedas = [];
    try{
      MonedaController monedaController = MonedaController();
      listaMonedas = await  monedaController.getMonedas();
  } catch (e){
      print(e);

}
    return listaMonedas;
}

  Future<List<MaterialesModels>> _getMaterialSupplier() async {
    List<MaterialesModels> listMaterialSupplier = [];
    var status = [ 1,2,3 ];
    try {
      MaterialesController materialesController = MaterialesController();
      listMaterialSupplier = await materialesController.getMateriales(status);
    } catch (e) {
      print(e);
    }
    return listMaterialSupplier;
  }

  void debounce( VoidCallback callback, int milliseconds ){
    Timer.periodic(Duration( milliseconds: milliseconds ), (timer) {
      timer.cancel();
      callback();
    });
  }

 void  aplicarFiltro(){
    if(_searchBarContoller.text.isNotEmpty ){
      listMaterialesTemp = materialList;
    listMaterialesTemp = listMaterialesTemp.where((mat) =>
    mat.familiaNombre!.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
        "${mat.codigoProducto} ${mat.familiaNombre} ${mat.subFamiliaNombre}".toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
        mat.descripcion.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
        mat.codigoProducto.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
        mat.codigoProducto.toLowerCase().contains(_searchBarContoller.text.toLowerCase())
    ).toList();
      debounce(() {
        setState(() {
          FocusScope.of(context).requestFocus(_focusNode);
        });
      }, 500);
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          listMaterialesTemp = materialList;
        });
      });

    }
  }
  void  aplicarFiltroPrueba(){
    if(_searchBarContoller.text.isNotEmpty ){
      listMaterialesTemp = materialList;
      listMaterialesTemp = listMaterialesTemp.where((mat) =>
      mat.familiaNombre!.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
          "${mat.codigoProducto} ${mat.familiaNombre} ${mat.subFamiliaNombre}".toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
          mat.descripcion.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
          mat.codigoProducto.toLowerCase().contains(_searchBarContoller.text.toLowerCase()) ||
          mat.codigoProducto.toLowerCase().contains(_searchBarContoller.text.toLowerCase())
      ).toList();
    }
  }

  ///porsí lo ocupo
  Future<List<SubFamiliaModel>> _getSubFamilia() async {
    List<SubFamiliaModel> listSubFamilia = [];
    try{
      SubFamiliaController subFamiliaController = SubFamiliaController();
      listSubFamilia = await subFamiliaController.getSubFamilias();
    } catch ( e ){
      print(e);
    }
    return listSubFamilia;
  }
}
