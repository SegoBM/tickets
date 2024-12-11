import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ComprasController/KitController/KitController.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/listaPrecioController.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/listaPrecio.dart';
import 'package:tickets/shared/widgets/textfields/autocomplete_Materiales.dart';
import 'package:tickets/shared/widgets/textfields/autocomplete_Productos.dart';
import 'package:tickets/shared/widgets/textfields/autocomplete_Servicios.dart';
import 'package:tickets/shared/widgets/textfields/cantidad_ComponenteDouble.dart';
import '../../../../models/ComprasModels/KitModels/Kits.dart';
import '../../../../models/ComprasModels/KitModels/KitsComponentes.dart';
import '../../../../models/ComprasModels/MaterialesModels/materiales.dart';
import '../../../../models/ComprasModels/ServiciosProductosModels/serviciosProductos.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/appBar/my_appBar.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/textfields/buildExpansionTile.dart';
import '../../../../shared/widgets/textfields/dropdown_buttonform.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

class KitRegistrationScreen extends StatefulWidget {
  static String id = 'KitRegistrationScreen';
  const KitRegistrationScreen({super.key});

  @override
  _KitRegistrationScreenState createState() => _KitRegistrationScreenState();
}

class _KitRegistrationScreenState extends State<KitRegistrationScreen> with TickerProviderStateMixin {
  int _currentIndex = -1;
  late Size size; late ThemeData theme;
  final _formKey = GlobalKey<FormState>();
  late TabController tabController;
  final _scrollController = ScrollController(), scrollPriceController = ScrollController();
  // Datos generales
  final _codigoController = TextEditingController(), _nombreController = TextEditingController(),
      _descripcionController = TextEditingController(), _estatusController = TextEditingController();
  List<String> listEstatus = ["INACTIVO", "DISPONIBLE", "BLOQUEADO","DESCONTINUADO"];
  //Para servicios
  final _searchServiciosController = TextEditingController();
  List<ServiciosProductosModels> selectedServicios = [];
  //Productos
  final _searchProductosController = TextEditingController();
  List<ServiciosProductosModels> selectedProductos = [];
  //Materiales
  final _searchMaterialesController = TextEditingController();
  List<MaterialesModels> selectedMateriales = [];
  //precios
  Map<String,int> reverseEstatusTexto = {
    "INACTIVO":0, "DISPONIBLE":1, "BLOQUEADO":2, "DESCONTINUADO":3
  };


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose(); scrollPriceController.dispose(); _codigoController.dispose();
    _nombreController.dispose(); _descripcionController.dispose(); _estatusController.dispose();
    _searchServiciosController.dispose(); _searchProductosController.dispose();
    _searchMaterialesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    theme = Theme.of(context);
    return WillPopScope(child: Scaffold(backgroundColor: theme.backgroundColor,
      appBar: size.width > 600 ? MyCustomAppBarDesktop(
          title: "Creación de Kits",
          suffixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.backgroundColor, elevation: 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Guardar",
                    style: TextStyle(color: theme.colorScheme.onPrimary),),
                  Icon(
                    IconLibrary.iconSave, color: theme.colorScheme.onPrimary,)
                ],), onPressed: () {
                      save();
              if (_formKey.currentState!.validate()) {} else {
                CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
              }
            },
            ),),
          context: context,
          backButton: true,
          defaultButtons: false,
          borderRadius: const BorderRadius.all(Radius.circular(25))
      ) : null,
      body: size.width > 600 ? _landscapeBody() : _portraitBody(),
    ), onWillPop: () async {
      bool salir = false;
      CustomAwesomeDialog(title: Texts.alertExit,
        desc: Texts.lostData, btnOkOnPress: () {
          salir = true;
        },
        btnCancelOnPress: () {
          salir = false;
        },).showQuestion(context);
      return salir;
    }
    );
  }

  Future<void> save() async {
     try{
      // LoadingDialog.showLoadingDialog(context, Texts.savingData);
        KitController kitController = KitController();
        List<Map<String, dynamic>> serviciosListJson = serviciosList.map((p) => p.toJson()).toList();
        List<KitsComponentes> componentes=[];
        componentes.addAll(serviciosList);
        componentes.addAll(productosList);
        componentes.addAll(materialesList);
        KitsConComponentes kitsConComponentes = KitsConComponentes(
           kitModels : KitModels(
            codigo: _codigoController.text.trim(),
            nombre: _nombreController.text.trim(),
            estatus: reverseEstatusTexto[_estatusController.text.trim()] ?? 0,
            descripcion: _descripcionController.text.trim(),
            fecha: null,
          ),
              kitsComponentes: componentes,
        );
        print('Save: ${kitsConComponentes} + ${serviciosList} + ${productosList} + ${materialesList}');
     }catch (error){
        //LoadingDialog.hideLoadingDialog(context);
     }
  }

  Widget _landscapeBody() {
    return Form(key: _formKey,
      child: Scrollbar(controller: _scrollController,
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(controller: _scrollController,
            child: Container(margin: const EdgeInsets.all(19.0),
              width: size.width * .80,
              height: size.height * .75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Column(children: [
                      const SizedBox(height: 10),
                      Container(width: size.width * 0.52, height: size.height *
                          0.340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.primaryColor,
                        ),
                        child: Column(children: datosGenerales(),),
                      ),
                      const SizedBox(height: 10,),
                      Container(width: size.width * 0.52, height: size.height *
                          0.380,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.primaryColor,
                        ),
                        child: Column(children: precios(context)),
                      ),
                    ],
                    ),
                  ],),
                  Container(
                    width: size.width * 0.20, height: size.height * 0.71,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10.0)),
                      color: theme.colorScheme.secondary,
                    ), child: Column(children: componentes(),),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _portraitBody() {
    return Column(
      children: const [
        Text("Modo retrato no implementado"),
      ],
    );
  }

  List<Widget> datosGenerales() {
    return [
      _myContainer("Datos generales"),
      _rowDivided3(
        MyTextfieldIcon(
          formatting: false,
          backgroundColor: theme.colorScheme.background,
          labelText: "Código",
          textController: _codigoController,
          suffixIcon: const Icon(Icons.qr_code),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
        MyTextfieldIcon(
          formatting: false,
          backgroundColor: theme.colorScheme.background,
          labelText: "Nombre",
          textController: _nombreController,
          suffixIcon: Icon(Icons.abc_sharp),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
        CustomDropdown(
          labelText: 'Estatus',
          items: listEstatus,
          textController: _estatusController,
          onChanged: (newValue) {
            setState(() {
              _estatusController.text = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: 16,),
      _rowDivided(
        MyTextfieldIcon(
          formatting: false,
          backgroundColor: theme.colorScheme.background,
          labelText: "Descripción",
          textController: _descripcionController,
          suffixIcon: Icon(Icons.description),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
      ),
    ];
  }

  ListaPrecioController listaPrecioController = ListaPrecioController();

  List<Widget> precios(BuildContext context) {
    return [
      _myContainer("Lista de precios"),
      encabezados(),
      FutureBuilder<List<ListaPrecio>>(
        future: listaPrecioController.getListaPrecioActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los precios'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay precios disponibles'));
          } else {
            List<ListaPrecio> listPrices = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              height: size.height * .239,
              width: size.width * 0.500,
              //height: ,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  controller: scrollPriceController,
                  shrinkWrap: true,
                  itemCount: listPrices.length,
                  itemBuilder: (context, index) {
                    return cardPrice(listPrices[index]);
                  },
                ),
              ),
            );
          }
        },
      ),
    ];
  }

  Widget cardPrice(ListaPrecio listaPrecio){
    return Card(margin: const EdgeInsets.all(2), shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7)),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          SizedBox(width: 85, child: Row(children: [
            // const Text("Nombre: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            SizedBox(width: 25,),
            Flexible(
              child: Text(listaPrecio.precio.toString(), style: TextStyle(fontSize: 12,
                color: theme.colorScheme.onPrimary.withOpacity(0.7)),),)
          ],),),
          SizedBox(width: 85, child: Row(children: [
            //const Text("Precio sugerido: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            Transform.scale(scale: 0.8,child: SizedBox(width: 80, height: 40, child: TextField(
              controller: TextEditingController(text: listaPrecio.cantidad.toString()),
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) {
                print(value);
                if(value.isNotEmpty){
                  if(double.parse(value) > 0){
                    listaPrecio.cantidad = double.parse(value);
                  }
                }
              },
            ),),)
          ],),),
          SizedBox(width: 85, child: Row(children: [
            //const Text("Descuento: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            Transform.scale(scale: 0.8,child: SizedBox(width: 80, height: 40, child: TextField(
              controller: TextEditingController(text: listaPrecio.cantidad.toString()),
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) {
                print(value);
                if(value.isNotEmpty){
                  if(double.parse(value) > 0){
                    listaPrecio.cantidad = double.parse(value);
                  }
                }
              },
            ),),)
          ],),),
          SizedBox(width: 85, child: Row(children: [
            // const Text("Ganancia: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            Transform.scale(scale: 0.8,child: SizedBox(width: 80, height: 40, child: TextField(
              controller: TextEditingController(text: listaPrecio.cantidad.toString()),
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) {
                print(value);
                if(value.isNotEmpty){
                  if(double.parse(value) > 0){
                    listaPrecio.cantidad = double.parse(value);
                  }
                }
              },
            ),),)
          ],),),
          SizedBox(width: 85, child: Row(children: [
            //const Text("Total: ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
            Transform.scale(scale: 0.8,child: SizedBox(width: 80, height: 40, child: TextField(
              controller: TextEditingController(text: listaPrecio.cantidad.toString()),
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) {
                print(value);
                if(value.isNotEmpty){
                  if(double.parse(value) > 0){
                    listaPrecio.cantidad = double.parse(value);
                  }
                }
              },
            ),),)
          ],),),
        ],),
      ),);
  }

  Widget encabezados(){
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //const SizedBox(width: 15),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Nombre",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                ),
              ),
            ),
            const SizedBox(width:15),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Precio sugerido",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize:15),
                ),
              ),
            ),
            const SizedBox(width:15),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Descuento",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Ganancia",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 15,),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Total",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _myContainer(String title) {
    return Center(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8),
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Divider(color: theme.colorScheme.onPrimary, thickness: 1, endIndent: 100, indent: 100),
        ],
      ),
    );
  }

  Widget _rowDivided3(Widget widgetL, Widget widgetC, Widget widgetR) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.17, child: widgetL),
        SizedBox(width: size.width * 0.17, child: widgetC),
        SizedBox(width: size.width * 0.17, child: widgetR),
      ],
    );
  }

  Widget _rowDivided(Widget widgetC) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [SizedBox(width: size.width * 0.51,  child: widgetC),],
    );
  }

  void _showServiciosDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: AutocompleteServicios(textController: _searchServiciosController,
              onValueChanged: (List<ServiciosProductosModels> selectedServicios){
                setState(() {
                  this.selectedServicios = selectedServicios;
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleExpansion(int index){
    setState(() {
      if (_currentIndex == index){
        _currentIndex = -1;
      }else {
        _currentIndex = index;
      }
    });
  }

  List<Widget> componentes() {
    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.80, height: size.height * .71,
        decoration: BoxDecoration(color: theme.colorScheme.secondary,),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionSection(title: "Servicios", buttonText: "Agregar servicio +",
                isExpanded: _currentIndex == 0,
                onPressed: () async {_showServiciosDialog(context);},
                onExpansionChanged: (){_toggleExpansion(0);},
                selectedItems: _buildCardsSeleccionadosServicios(),
              ),
              ExpansionSection(title: "Productos", buttonText: "Agregar producto +",
                isExpanded: _currentIndex == 1,
                onPressed: () async {_showProductosDialog(context);},
                onExpansionChanged: (){_toggleExpansion(1);},
                selectedItems: _buildCardsSeleccionadosProductos(),
              ),
              ExpansionSection(title: "Materiales", buttonText: "Agregar material +",
                isExpanded: _currentIndex == 2,
                onPressed: () async {_showMaterialesDialog(context); },
                onExpansionChanged: (){_toggleExpansion(2);},
                selectedItems: _buildCardsSeleccionadosMaterial(),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showProductosDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: AutocompleteProductos(textController: _searchProductosController,
              onValueChanged: (List<ServiciosProductosModels> selectedProductos){
                setState(() {
                  this.selectedProductos = selectedProductos;
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _showMaterialesDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: AutocompleteMateriales(textController: _searchMaterialesController,
              onValueChanged: (List<MaterialesModels> selectedMateriales){
                setState(() {
                  this.selectedMateriales = selectedMateriales;
                });
              },
            ),
          ),
        );
      },
    );
  }

  List<KitsComponentes> serviciosList = [];

  Widget _buildCardsSeleccionadosServicios() {
    if (selectedServicios.isEmpty) {
      return Container();
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: selectedServicios.length,
              itemBuilder: (BuildContext context, int index) {
                final servicio = selectedServicios[index];
                if (serviciosList.length < selectedServicios.length) {
                  serviciosList.add(
                    KitsComponentes(
                      servicioID: servicio.idServiciosProductos,
                      cantidad: 0.0,
                    ),
                  );
                }
                KitsComponentes kitsComponentes = serviciosList[index];
                return Dismissible(
                  key: Key(servicio.idServiciosProductos!),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    setState(() {
                      selectedServicios.removeAt(index);
                      serviciosList.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Servicio eliminado',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(2),
                    //color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Text(
                                    servicio.concepto,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: 73,
                                    child: Transform.scale(
                                      scale: 0.8,
                                      child: TextField(
                                       controller: TextEditingController(text: kitsComponentes.cantidad.toString()),
                                       style: TextStyle(fontSize: 14, color: theme.colorScheme.secondary, fontWeight: FontWeight.normal),
                                       decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                       borderSide: BorderSide(color: theme.colorScheme.secondary)),
                                       focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                       borderSide: BorderSide(color: theme.colorScheme.secondary)),
                                       ),
                                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                       onChanged: (value){
                                       print(value);
                                        if(value.isNotEmpty){
                                          if(double.parse(value) > 0){
                                           serviciosList[index].cantidad = double.tryParse(value);
                                          }
                                       }
                                     },
                                    ),)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<KitsComponentes> productosList = [];

  Widget _buildCardsSeleccionadosProductos(){
    if(selectedProductos.isEmpty){
      return Container();
    }
    return Container(
     height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: selectedProductos.length,
              itemBuilder: (BuildContext context, int index){
                final producto = selectedProductos[index];
                if (productosList.length < selectedProductos.length){
                  productosList.add(
                    KitsComponentes(
                      productoID: producto.idServiciosProductos,
                      cantidad:0.0,
                    ),
                  );
                }
                KitsComponentes kitsComponentes = productosList[index];
                return Dismissible(
                  key: Key(producto.idServiciosProductos!),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    setState(() {
                      selectedProductos.removeAt(index);
                      productosList.removeAt(index);
                    });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text( 'Producto eliminado',
                      style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                 },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(2),
                    child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 7.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Expanded(
                          child: Column(
                                children:[
                                  SizedBox( width: MediaQuery.of(context).size.width /4,
                                   child: Text( producto.concepto,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 12,
                                    ),
                                   ),),
                                    SizedBox(
                                      width: 73,
                                      child: Transform.scale(
                                         scale: 0.8,
                                         child: TextField(
                                          controller: TextEditingController(text: kitsComponentes.cantidad.toString()),
                                          style: TextStyle(fontSize:14, color: theme.colorScheme.secondary,
                                            fontWeight: FontWeight.normal),
                                          decoration: InputDecoration( enabledBorder:
                                            UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(color: theme.colorScheme.secondary)),),
                                          inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                          onChanged: (value){
                                            print(value);
                                            if( value.isNotEmpty){
                                              if(double.parse(value) > 0){
                                                productosList[index].cantidad = double.tryParse(value);
                                                }
                                              }
                                            },
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<KitsComponentes> materialesList = [];

  Widget _buildCardsSeleccionadosMaterial(){
    if(selectedMateriales.isEmpty){
      return Container();
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: selectedMateriales.length,
              itemBuilder: (BuildContext context, int index){
                final material = selectedMateriales[index];
                if( materialesList.length < selectedMateriales.length) {
                  materialesList.add(
                    KitsComponentes(
                      materialID: material.idMaterial,
                      cantidad: 0.0,
                    ),
                  );
                }
                KitsComponentes kitsComponentes = materialesList[index];
                return Dismissible(
                  key: Key(material.idMaterial!),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    setState((){
                      selectedMateriales.removeAt(index);
                      materialesList.removeAt(index);
                    });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text( 'Material eliminado',
                          style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                 },
                  background: Container(
                   color: Colors.red,
                   alignment: Alignment.centerRight,
                   padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(
                            child: Column(
                              children:[
                                SizedBox( width: MediaQuery.of(context).size.width /4,
                                  child: Text(
                                  '${material.familiaNombre} ${material.subFamiliaNombre} ${material.categoria}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 12),
                                ),),
                                SizedBox(
                                  width: 73,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: TextField(
                                      controller: TextEditingController(text: kitsComponentes.cantidad.toString()),
                                      style: TextStyle(fontSize: 14, color: theme.colorScheme.secondary,
                                         fontWeight: FontWeight.normal),
                                      decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(color: theme.colorScheme.secondary)),
                                      focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                         borderSide: BorderSide(color: theme.colorScheme.secondary)),),
                                      inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                      onChanged: (value){
                                        print(value);
                                        if(value.isNotEmpty){
                                          if(double.parse(value) > 0){
                                            materialesList[index].cantidad = double.tryParse(value);
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ),
                              ]
                            )
                          )
                        ]
                      )
                    )
                  )
                );
              }
            )
          )
        ]
      )
    );
  }

}
