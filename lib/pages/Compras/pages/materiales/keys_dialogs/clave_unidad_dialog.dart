import 'dart:async';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/widgets/PopUpMenu/PopupMenuFilter.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';

class ClaveUnidadDialog extends StatefulWidget {
  const ClaveUnidadDialog({super.key});

  @override
  State<ClaveUnidadDialog> createState() => _ClaveUnidadDialogState();
}


class _ClaveUnidadDialogState extends State<ClaveUnidadDialog> {
  bool pressed=true;
  bool arrows = true;
  int _sortName = 0;
  final _pressedKey = GlobalKey();
  final _claveController = ScrollController();
  final  _filterByController = TextEditingController();
  final  _searchController = TextEditingController();
  String selectedItem = 'Clave';
  List<String> listClaveIdString = [];
  List<String> listNombreClaveString = [];
  List<ClaveUnidad> _claveUnidadList = [];

  final _gkey = GlobalKey();
  final _buttonKey1 = GlobalKey();
  final _buttonKey2 = GlobalKey();

  final _foucusSearch = FocusNode();

  List<ClaveUnidad> listTemp = [];

  late ThemeData theme; late Size size;


    List<ClaveUnidad> claveUnidadList = List.generate(30, (index) {
      int randomizer = Random().nextInt(1000);
      return ClaveUnidad(
        claveId: '${index*randomizer}',
        nombreClave: 'descripcíon de clave- $index',
      );
    });

    getDatos(){
      claveUnidadList;
      listNombreClaveString = getValues2(claveUnidadList, "claveId", false);
      listNombreClaveString = getValues2(claveUnidadList, "nombreClave", false);
    }

 final Map<String, int> _sortNames = {
    "claveId":0,
    "nombreClave":0,
  };

 Map<String, Map<int, int Function(ClaveUnidad, ClaveUnidad)>> sortClave ={
   "claveId":{
     1:(ClaveUnidad a,ClaveUnidad b)=> a.claveId.compareTo(b.claveId),
     2:(ClaveUnidad a,ClaveUnidad b)=> b.claveId.compareTo(a.claveId),
   },
   "nombreClave":{
     1:(ClaveUnidad a,ClaveUnidad b)=> a.nombreClave.compareTo(b.nombreClave),
     2:(ClaveUnidad a,ClaveUnidad b)=> b.nombreClave.compareTo(a.nombreClave),
   },
  };

@override
  void initState() {
  getTempList();
  getDatos();
    super.initState();
  }

@override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    return PressedKeyListener(
      Gkey: _pressedKey,
        keyActions: { LogicalKeyboardKey.escape:(){ exitDialog(); } },
        child:body(),
    );
  }

  Widget body(){
    return Column(
      children: [
        _toolBar(),
        // _filter(),
        searchBar(),
        _containers(),
      ],
    );
  }

Widget _toolBar(){
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(width: 10,),
        Text('Clave de unidad', style: TextStyle(fontSize: 15,color: theme.colorScheme.onPrimary),),
        const Spacer(),
        Container(
          height: 27,width: 27,
          decoration: BoxDecoration( color: theme.colorScheme.surface,borderRadius: const BorderRadius.all(Radius.circular(25))),
          child: IconButton(
            onPressed: () {
              exitDialog();
            },
            icon:  Icon(Icons.close, color: Colors.red,size: size.height*.015,),
          ),
        ),
        const SizedBox(width: 10,),
      ],
    ),
  );
}

  Widget _containers(){
    return Column(
      children:[
        _labelContainer(),
        _claveNombreConteainer(),
      ]
    );
  }

  void debounce( VoidCallback callback, int milliseconds ){
  Timer.periodic(Duration( milliseconds: milliseconds ), (timer) {
    timer.cancel();
    callback();
  });
  }

