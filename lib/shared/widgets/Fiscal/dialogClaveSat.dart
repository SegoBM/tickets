import 'dart:async';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/ConfigModels/usuario.dart';
import '../../utils/color_palette.dart';
import '../../utils/icon_library.dart';
import '../../utils/texts.dart';
import '../PopUpMenu/PopupMenuFilter.dart';
import '../card/my_swipe_tile_card.dart';

class DialogClaveSat extends StatefulWidget {
  @override
  _DialogClaveSatState createState() => _DialogClaveSatState();
}

class _DialogClaveSatState extends State<DialogClaveSat> {
  late ThemeData theme; late Size size;
  late double width;
  final _key = GlobalKey(), buttonKey1 = GlobalKey(), buttonKey2 = GlobalKey(), buttonKey3 = GlobalKey();
  List<String> listUsuariosString = [], listNombreString = [],
      listTipoUsuarioString = [], listDepartamentoString = [], listEstatusString = [],
      itemsDepartments = [], selectedItems = [], selectedDepartmentsItems = [];
  List<ClaveSat> listClaveSat = [], listClaveSatTemp = [];
  int _sortOrder = 0;
  Map<String, int> sortOrders = {
    "claveSat": 0,
    "descripcion": 0,
    "concepto": 0,
  };
  bool _isLoading = true;
  final ScrollController scrollController2 = ScrollController();

