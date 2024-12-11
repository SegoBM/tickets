import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';

import '../../../config/theme/app_theme.dart';
class MyPopupMenuButton extends StatefulWidget {
  List<String> items;
  List<String> selectedItems;
  bool order;
  MyPopupMenuButton({Key? key, required this.items, required this.selectedItems, this.order = true}) : super(key: key);
  @override
  _MyPopupMenuButtonState createState() => _MyPopupMenuButtonState();
}

class _MyPopupMenuButtonState extends State<MyPopupMenuButton> {
  bool _isVisible = true;
  bool? _selectAll;

  late List<String> items;
  late List<String> selectedItems;
  TextEditingController _searchController = TextEditingController();
  @override
  void initState(){
    items = widget.items;
    selectedItems = widget.selectedItems;
    if(items.length == selectedItems.length) {
      _selectAll = true;
    }else if(selectedItems.isEmpty) {
      _selectAll = false;
    }else{
      _selectAll = null;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      color: theme.colorScheme == GlobalThemData.lightColorScheme? const Color(0xFFF8F8F8):const Color(0xFF303030),
      child: Column(
        children: <Widget>[
          if(widget.order == true)...[
            MaterialButton(padding: EdgeInsets.all(15),onPressed: (){
              Navigator.of(context).pop("AZ");
            }, child: const Row(children: [
              Icon(IconData(0xe700, fontFamily: 'FilterIcon',
                  fontPackage: 'syncfusion_flutter_datagrid')),
              SizedBox(width: 10,),
              Text('Ordenar de la A a la Z'),
            ],),),
            MaterialButton(padding: EdgeInsets.all(15),onPressed: (){
              Navigator.of(context).pop("ZA");
            }, child: const Row(children: [
              Icon(IconData(0xe701, fontFamily: 'FilterIcon',
                  fontPackage: 'syncfusion_flutter_datagrid')),
              SizedBox(width: 10,),
              Text('Ordenar de Z a la A'),
            ],),),
            const SizedBox(height: 5,),
            const Divider(indent: 8.0, endIndent: 8.0,height: 2,),
            const SizedBox(height: 5,),
          ],
          MaterialButton(
            enableFeedback: false,
            padding: const EdgeInsets.all(15),onPressed: (){
            Navigator.of(context).pop("ClearAll");
          }, child: Row(children: [
            const Icon(IconData(0xe703, fontFamily: 'FilterIcon',
                fontPackage: 'syncfusion_flutter_datagrid')),
            const SizedBox(width: 10,),
            Opacity(
              opacity: widget.items.length==widget.selectedItems.length? 0.5 : 1.0 , // Si no hay filtro aplicado, la opacidad será 0.5
              child: const Text('Eliminar los filtros seleccionados'),
            ),
          ],),),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SizedBox(
              height: 35,
              child: TextField(
                style: TextStyle(color: theme.colorScheme.onPrimary),
                controller: _searchController,
                onChanged: (value) {
                  items = widget.items.where((element) => element.toLowerCase().contains(value.toLowerCase())).toList();
                  setState(() {});
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.secondary,
                    ),
                  ),

                  suffixIcon: Visibility(
                    visible: _searchController.text.isEmpty,
                    replacement: IconButton(
                      iconSize: 16 + 8, // Ajusta esto al tamaño de fuente que necesites
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 22.0, height: 22.0,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    child: const Icon(Icons.search),
                  ),
                  contentPadding: const EdgeInsets.all(8.0),
                  border: const OutlineInputBorder(),
                  hintText: 'Búsqueda', // Ajusta esto al texto de sugerencia que necesites
                ),
              ),
            ),
          ),
          MaterialButton(height: 50,
            onPressed: (){
              if(_selectAll!= null){
                _selectAll = !_selectAll!;
                List<String> tempList = List<String>.from(selectedItems);
                if (_selectAll!) {
                  tempList.addAll(widget.items);
                } else {
                  tempList.clear();
                }
                selectedItems = tempList;
                setState(() {});
              }else{
                _selectAll = false;
                selectedItems.clear();
                setState(() {});
              }
            },child: Row(children: [
            Checkbox(
              tristate: true,
              value: _selectAll,
              activeColor: theme.colorScheme.secondary,
              onChanged: (bool? value) {
                if(value != null) {
                  setState(() {
                    _selectAll = value!;
                    List<String> tempList = List<String>.from(selectedItems);
                    if (_selectAll!= null) {
                      if (_selectAll!) {
                        tempList.addAll(widget.items);
                      } else {
                        tempList.clear();
                      }
                    } else {
                      tempList.clear();
                    }
                    selectedItems = tempList;
                  });
                }else{
                  setState(() {
                    _selectAll = false;
                    List<String> tempList = List<String>.from(selectedItems);
                    if (_selectAll!= null) {
                      if (_selectAll!) {
                        tempList.addAll(widget.items);
                      } else {
                        tempList.clear();
                      }
                    } else {
                      tempList.clear();
                    }
                    selectedItems = tempList;
                  });;
                }
              },
            ),
            const Text('Seleccionar todo', style: TextStyle(fontSize: 14),),
          ],),),
          SizedBox(
              height: 150,width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return MaterialButton(height: 45,
                      onPressed: () {
                        setState(() {
                          bool value = selectedItems.contains(items[index]);
                          if (!value) {
                            selectedItems.add(items[index]);
                          } else {
                            selectedItems.remove(items[index]);
                          }
                          if(selectedItems.length == items.length){
                            _selectAll = true;
                          }else if(selectedItems.isEmpty){
                            _selectAll = false;
                          }else{
                            _selectAll = null;
                          }
                        });
                      },
                      child: Row(children: [
                        Checkbox(
                          value: selectedItems.contains(items[index]), activeColor: theme.colorScheme.secondary,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                selectedItems.add(items[index]);
                              } else {
                                selectedItems.remove(items[index]);
                              }
                              if(selectedItems.length == items.length){
                                _selectAll = true;
                              }else if(selectedItems.isEmpty){
                                _selectAll = false;
                              }else{
                                _selectAll = null;
                              }
                            });
                          },
                        ),
                        SizedBox(width: 220,child: Text(items[index], style: const TextStyle(fontSize: 12),),)
                      ],),);
                  })
          ),
          const Divider(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
                  ),
                  onPressed: () {
                    String selectedItemString = "";
                    if(_searchController.text.isNotEmpty){
                      List<String> itemsString = selectedItems.where((element) => element.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                      selectedItemString = itemsString.join('%^');
                    }else{
                      selectedItemString = selectedItems.join('%^');
                    }
                    if(selectedItemString.isEmpty){
                      CustomSnackBar.showWarningSnackBar(context, 'No se ha seleccionado ningún filtro');
                    }else{
                      Navigator.of(context).pop(selectedItemString);
                    }
                  },
                  child: Text('Aplicar', style: TextStyle(color: theme.colorScheme.onPrimary),),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.inversePrimary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.onPrimary),),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}