void searchBarFilter() {
  if( _searchController.text.isNotEmpty ){
    listTemp = claveUnidadList.where((clave) {
      return clave.claveId.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          clave.nombreClave.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
    debounce( (){
      setState(() {
      _foucusSearch.requestFocus();
      }); }, 200 );
  } else {
    setState(() {
    listTemp = claveUnidadList;
    });
  }
}


  Widget _labelContainer(){
    return Container(
      margin: const EdgeInsets.only(top: 5),
      height: 55,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          SizedBox( width: size.width/7,child: Row(
            children: [
              Text( "Clave de unidad",style: TextStyle(fontSize: 14,color: theme.colorScheme.onPrimary ), ),
               const SizedBox(width: 5,),
               Row( mainAxisAlignment: MainAxisAlignment.center , children: [
                InkWell(
                    onTap:(){order("claveId");},
                    child: Icon(_sortIcon(_sortNames["claveId"]!),size:size.width*.013)
                ),
                InkWell(
                  key: _buttonKey1,
                  onTap:(){ handlePopUp(_buttonKey1.currentContext!,"claveId",listClaveIdString);},
                  child : Icon(Icons.filter_alt ,size:size.width*.012,
                      color: listClaveIdString.length != claveUnidadList.map((e)=>e.claveId ).toList().length?
                  ColorPalette.informationColor:theme.colorScheme.onPrimary
                  ),
                ),
              ],)
            ],
          ),),
          const SizedBox.shrink(),
          SizedBox(width: size.width/5,child: Row(
            children: [
              Text("Nombre",style: TextStyle(fontSize: 14,color: theme.colorScheme.onPrimary) ),
              const SizedBox(width: 5,),
              Row( mainAxisAlignment: MainAxisAlignment.center , children: [
                InkWell(
                    child: Icon(_sortIcon( _sortNames["nombreClave"]!),  size: size.width*.013,),
                    onTap: (){ order("nombreClave");},
                ),
                InkWell(
                  key: _buttonKey2,
                    child: Icon( Icons.filter_alt, size: size.width*.012,
                      color: listNombreClaveString.length != claveUnidadList.map((e)=>e.nombreClave ).toList().length
                          ? ColorPalette.informationColor:theme.colorScheme.onPrimary,),
                  onTap:(){
                    handlePopUp(_buttonKey2.currentContext!,"nombreClave",listNombreClaveString);
                },
                ),
              ],)
            ],
          ),),
        ],
      ),
    );
  }


  Widget _claveNombreConteainer(){
    return Container(
      height: size.height-500,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(10)
        ),
      ),
      child: Scrollbar(
        controller: _claveController,
        child: FadingEdgeScrollView.fromScrollView(
          gradientFractionOnEnd: .25,
          child: ListView.builder(
            controller: _claveController,
            itemCount: listTemp.length,
            itemBuilder: (context, index) {
              var item = listTemp[index];
              getTempList();
              resetSortOrder();
              return _card(index, item);
            },
          ),
        ),
      )
    );
  }

Widget _card(int index, item){
  return GestureDetector(
    onTap: (){
      print(item.claveId);
      CustomAwesomeDialog(
        title: 'Clave Unididad',
        desc: '¿Deseas seleccionar la siguiente clave unidad?\nClave Unidad: ${item.claveId}\nNombre: ${item.nombreClave}',
        btnOkOnPress: () {
          Navigator.of(context).pop(item.claveId);
        },
        btnCancelOnPress: () {  },
      ).showQuestion(context);
    },
    child: _cardClaveNombre(index, item),
  );
}

  Widget _cardClaveNombre(index, ClaveUnidad item){
    return MySwipeTileCard(
      radius: 0, horizontalPadding: 1, verticalPadding: 1,
      colorBasico: index%2==0? theme.colorScheme.background
          : ( theme.colorScheme == GlobalThemData.lightColorScheme
          ? ColorPalette.backgroundLightColor:ColorPalette.backgroundDarkColor
      ),
        containerB: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            SizedBox( width: size.width/7,child: Text( item.claveId,style: TextStyle(color: theme.colorScheme.onPrimary ), ),),
            const SizedBox.shrink(),
            SizedBox(width: size.width/5, child: Text(item.nombreClave,style: TextStyle(color: theme.colorScheme.onPrimary) ),),
          ],
        ),
        onTapLR: (){},
        onTapRL: (){}
    );
  }

  Widget _myFilter(Widget widget ,{double widgetWidth = 0.15}){
    return Container(
      margin: const EdgeInsets.only( top: 10 ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children:[
          const SizedBox(height: 10,),
          SizedBox(
            width:size.width*widgetWidth,
              child: widget),
        ]
      ),
    );
  }

IconData _sortIcon(int sortInt){
    if(sortInt == 0){
      return Icons.swap_vert;
    } else if( sortInt == 1 ){
      return Icons.arrow_upward_rounded;
    } else{
      return Icons.arrow_downward_rounded;
    }
}