  @override
  void initState(){
    getDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context); size = MediaQuery.of(context).size; width = size.width;
    return AlertDialog(
      title: Text('Clave SAT', style: TextStyle(color: theme.colorScheme.onPrimary),),
      content: SingleChildScrollView(
        child: Column(children: [
          encabezados(),
          viewCard(),
        ],)
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onPrimary, minimumSize: const Size(150, 40),
            backgroundColor: theme.colorScheme.secondary,),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
  Widget encabezados ( ){
    return Container(height: 40,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 0,),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: encabezadosCard(),
            ))
    );
  }
  List<Widget> encabezadosCard(){
    return [
      const SizedBox(width: 15,),
      SizedBox(width: width/5,child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Clave SAT", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(key: buttonKey1,child: Icon(Icons.filter_alt,
            color: listUsuariosString.length != listClaveSat.map((e) => e.claveSat).toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey1.currentContext!, "claveSat", listUsuariosString);},)
        ],)
      ],),),
      const SizedBox(width: 5,),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Descripción", textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
         InkWell(key: buttonKey2,child: Icon(Icons.filter_alt,
            color: listNombreString.length != listClaveSat.map((e) => e.descripcion).toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),
            onTap: () {handleButtonPress(buttonKey2.currentContext!, "descripcion", listNombreString);},)
        ],)
      ],),),
      const SizedBox(width: 5,),
      SizedBox(width: width/5, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        SizedBox(width: width/10,child: const Text("Concepto",  textAlign: TextAlign.left, style: TextStyle(fontSize: 14),),),
        Row(children: [
          InkWell(key: buttonKey3,child: Icon(Icons.filter_alt,
            color: listTipoUsuarioString.length != listClaveSat.map((e) => e.concepto).toSet().toList().length? ColorPalette.informationColor
                : theme.colorScheme.onPrimary,),onTap: (){handleButtonPress(buttonKey3.currentContext!, "concepto", listTipoUsuarioString);},)
        ],)
      ],),),
      const SizedBox(width: 15,),
    ];
  }

  void handleButtonPress(BuildContext context, String column, List<String> listA) async {
    List<String> list = getValue2(listClaveSat, column, column != "claveSat" && column != "descripcion");
    List<String> listSelected = getValue2(listClaveSatTemp, column, column != "claveSat" && column != "descripcion");
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
            child:MyPopupMenuButton(items: list, selectedItems: listSelected, order: false,)
        ),
      ],
    );
    await aplicarFiltro2(result, column, listA);
  }

  List<String> getValue2(List<ClaveSat> claveSat, String column, bool removeDuplicates) {
    List<String> list = claveSat.map((claveSat) {
      switch (column) {
        case "claveSat":
          return claveSat.claveSat;
        case "descripcion":
          return claveSat.descripcion;
        case "concepto":
          return claveSat.concepto;
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
        //_searchController.clear();
        listA.clear();
        listA.addAll(getValue2(listClaveSat, column, column != "claveSat" && column != "descripcion"));
        await resetList();
      } else {
        listA.clear();
        listA.addAll(result.split("%^"));
        await resetList();
      }
      setState(() {});
    }
  }
  void applySort(String column) {
    // Establecer todos los valores en 0
    sortOrders.updateAll((key, value) => 0);
    // Actualizar solo el valor que necesitas
    sortOrders[column] = _sortOrder;
    sortList(listClaveSatTemp, (usuario) => getValue(usuario, column), _sortOrder);
  }
  void sortList(List<ClaveSat> usuarios, String Function(ClaveSat) getValue, int sortOrder) {
    usuarios.sort((a, b) {
      int compare = getValue(a).compareTo(getValue(b));
      return sortOrder == 1 ? compare : -compare;
    });
  }
  String getValue(ClaveSat claveSat, String column) {
    switch (column) {
      case "claveSat":
        return claveSat.claveSat;
      case "descripcion":
        return claveSat.descripcion;
      case "concepto":
        return claveSat.concepto;
      default:
        return '';
    }
  }
  Future<void> resetList() async {
    listClaveSatTemp = filterList(listClaveSat, listUsuariosString, (usuario) => usuario.claveSat);
    listClaveSatTemp = filterList(listClaveSatTemp, listNombreString, (usuario) => usuario.descripcion);
    listClaveSatTemp = filterList(listClaveSatTemp, listTipoUsuarioString, (usuario) => usuario.concepto);
  }

  List<ClaveSat> filterList(List<ClaveSat> usuarios, List<String> strings, String Function(ClaveSat) getValue) {
    return usuarios.where((usuario) => strings.contains(getValue(usuario))).toList();
  }

  Widget viewCard(){
    return Container(height: 465,
      decoration: BoxDecoration(color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SizedBox(width: ((width/5)*3)+40, height: 450,
        child: futureList(),
      ),
    );
  }

  Widget futureList(){
    return Scrollbar(
      thumbVisibility: true, controller: scrollController2,
      child: FadingEdgeScrollView.fromScrollView(
        child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController2, itemCount: listClaveSatTemp.length,
          itemBuilder: (context, index) {
            return _card(listClaveSatTemp[index], index);
          },
        ),
      ),
    );
  }

  Widget _card(ClaveSat claveSat, int index) {
    return GestureDetector(child: mySwipeCard(claveSat, index), onTap: (){
        CustomAwesomeDialog(title: 'Clave SAT',
          desc: '¿Deseas seleccionar la siguiente clave SAT?\nClave SAT: ${claveSat.claveSat}\nDescripción: ${claveSat.descripcion}\nConcepto: ${claveSat.concepto}',
          btnCancelOnPress: (){}, btnOkOnPress: (){Navigator.of(context).pop(claveSat.claveSat);},).showQuestion(context);
    },);
  }

  Widget mySwipeCard(ClaveSat claveSat, int index){
    return Card(color: theme.colorScheme.background, margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: width / 5, child: Text(claveSat.claveSat, textAlign: TextAlign.left,)),
          SizedBox(width: width / 5, child: Text(claveSat.descripcion, textAlign: TextAlign.left,)),
          SizedBox(width: width / 5, child: Text(claveSat.concepto.toUpperCase(), textAlign: TextAlign.left,)),
        ],
      ),));
  }
  Future<void> getDatos() async {
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSat.add(ClaveSat(claveSat: '16565', descripcion: 'fae', concepto: 'afefa'));
    listClaveSatTemp = listClaveSat;
    listUsuariosString = getValue2(listClaveSat, "claveSat", false);
    listNombreString = getValue2(listClaveSat, "descripcion", false);
    listTipoUsuarioString = getValue2(listClaveSat, "concepto", true);
    _isLoading = false;
  }
}
class ClaveSat {
  final String claveSat;
  final String descripcion;
  final String concepto;

  ClaveSat({
    required this.claveSat,
    required this.descripcion,
    required this.concepto,
  });
}