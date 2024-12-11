import 'dart:convert';
import 'package:tickets/controllers/ComprasController/ServiciosProductosController/serviciosProductosController.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/servicioProductosConProveedores.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/serviciosProductos.dart';
import 'package:image/image.dart' as img;
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ComprasModels/ProveedorModels/proveedor.dart';
import 'package:tickets/shared/widgets/textfields/dropdown_buttonform.dart';
import '../../../../controllers/ComprasController/ListaPrecioPSMK/listaPrecioPSMK.dart';
import '../../../../controllers/ComprasController/ServiciosProductosController/ClaveSAT/claveSAT.dart';
import '../../../../controllers/ConfigControllers/GeneralSettingsController/listaPrecioController.dart';
import '../../../../models/ComprasModels/ServiciosProductosModels/ClaveSAT/claveSAT.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/listaPrecio.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/monedas.dart';
import '../../../../shared/actions/key_raw_listener.dart';
import '../../../../shared/utils/color_palette.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/appBar/my_appBar.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/textfields/autocomplete_PROVEEDOR.dart';
import '../../../../shared/widgets/textfields/autocomplete_decoration.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';
import 'dart:io';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';

class ServiciosProductosRegistrationScreen extends StatefulWidget {
  static String id = 'serviciosProductosRegistration';
  List<MonedaModels> monedas;
  ServiciosProductosRegistrationScreen({super.key, required this.monedas});

  @override
  _ServiciosProductosRegistrationScreenState createState() =>
      _ServiciosProductosRegistrationScreenState();
}