void order( String obj ){
  setState((){
    _sortNames[obj] = _sortNames[obj] == 0||_sortNames[obj]== 2? 1:2 ;
    _sortNames.updateAll((key,value){
      if(key != obj){
        return 0;
      } else {
        return _sortNames[key]??0;
      }
    });
    applysort2();
    setState(() {});
  });
}

  void applysort2(){
    _sortNames.forEach((key, value) {
      if( value != 0 ){
        listTemp.sort( sortClave[key]?[value]);
      }
    });
  }

  void  handlePopUp(BuildContext context, String columna,List<String> listA  ) async {
    List<String> list =  getValues2(claveUnidadList, columna, columna == "claveId"|| columna == "nombreClave");
    List<String> listSelected = getValues2(listTemp, columna, columna == "claveId"|| columna == "nombreClave");
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal( button.size.bottomCenter(Offset.zero), ancestor: overlay ),
        button.localToGlobal( button.size.bottomCenter(Offset.zero), ancestor: overlay ),
      ),
      Offset.zero & overlay.size
    );
    var result = await showMenu(
        context: context, position: position, elevation: 8.0,
        constraints: const BoxConstraints( maxWidth: 274), surfaceTintColor: Colors.transparent,
        color: theme.colorScheme == GlobalThemData.lightColorScheme ? const Color(0xFFF8F8F8): const Color(0xFF303030),
        items: <PopupMenuEntry<String>>[
           PopupMenuItem<String> (enabled: false, padding: EdgeInsets.zero,
             child: MyPopupMenuButton(items: list, selectedItems: listSelected ,order:false),
          )
        ]
    );
    await sort2( result.toString(), columna, listA );
  }

  Future<void> sort2( String result, String columna, List<String> listA) async {
    if( result != null ){
      if( result == "AZ" || result =="ZA" ) {
        _sortName = result == "AZ" ? 1 : 2;
        applySort(columna);
      } else if(result == "ClearAll" ){
            _searchController.clear();
            listA.clear();
            listA.addAll( getValues2(claveUnidadList, columna, columna!="claveId"|| columna!="nombreClave"));
        await resetList();
      }else{
        listA.clear();
        listA.addAll( result.split("%^"));
        await resetList();
      }
      setState((){});
    }
  }

  List<ClaveUnidad> filterList( List<ClaveUnidad> clave, List<String> strings , Function( ClaveUnidad ) getValue ){
    return clave.where( (clave)=> strings.contains(getValue(clave))).toList();
  }
  Future<void> resetList() async{
   listTemp = filterList( claveUnidadList,listClaveIdString, (clave)=>clave.claveId );
   listTemp = filterList( claveUnidadList,listNombreClaveString, (clave)=>clave.claveId );
  }
void resetSortOrder(){
    _sortNames.updateAll((key, value) => 0);
}
  applySort(String columna){
    _sortNames.updateAll((key, value) => 0);
    _sortNames[columna] = _sortName;
    sortList( listTemp, (claves)=> getValue( claves, columna ), _sortName );

  }
  String getValue(ClaveUnidad clave, String column){
    switch( column ){
      case"claveId":
        return clave.claveId;
      case "nombreClave":
        return clave.nombreClave;
      default: return'';
    }
  }

  List<String> getValues2( List<ClaveUnidad> clave, String columna, bool removeDuplicates){
    List<String> list = clave.map((clave){
      switch(columna){
        case "claveId":
          return clave.claveId;
        case "nombreClave":
          return clave.nombreClave;
        default:
          return'';
      }
    }).toList();
    return removeDuplicates? list.toSet().toList():list;
  }

  sortList( List<ClaveUnidad> clave,String Function(ClaveUnidad) getValue, int sortOrder ){
    clave.sort((a,b){
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare: -compare;
    });
  }

  getTempList() {
    listTemp = claveUnidadList;
    return listTemp;
  }
  void exitDialog() {
    CustomAwesomeDialog(
      title: '¡ Saldras de este diálogo !', desc: '',
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },
      btnCancelOnPress: () {},).showQuestion(context);
  }
  Widget searchBar(){
        return MyTextfieldIcon(
          labelText: 'Buscar clave',
          textController: _searchController,
          focusNode: _foucusSearch,
          suffixIcon: const Icon(Icons.search),
          onChanged: (value){
            searchBarFilter();
          },
        );
  }
}

class ClaveUnidad{
  final String nombreClave;
  final String claveId;
  ClaveUnidad(
  {
    required this.claveId,
    required this.nombreClave,
});
}