class _ServiciosProductosRegistrationScreenState extends State<ServiciosProductosRegistrationScreen> with TickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>(); final GlobalKey _key = GlobalKey();
  //generales
  final _codigoController = TextEditingController(); final _descripcionController = TextEditingController();
  final _clasificacionController = TextEditingController(); final _categoriaController = TextEditingController();
  final _estatusController = TextEditingController(); final _fotoController = TextEditingController();
  //si es servicio/producto
  final _conceptoController = TextEditingController();
  // servicios
  final TextEditingController _duracionAproximada = TextEditingController();
  //productos
  final _unidadController = TextEditingController();
  //precios y controller
  final _monedaController = TextEditingController(); final _costeoController = TextEditingController();
  //SAT
  final TextEditingController ClaveSController = TextEditingController();
  List<ClaveSATModels> listClaveS = []; final claveSATController= ClaveSATController(); String? idClaveS;
  String? selectedValueClaveS; String? claveUnidadMedida; List<String> dropdownItemsClaveS =[]; String? place;
  //Moneda
  List<MonedaModels> listMonedas = []; List<String> listMonedasString = []; String selectedMoneda = "";
  Image? image; Uint8List? imageBytes; String base64String = "";
  //Scroller
  final _scrollController = ScrollController(), scrollPriceController = ScrollController();
  late Size size; late ThemeData theme;
  List<String> listCategoria = ['SERVICIOS', 'PRODUCTOS'];
  List<String> listUnidad = ['LITROS', 'PIEZAS', 'METROS', 'KILOGRAMOS', 'OTRO'];
  List<String> listClasificacion = ['COMPRA', 'COMPRA/VENTA'];
  List<String> listCosteo = ['UEPS', 'PEPS', 'PROMEDIO', 'ESTÁNDAR', 'IDENTIFICADO'];
  List<String> listEstatus = ['INACTIVO', 'ACTIVO', 'BLOQUEADO', 'FUERA DE LÍNEA'];
  List<String> listDuracion =['DE 30 MIN - 1 HORA', 'DE 2 - 3 HORAS', 'MÁS DE 3 HORAS'];
  final _searchProviderController = TextEditingController();
  List<ProveedorModels> selectedProveedores = [];
  late TabController tabController;
  String? selectedCategoriaProducto;
  List<ListaPrecio> listPrices = [];
  Map<String, int> reverseEstatusTextos = {
    "INACTIVO": 0, "ACTIVO": 1, "BLOQUEADO": 2, "FUERA DE LÍNEA": 3
  };
  bool isSavePrecios = false;
  bool? isChecked = false;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    getDatos();
    getMoneda();
    print(listPrices);
    super.initState();
  }

  @override
  void dispose() {
    _codigoController.dispose(); _descripcionController.dispose(); _clasificacionController.dispose();
    _categoriaController.dispose(); _estatusController.dispose(); _fotoController.dispose();
    _conceptoController.dispose(); _duracionAproximada.dispose(); _unidadController.dispose();
    _monedaController.dispose(); _costeoController.dispose(); _scrollController.dispose();
    _searchProviderController.dispose(); ClaveSController.dispose(); claveSATController.dispose();
    proveedoresList =[];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return bodyReload();
  }

  PreferredSizeWidget? appBarWidget(){
    return size.width > 600? MyCustomAppBarDesktop(title:"Alta de Servicios y Productos",
        backButtonWidget: TextButton.icon(
          icon: const Icon(IconLibrary.iconX),
          label: Text("Cerrar", style: TextStyle(color: theme.colorScheme.onPrimary),),
          style: TextButton.styleFrom(
            iconColor: ColorPalette.accentColor, primary: theme.colorScheme.onPrimary,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {
            if (moverTab(0) == false) {
              moverTab(0);
              Future.delayed(const Duration(milliseconds: 400), () {
                CustomAwesomeDialog(title: Texts.alertExit,
                    desc: Texts.lostData, btnOkOnPress: () {
                      Navigator.of(context).pop();
                    },
                    btnCancelOnPress: () {}).showQuestion(context);
              });
            }else{
              CustomAwesomeDialog(title: Texts.alertExit,
                  desc: Texts.lostData, btnOkOnPress: () {
                    Navigator.of(context).pop();
                  },
                  btnCancelOnPress: () {}).showQuestion(context);
            }
          },
        ),
        suffixWidget: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Guardar  ', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),),
              Container(padding: const EdgeInsets.all(.5),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.colorScheme.onSecondary, width: .5,),)),
                  child: Text(' f4 ', style: TextStyle( color: theme.colorScheme.onPrimary ),)),
              const SizedBox(width: 3,),
              Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary, size: size.width *.012, ),
            ],),
          onPressed: () async {
            if(tabController.index == 0){
               comprobarSave();
             } else{
                await moverTab(0);
                Future.delayed(const Duration(milliseconds: 400), () {
                   comprobarSave();
              });
            }
          },
        ),
        context: context,backButton: true, defaultButtons: false,
        borderRadius: const BorderRadius.all(Radius.circular(25))
    ) : null;
  }

  Future<void> comprobarSave() async {
    if (_formKey.currentState!.validate()) {
      bool allFieldsValid = true;
      if (selectedCategoriaProducto == 'SERVICIOS') {
        for (var field in servicios()) {
          if (field is MyTextfieldIcon) {
            if (field.validator != null && field.validator!(field.textController.text) != null) {
              allFieldsValid = false;
              break;
            }
          } else if (field is CustomDropdown) {
            if (field.validator != null &&
                field.validator!(field.textController.text) != null) {
              allFieldsValid = false;
              break;
            }
          }
        }
      } else if (selectedCategoriaProducto == 'PRODUCTOS'){
        for (var field in productos()){
          if (field is MyTextfieldIcon) {
            if (field.validator != null &&
                field.validator!(field.textController.text) != null) {
              allFieldsValid = false;
              break;
            }
          } else if(field is CustomDropdown  ){
            if(field.validator != null &&
                field.validator!(field.textController.text) != null){
              allFieldsValid = false;
              break;
            }
          }
        }
      }
      //////////LISTA PRECIO////////////
      bool allPricesAreZero = preciosPSMKList.every((element){
       return element.precio !> 0.0;
      });
      bool botonP = isSavePrecios;
      print(botonP);
      print(allPricesAreZero);
      if (isSavePrecios == false) {
        allFieldsValid = false;
        CustomAwesomeDialog(
          title: Texts.errorSavingData,
          desc: 'No ha ingresado ningún precio. \n ¡Es necesario ingresar como mínimo el precio base!',
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        ).showError(context);
      }
      /////////////PROVEEDORES///////////
      bool allProveedoresValid = proveedoresList.every((proveedor) {
        return proveedor.costo !> 0.0 && proveedor.total !> 0.0;
      });
      if(!allProveedoresValid){
        allFieldsValid = false;
        CustomAwesomeDialog(title: Texts.errorSavingData,
         desc: 'Todos los costos por unidad y los totales de los proveedores deben ser mayores de 0.0' ,
          btnCancelOnPress: (){},
          btnOkOnPress: (){},
        ).showError(context);
      }
      if (allFieldsValid) {
        if (selectedProveedores.isEmpty) {
          CustomAwesomeDialog(
            title: Texts.askSaveConfirm,
            desc: 'No tiene proveedores. ¿Desea guardar de todos modos?',
            btnOkOnPress: () async {
              await _save();
            },
            btnCancelOnPress: () {},
          ).showQuestion(context);
        } else {
          CustomAwesomeDialog(
            title: Texts.askSaveConfirm,
            desc: '¿Desea guardar el registro?',
            btnOkOnPress: () async {
              await _save();
            },
            btnCancelOnPress: () {
            },
          ).showQuestion(context);
        }
      } else {
        CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
      }
    } else {
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }

  Future<void> _save() async {
    try {
      LoadingDialog.showLoadingDialog(context, Texts.savingData);
      ServiciosProductosController serviciosProductosController = ServiciosProductosController();
      List<Map<String, dynamic>> proveedoresListJson = proveedoresList.map((p) => p.toJson()).toList();
      ServiciosProductos servicioProducto = ServiciosProductos(
        serviciosProductos: ServiciosProductosModels(
          codigo: _codigoController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          clasificacion: _clasificacionController.text.trim(),
          categoria: _categoriaController.text.trim(),
          estatus: reverseEstatusTextos[_estatusController.text.trim()] ?? 0,
          foto: base64String,
          concepto: _conceptoController.text.trim(),
          duracionAproximada: _duracionAproximada.text.trim().isEmpty ? "N/A" : _duracionAproximada.text,
          unidad: _unidadController.text.trim().isEmpty ? "N/A" : _unidadController.text,
          moneda: selectedMoneda,
          costeo: _costeoController.text.trim(),
          claveSATID: idClaveS?.toUpperCase(),
        ),
           listaPrecioPSMK: preciosPSMKList,
           proveedoresList: proveedoresList,
      );
      print('JSON generado: ${servicioProducto.toJson3()} + ${proveedoresListJson} ');
      bool result = await serviciosProductosController.saveServicioProductoConProveedores(servicioProducto);
      if (result) {
        LoadingDialog.hideLoadingDialog(context);
        CustomAwesomeDialog(
          title: Texts.addSuccess,
          desc: '',
          btnOkOnPress: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          btnCancelOnPress: () {},
        ).showSuccess(context);
        Future.delayed(const Duration(milliseconds: 2500), () {
          Navigator.of(context).pop();
        });
      } else {
        LoadingDialog.hideLoadingDialog(context);
        throw Exception('Error inesperado al guardar');
      }
    } catch (error) {
      LoadingDialog.hideLoadingDialog(context);
      CustomAwesomeDialog(
        title: Texts.errorSavingData,
        desc: 'Error inesperado. Contacte soporte. Detalles: $error',
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
      ).showError(context);
    }
  }

  Future<void> moverTab(int index) async {
    tabController.index = index;
  }

  Widget bodyReload() {
    return WillPopScope(
      child: PressedKeyListener(
        keyActions: <LogicalKeyboardKey, Function()>{
          LogicalKeyboardKey.escape: () {
            moverTab(0);
            CustomAwesomeDialog(
              title: Texts.alertExit,
              desc: Texts.lostData,
              btnOkOnPress: () {
                Navigator.of(context).pop();
              },
              btnCancelOnPress: () {},
            ).showQuestion(context);
          },
          LogicalKeyboardKey.f1: () async {
            moverTab(0);
          },
          LogicalKeyboardKey.f2: () async {
            moverTab(1);
          },
          LogicalKeyboardKey.f4: () async {
            if (tabController.index != 0) {
              await moverTab(0);
              Future.delayed(const Duration(milliseconds: 400), () {
                 comprobarSave();
              });
            }
          },
        },
        Gkey: _key,
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: appBarWidget(),
          body: size.width > 600 ? _landscapeBody2() : _portraitBody(),
        ),
      ),
      onWillPop: () async {
        bool salir = false;
        CustomAwesomeDialog(
          title: Texts.alertExit,
          desc: Texts.lostData,
          btnOkOnPress: () {
            setState(() {
              salir = true;
              selectedProveedores.clear();
              moverTab(0);
            });
            Navigator.of(context).pop();
          },
          btnCancelOnPress: () {
            setState(() {
              salir = false;
            });
          },
        ).showQuestion(context);
        return salir;
      },
    );
  }

  List<Widget> datosGenerales(){
    return[
      const SizedBox(height: 5,),
      _myContainer("DATOS GENERALES"),
       Container(child:
        Row(
          children: [
            _rowDividedP2(
              Column(
                children: [
                  Container(
                    child:
                    _rowDivided2(
                      MyTextfieldIcon(
                        formatting: false, backgroundColor: theme.colorScheme.background,
                        labelText: "Código", textController: _codigoController,
                        toUpperCase: true, suffixIcon: const Icon(Icons.qr_code),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor completa este campo';
                          } else if (value.length > 10){
                            return 'No puedes tener más de 10 caracteres.Actual ${value.length}';
                          }
                          return null;
                        },
                      ),
                      CustomDropdown(labelText:'Clasificación', items: listClasificacion,
                        textController: _clasificacionController,
                        onChanged: (newValue) {
                          setState(() {_clasificacionController.text = newValue!;});
                          },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor completa este campo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    child:
                    _rowDivided2(
                      CustomDropdown(
                        labelText:'Categoría',
                        items: listCategoria,
                        textController: _categoriaController,
                        onChanged: (newValue) {
                          setState(() {
                            _categoriaController.text = newValue!;
                            selectedCategoriaProducto = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor completa este campo';
                          }
                          return null;
                        },
                      ),
                      CustomDropdown(
                        labelText:'Estatus',
                        items: listEstatus,
                        textController: _estatusController,
                        onChanged: (newValue) {
                          _estatusController.text = newValue!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor completa este campo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    child:
                    _rowDivided(
                      MyTextfieldIcon(
                        backgroundColor: theme.colorScheme.background,
                        labelText: "Descripción",
                        toUpperCase: true,
                        textController: _descripcionController,
                        suffixIcon: const Icon(Icons.description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor completa este campo';
                          } else if (value.length > 350){
                            return 'No puede tener más de 350 caracteres.Actual ${value.length}';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
                Column( mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _imageField(_fotoController),
                  ],)
            ),
          ],
        ),
      ),
    ];
  }

  Widget _imageField(TextEditingController textController) {
    return Column(
      children: [
        imageBytes != null ? Image.memory( imageBytes!,
          height: size.height * 0.18, width: size.width * 0.20, fit: BoxFit.cover,
        ): Container(
            decoration: BoxDecoration(
            color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ), child: Icon(Icons.image, size: size.width *0.1,),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () => _pickImage(),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickImage(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
    allowedExtensions: ['jpg', 'png', 'jpeg'],);
    if(result != null) {
      PlatformFile file = result.files.single;
      final File imageFile = File(file.path.toString());
      int fileSize = await imageFile.length();
      int maxSize = 1024 * 1024;
      if (fileSize <= maxSize) {
        imageBytes = await imageFile.readAsBytes();
        image = Image.memory(imageBytes!);
        base64String = await reducirCalidadImagenBase64(base64.encode(imageBytes!));
        setState(() {});
      } else {
        CustomAwesomeDialog(title: Texts.errorSavingData,
            desc: 'La imagen debe tener un tamaño menor a 1MB',
            btnOkOnPress: () {},
            btnCancelOnPress: () {}).showError(context);
      }
    } else {
    }
  }

  Future<String> reducirCalidadImagenBase64(String base64Str, {int calidad=50}) async{
    Uint8List bytes = base64.decode(base64Str);
    img.Image? image = img.decodeImage(bytes);
    Uint8List jpeg = img.encodeJpg(image!, quality: calidad);
    return base64.encode(jpeg);
  }

  List<Widget> servicios(){
    return[
      _myContainer("INFORMACIÓN DEL SERVICIO"),
      _rowDivided2(
        MyTextfieldIcon(
          backgroundColor: theme.colorScheme.background,
          labelText: "Concepto",
          textController: _conceptoController,
          toUpperCase: true,
          suffixIcon: const Icon(Icons.abc_sharp),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }  else if (value.length > 100) {
              return 'No puede tener más de 100 caracteres. Actual: ${value.length}';
            }
            return null;
          },
        ),
        CustomDropdown(
          labelText:'Duración Apróximada',
          items: listDuracion,
          textController: _duracionAproximada,
          onChanged: (newValue) {
            setState(() {
              _duracionAproximada.text = newValue!;
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
    ];
  }

  List<Widget> productos(){
    return[
      _myContainer("INFORMACIÓN DEL PRODUCTO"),
      _rowDivided2(
        MyTextfieldIcon(
          backgroundColor: theme.colorScheme.background,
          labelText: "Concepto",
          toUpperCase: true,
          textController: _conceptoController,
          suffixIcon: const Icon(Icons.abc_sharp),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            } else if (value.length > 100) {
              return 'No puede tener más de 100 caracteres. Actual: ${value.length}';
            }
            return null;
          },
        ),
        CustomDropdown(
          labelText:'Unidad',
          items: listUnidad,
          textController: _unidadController,
          onChanged: (newValue) {
            setState(() {
              _unidadController.text = newValue!;
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
    ];
  }

  List<Widget> preciosControl(StateSetter setState1) {
    return [
      const SizedBox(height: 5,),
      _myContainer("PRECIOS Y COSTEO"),
      _rowDivided3(
        CustomDropdown(
          labelText: 'Moneda',
          items: listMonedasString,
          textController: _monedaController,
          onChanged: (newValue) {
            setState(() {
              selectedMoneda = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
        CustomDropdown(
          labelText: 'Costeo',
          items: listCosteo,
          textController: _costeoController,
          onChanged: (newValue) {
            setState(() {
              _costeoController.text = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor completa este campo';
            }
            return null;
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary, elevation: 0),
          onPressed: isSavePrecios ? null : () async {
            ListaPrecioController listaPrecioController = ListaPrecioController();
            if(listPrices.isEmpty){
              listPrices = await listaPrecioController.getListaPrecioActivos();
            }
            /////////////////Para buscar el registro con lista base /////////
            var precioBase =  listPrices.firstWhere((p) => p.listaBase == true,
               orElse: () => ListaPrecio(idListaPrecio: ''));
            if (precioBase != null) {
              listPrices.remove(precioBase);
              listPrices.insert(0, precioBase);
              print("Registro con listaBase movido al inicio");
            } else {
              print("No se encontró un registro con listaBase en true");
            }
            await _showPreciosDialog(context);
          },
          child: Row(
            children: [
              Text("Lista de precios para venta", style: TextStyle(color: theme.colorScheme.onPrimary,
                  fontSize: 14, fontWeight: FontWeight.bold),),
              Icon(IconLibrary.iconMoney, color: theme.colorScheme.onPrimary,)
            ],),
        ),
      ),
    ];
  }

  Future<void> _showPreciosDialog(BuildContext context) async {
    await showDialog(context: context, barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context1, StateSetter setState1) {
          return Dialog(
            child: Container(width: 650, height: 450, padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15),),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _myContainer("Lista de precios"),
                      const SizedBox(height: 5),
                      Container(decoration: BoxDecoration(color: theme.colorScheme.background, borderRadius: BorderRadius.circular(10)),
                        height: 330,width: 620, child: FadingEdgeScrollView.fromScrollView(
                            child: ListView.builder(controller: scrollPriceController,
                                shrinkWrap: true, itemCount: listPrices.length,
                                itemBuilder: (context, index){
                                  return cardPrice(listPrices[index], index, setState1);
                                })),),
                    ],
                  ),
                  _rowDividedPL2(
                      ElevatedButton(style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.inversePrimary, elevation: 0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                            Text("Cerrar\t", style: TextStyle(color: theme.colorScheme.onPrimary),),
                            Icon(IconLibrary.iconX, color: theme.colorScheme.onPrimary,)
                          ],), onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                isSavePrecios = false;
                              });
                        }
                      ),
                      ElevatedButton(style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.background, elevation: 0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Guardar\t", style: TextStyle(color: theme.colorScheme.onPrimary),),
                            Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary,)
                          ],), onPressed: () {
                                  _savePrecios();
                          setState(() {
                            isSavePrecios = true;
                          });
                        },
                      ), width: 0.18
                  ),
                ],)
            ),
          );
        }
        );
      },
    );
  }

  List<ListaPrecioPSMK> preciosPSMKList=[];

  Widget cardPrice(ListaPrecio listaPrecio, int index, StateSetter setState1){
    bool showCheckbox = index != 0;
    isChecked = showCheckbox ? true : true;
    double base = 0.0;
   double? precioFinal;

    if(preciosPSMKList.length <= index){
          preciosPSMKList.add(ListaPrecioPSMK(
            listaPrecioId: listaPrecio.idListaPrecio,
            precio: 0,
          ));
    }
    //////////Determinar el tipo seleccionado y el valor de ese tipo//////////
    String tipo =""; String? valor="";

    if(listaPrecio.porcentaje == true){
      tipo = "Porcentaje:";
      valor = listaPrecio.porcentajeValue.toString() +"%";
    } else if (listaPrecio.monto == true){
      tipo = "Monto:";
      valor = "\$" +listaPrecio.montoValue.toString();
    } else if (listaPrecio.capturaManual == true){
      tipo = "Captura manual";
    } else if (listaPrecio.listaBase == true){
      tipo = "Precio base a ingresar";
    }

    //precioFinal = calcularPrecioFinal(listaPrecio, index);
    Color opacoPrimaryColor = theme.primaryColor.withOpacity(0.2);

    return Card(
      margin: EdgeInsets.all(2), shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7)),
     color: listaPrecio.isChecked! ? theme.primaryColor : opacoPrimaryColor,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(showCheckbox)
             SizedBox(width: size.width *.050,
                child:
                Checkbox(
                  checkColor: theme.colorScheme.onPrimary,
                  value: listaPrecio.isChecked,
                  onChanged: (bool? value){
                    setState1(() {
                      listPrices[index].isChecked = value ?? false;
                      //////////Actualiza el precio final////////
                      preciosPSMKList[index].precio = calcularPrecioFinal(listaPrecio, index);
                    });
                  },
                ),
             ),
          SizedBox(width: size.width * 0.10, child: Row(children: [
            const Text("Nombre: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
            Flexible(child: Text(listaPrecio.precio.toString(), style: TextStyle(fontSize: 11,
                color: theme.colorScheme.onPrimary.withOpacity(0.7)),),)
          ],),),
          SizedBox( width: size.width * 0.10, child: Row(children:[
            Text("$tipo ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
            Flexible( child: Text( "$valor",
              style: TextStyle( fontSize: 11, color: theme.colorScheme.onPrimary.withOpacity(0.7)),),)
          ])),
          SizedBox(width: size.width * 0.10, child: Row(children: [
            const Text("Precio: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
            Transform.scale(scale: 0.8,child: SizedBox(width: 80, height: 40, child: TextField(
              //controller: TextEditingController(text: listaPrecio.cantidad.toString()),
              controller: TextEditingController(text: preciosPSMKList[index].precio.toStringAsFixed(2)),
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              enabled:  index == 0 || listPrices[index].isChecked! && listaPrecio.capturaManual,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) {
                double? newValue = value.isNotEmpty ? double.tryParse(value) : null;
                if (newValue != null && newValue > 0) {
                  preciosPSMKList[index].precio = newValue;
                } else if (value.isEmpty) {
                  preciosPSMKList[index].precio = 0.0;
                  precioFinal=0.0;
                }
                if(index== 0){
                   base = newValue ?? 0.0;
                }
              },
          ),),)
          ],),),
        ],),
      ),);
  }

  double calcularPrecioFinal (ListaPrecio listaPrecio, int index){
    double base = preciosPSMKList[0].precio;
    if(listaPrecio.capturaManual == true){
      return preciosPSMKList[index].precio;
    } else if (listaPrecio.porcentaje == true){
      return double.parse((base + (base * (listaPrecio.porcentajeValue /
          100))).toStringAsFixed(2));
    } else if (listaPrecio.monto == true){
      return base + listaPrecio.montoValue;
    } else {
      return base;
    }
  }

  Future<void> _savePrecios() async{
    try{
      bool allPricesAreZero = preciosPSMKList.every((element) => element.precio == 0.0);
      if(allPricesAreZero){
        LoadingDialog.hideLoadingDialog(context);
        throw Exception('Todos los precios están en \$0.0 pesos.¡No se puede guardar!');
      }
      if(preciosPSMKList.isNotEmpty){
        preciosPSMKList.removeWhere((precioss) => precioss.precio == 0.0);
        LoadingDialog.hideLoadingDialog(context);
        CustomAwesomeDialog(title: Texts.addSuccess, desc:'', btnOkOnPress: (){
          Navigator.of(context).pop();
        }, btnCancelOnPress: (){},
        ).showSuccess(context);
        Future.delayed(const Duration(milliseconds: 2500), ()
        {
          Navigator.of(context).pop();
        });
      } else {
        LoadingDialog.hideLoadingDialog(context);
        throw Exception('Error inesperado al guardar');
      }
    } catch (error){
      LoadingDialog.hideLoadingDialog(context);
      CustomAwesomeDialog(
        title: Texts.errorSavingData,
        desc: 'Error inesperado. Contacte a soporte. Detalles: $error',
        btnOkOnPress: (){},
        btnCancelOnPress: (){},
      ).showError(context);
    }
  }

  Widget _rowDividedPL2(Widget widgetL, Widget widgetR, {double width = 0.15}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * width, child: widgetL),
        SizedBox(width: size.width * width, child: widgetR),
      ],
    );
  }

  List<Widget> proveedores(){
    return[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            _myContainer("PROVEEDORES"),
            encabezados(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              height: MediaQuery.of(context).size.height * 0.4 - 20,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTablaSeleccionados(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    ];
  }

  List<Widget>sat(){
    return [
      _myContainer("CLAVES CATÁLOGOS CFDI"),
      _rowDivided2(
        MyAutocomplete(
          onValueChange: handleAutocompleteValueChangedClaveS,
          labelText: 'Clave SAT',
          placeholderText: place,
          labelStyle: TextStyle(
              fontSize: 14, color: theme.colorScheme.onPrimary),
          dropdownItems: dropdownItemsClaveS,
          textController: ClaveSController,
          colorLine: theme.colorScheme.background,
          suffixIcon: Icon(Icons.numbers_rounded, color: theme.colorScheme.onPrimary),
          textStyle: TextStyle(color: theme.colorScheme.onPrimary),
          onValueChanged: handleAutocompleteValueChangedClaveS,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter> [FilteringTextInputFormatter.digitsOnly],
        ),
         Container(
              width: size.width * 0.40,
              height: size.width * 0.039,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.onPrimary),
                borderRadius: BorderRadius.circular(5),

              ),
              child: Text(
                claveUnidadMedida ?? 'Clave unidad',
                style: TextStyle( fontSize: 14, color: theme.colorScheme.onPrimary)),
              ),
            ),
    ];
  }

  Future<void> getDatos() async{
    try{
      List<ClaveSATModels> claveSAT = await claveSATController.GetClavesSat();
      setState(() {
        dropdownItemsClaveS = claveSAT.map((e) =>
            e.clavePs.toString()).toList();
         Future.delayed(const Duration(seconds: 1));
      });
    } catch (e){
      print(e);
    }
  }

  void handleAutocompleteValueChangedClaveS(String? value){
    setState((){
      selectedValueClaveS = value;
      print(selectedValueClaveS);
      place = selectedValueClaveS;
    });
    obtenerValores();
  }

  void handleValueChangedClaveS(String? value){
    setState(() {
      selectedValueClaveS = value;
      print(selectedValueClaveS);
    });
  }

  Future<void> obtenerValores() async {
    List<ClaveSATModels> claveSAT2 = await claveSATController.GetClavesSat();

    if (selectedValueClaveS == null || selectedValueClaveS!.isEmpty) {
      idClaveS = null;
      claveUnidadMedida = null;
      print("No se seleccionó ninguna clave, se establece claveSATID en null.");
      return;
    }
    int? selectedValueClavePS = int.tryParse(selectedValueClaveS!);
    if (selectedValueClavePS == null) {
      print("Error: selectedValueClaveS no es un número válido.");
      return;
    }
    ClaveSATModels? registroSeleccionado = claveSAT2.firstWhere(
          (modelo) => modelo.clavePs == selectedValueClavePS,
      orElse: () => ClaveSATModels(idClaveSat: "", descripcion: "", clavePs: 0, claveUnidadMedida: ""),
    );
    if (registroSeleccionado.idClaveSat!.isNotEmpty) {
      idClaveS = registroSeleccionado.idClaveSat;
      print(idClaveS);
      setState(() {
        claveUnidadMedida = registroSeleccionado.claveUnidadMedida;
        print("$claveUnidadMedida");
      });
    } else {
      print("Registro no encontrado");
    }
  }

  List<Widget> serviciosProductosForm(){
    return [
      Form(key: _formKey,
          child: Scrollbar(controller: _scrollController,thumbVisibility: true,
            child: FadingEdgeScrollView.fromSingleChildScrollView(child:
              SingleChildScrollView(controller: _scrollController,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child: Column(
                  children: <Widget>[
                    ...datosGenerales(),
                    if(selectedCategoriaProducto == 'SERVICIOS')
                      ...servicios(),
                    if(selectedCategoriaProducto == 'PRODUCTOS')
                      ...productos(),
                      ...preciosControl(setState),

                  ],
              ),),)),)
      ),
      Form(
          child: Scrollbar(controller: scrollPriceController,thumbVisibility: true,
            child: FadingEdgeScrollView.fromSingleChildScrollView(child:
              SingleChildScrollView(controller: scrollPriceController,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child: Column(
                  children: <Widget>[
                    ...sat(),
                    ...proveedores(),
                  ],
                ),),)),)
      ),
    ];
  }

  Widget _landscapeBody2(){
    return Column(children: [
      TabBar(
        controller: tabController,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        indicatorWeight: 5,
        padding: EdgeInsets.symmetric(horizontal: size.width*.15),
        tabs: const [
          Tab(
            text: "DATOS GENERALES Y PRECIOS",
          ),
          Tab(
            text: "CATÁLOGOS CFDI Y PROVEEDORES",
          ),
        ],
      ),
      Expanded(
        child: SizedBox(height: size.height * 180, width: size.width * 100 ,child:
           TabBarView(controller: tabController,
            children: serviciosProductosForm(),),
      ),),
    ],);
  }

  Widget encabezados() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 15),
            Flexible(
              flex: 1,
              child:
              SizedBox(
                width: size.width / 5,
                child: const Text(
                  "Proveedor",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 29),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: size.width /5,
                child: const Text(
                  "Costo por unidad",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                )
              )
            ),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width/5,
                child: const Text(
                  "Descuento",
                  textAlign: TextAlign.center,
                  overflow:TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                )
              )
            ),
            Flexible(
                flex: 1,
                child: SizedBox(
                  width: size.width /5,
                  child: const Text(
                    "Total",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                  )
                )
            ),
            //const SizedBox(width: 10),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width/5,
                child: const Text(
                  "Calificación",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                )
              )
            ),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width/5,
                child: const Text(
                  "Compra minima",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                )
              )
            ),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width/5,
                child: const Text(
                  "Mejor conocido",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                )
              )
            ),
            Flexible(
              flex:1,
              child: SizedBox(
                width: size.width/5,
                child: const Text(
                  "LM",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize:15),
                )
              )
            ),
            IconButton(
              onPressed: () async {
                _showProveedorDialog(context);
              },
              icon: const Icon(Icons.add),
              hoverColor: theme.colorScheme.background,
              splashRadius: 24,
              color: theme.colorScheme.secondary,
              splashColor: theme.colorScheme.secondary.withOpacity(0.2),
              padding: const EdgeInsets.all(5),
              tooltip: 'Agregar',
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  void _showProveedorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: CustomAutocomplete(
              textController: _searchProviderController,
              onValueChanged: (List<ProveedorModels> selectedProveedores){
                setState(() {
                  this.selectedProveedores = selectedProveedores;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _myContainer(String title){
    return Container(width: size.width/3,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
    padding: const EdgeInsets.only(top: 5),
      child: Center(
        child: Column ( children: [
          Text( title,
            style: const TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold
            ),
          ),
          Divider(thickness: 2, color: theme.colorScheme.secondary,)
        ],)
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

  Widget _rowDivided3(Widget widgetL, Widget widgetC, Widget widgetR) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.23, child: widgetL),
        SizedBox(width: size.width * 0.24, child: widgetC),
        SizedBox(width: size.width * 0.23, child: widgetR),
      ],
    );
  }

  Widget _rowDivided2(Widget widgetL, Widget widgetR) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.25,  child: widgetL),
        SizedBox(width: size.width * 0.25,  child: widgetR),
      ],
    );
  }

  Widget _rowDividedP2(Widget widgetL, Widget widgetR) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.55, child: widgetL),
        SizedBox(width: size.width * 0.15, child: widgetR),
      ],
    );
  }

  Widget _rowDivided(Widget widgetC) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.52, child: widgetC),
      ],
    );
  }

  void getMoneda() {
    listMonedas = widget.monedas;
    listMonedasString = listMonedas.map((e) => e.nombre).toList();
    selectedMoneda = listMonedasString.first;
    setState(() {});
  }

  List<ServicioProductoProveedores> proveedoresList =[];

  Widget _buildTablaSeleccionados() {
    if (selectedProveedores.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedProveedores.length,
          itemBuilder: (BuildContext context, int index) {
            final proveedor = selectedProveedores[index];
            if(proveedoresList.length < selectedProveedores.length){
              proveedoresList.add( ServicioProductoProveedores(
                proveedorId: proveedor.idProveedor,
                costo: 0.0,
                descuento: 0.0,
                total: 0.0,
                calificacion: 0,
                compraMinima: 0.0,
                mejorConocido: '',
                lm: false,
              ));
            }
            ServicioProductoProveedores servicioProductoProveedores = proveedoresList[index];
            return Dismissible(
              key: Key(proveedor.idProveedor),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                setState(() {
                  selectedProveedores.removeAt(index);
                  proveedoresList.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Proveedor eliminado', style: TextStyle(color:Colors.white)),
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
                color: theme.colorScheme.background,
                margin: const EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 15),
                    Flexible(
                      flex:1,
                      child: SizedBox(
                        width: size.width / 5,
                        child: Text(
                          proveedor.nombre,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 29),
                    Flexible(
                      flex:1,
                      child:
                      SizedBox( width: size.width / 5,
                        child: Transform.scale( scale: 0.8,
                          child: SizedBox( width: 80, height: 40,
                            child: TextField(
                              controller: TextEditingController(text: servicioProductoProveedores.costo.toString())
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: servicioProductoProveedores.costo.toString().length),
                                ),
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary.withOpacity(0.7),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                                ),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (double.parse(value) > 0) {
                                      proveedoresList[index].costo = double.parse(value);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                          width: size.width / 5,
                          child: Transform.scale(scale: 0.8, child: SizedBox(width:80, height:40,
                              child: TextField(
                                controller: TextEditingController(text: servicioProductoProveedores.descuento.toString()),
                                style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                                decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                                  focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
                                ),
                                inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                onChanged: (value){
                                  print(value);
                                  if(value.isNotEmpty){
                                    if(double.parse(value) >0){
                                        proveedoresList[index].descuento = double.parse(value);
                                    }
                                  }
                                },
                              )))
                      ),
                    ),
                    Flexible(
                      flex:1,
                      child: SizedBox(
                          width: size.width / 5,
                          child:  Transform.scale(scale: 0.8, child: SizedBox(width:80, height: 40,
                            child: TextField( controller: TextEditingController(text: servicioProductoProveedores.total.toString()),
                              style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                              decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              onChanged: (value){
                                print(value);
                                if(value.isNotEmpty) {
                                  if(double.parse(value) > 0) {
                                    proveedoresList[index].total = double.parse(value);
                                  }
                                }
                              },
                            ),))
                      ),
                    ),
                    Flexible(
                      flex:1,
                      child: SizedBox(
                          width: size.width / 5,
                          child:  Transform.scale( scale: 0.8, child: SizedBox( width:80, height: 40,
                            child: TextField(controller: TextEditingController(text: servicioProductoProveedores.calificacion.toString()),
                              style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                              decoration: InputDecoration( enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
                                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                    borderSide:BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.7))),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[1-9]$|^10$')),],
                              keyboardType: TextInputType.number,
                              onChanged: (value){
                                print(value);
                                if(value.isNotEmpty){
                                 if(int.parse(value) > 0){
                                     proveedoresList[index].calificacion = int.parse(value);
                                 }
                                }
                              },
                            ),)
                          )
                      ),
                    ),
                    Flexible(
                      flex:1,
                      child: SizedBox(
                          width: size.width / 5,
                          child:  Transform.scale(scale:0.8, child: SizedBox(width: 80, height: 40,
                            child: TextField(
                              controller: TextEditingController(text: servicioProductoProveedores.compraMinima.toString()),
                              style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withOpacity(0.7)),
                              decoration:InputDecoration(enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                  borderSide:BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                                focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7))),
                              ),
                              inputFormatters:[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              onChanged: (value){
                                print(value);
                                if(value.isNotEmpty){
                                  if(double.parse(value)> 0){
                                      proveedoresList[index].compraMinima = double.tryParse(value);
                                  }
                                }
                              },
                            ),))
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Transform.scale(
                        scale: 0.8,
                        child: SizedBox(
                          width: 80,
                          height: 40,
                          child: TextField(
                            controller: TextEditingController(
                              text: servicioProductoProveedores.mejorConocido?.toString() ?? "", // Muestra una cadena vacía si es null
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            ),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.secondary.withOpacity(0.7),
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*$')), // Permite solo letras y números
                            ],
                            onChanged: (value) {
                              print(value);
                              if (value.isNotEmpty) {
                                proveedoresList[index].mejorConocido = value;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 34,),
                    Flexible(
                      flex:1,
                      child: Checkbox(
                        checkColor: Colors.white,
                        value: servicioProductoProveedores.lm ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            proveedoresList[index].lm = value ?? false;
                          });
                        },
                      ) ,
                    ),
                    SizedBox(width: 74,),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}
