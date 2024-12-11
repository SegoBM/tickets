import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/ClaveSAT/claveSAT.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/servicioProductosConProveedores.dart';
import 'package:tickets/pages/Compras/pages/materiales/featuresDialogs/color_and_size.dart';
import 'package:tickets/pages/Compras/pages/materiales/featuresDialogs/color_dialog.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/drop_down_button/dropdown_container.dart';
import 'package:tickets/shared/widgets/error/customNoData.dart';
import 'package:tickets/shared/widgets/textfields/autocomplete_PROVEEDOR.dart';
import 'package:tickets/shared/widgets/textfields/autocomplete_decoration.dart';
import 'package:tickets/shared/widgets/textfields/mini_text_field.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/familia_model.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/image_picker.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/textfields/dropdown_buttonform.dart';

import '../../../../controllers/ComprasController/MaterialesControllers/familia_controller.dart';
import '../../../../controllers/ComprasController/MaterialesControllers/material_w_suppliers_controller.dart';
import '../../../../controllers/ComprasController/MaterialesControllers/materialesController.dart';
import '../../../../controllers/ComprasController/ServiciosProductosController/ClaveSAT/claveSAT.dart';
import '../../../../models/ComprasModels/MaterialesModels/materiales.dart';
import '../../../../models/ComprasModels/MaterialesModels/materiales_w_suppliers.dart';
import '../../../../models/ComprasModels/ProveedorModels/proveedor.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/listaPrecio.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/monedas.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

import 'featuresDialogs/manual_color_size.dart';
import 'featuresDialogs/size_dialog.dart';
import 'keys_dialogs/clave_unidad_dialog.dart';
import 'keys_dialogs/key_middle_dialog.dart';
import 'lista_provedores.dart';


class AltaMaterialesScreen extends StatefulWidget {
  List<FamiliaModel> familia;
  List<MonedaModels> moneda;

   AltaMaterialesScreen({
     super.key,
     required this.familia,
     required this.moneda,

   });



  @override
  State<AltaMaterialesScreen> createState() => _AltaMaterialesScreenState();
  static const id = 'alta_materiales_screen';
}
   enum TypeProduct {single, variant}
   enum ProductFeature {size, color, sizeNColor}

  ///[start]///
  class _AltaMaterialesScreenState extends State<AltaMaterialesScreen> with TickerProviderStateMixin {
    /// [uses] ///
    late ThemeData theme;
    late Size size;
    int index = 0;
    late FamiliaModel selectedFamiliaModel;

    ///[GlobalKeys]////
    final GlobalKey altaMatKey = GlobalKey();
    final GlobalKey<FormState> _keey = GlobalKey<FormState>();

    final GlobalKey _colorKey = GlobalKey();
    final GlobalKey _colorNSizeKey = GlobalKey();
    final GlobalKey _colorNSizeKeyManual = GlobalKey();
    final GlobalKey _sizeKey = GlobalKey();
    final _keyDialog = GlobalKey();


    final _codigoRequest = FocusNode();
    final FamiliaController _familiaController = FamiliaController();

    final TextEditingController _satController = TextEditingController();
    String? iDClaveS = "";
    String? claveUnidadMedida;

    ProductFeature feature = ProductFeature.color;

    String selectedClasif = "Clasificacion1";
    String selecteCat = "Categoria1";
    String selectedStat = "Status1";
    List<String> satList = [];
    List<String> listEstatus = ['INACTIVO', 'ACTIVO', 'BLOQUEADO', 'FUERA DE LÍNEA'];
    final List<String> clasiItems = ["Seleccoione una categoria","Clasificacion1","Clasificacion2","Clasificacion3"];
    final List<String> catItem = ['Categoria1', 'Categoria2', 'Categoria3', 'Categoria4'];
    List<String> listCosteo = ['UEPS', 'PEPS', 'PROMEDIO', 'ESTÁNDAR', 'IDENTIFICADO'];
    Map<String, int> statusMap = {
      "INACTIVO":0,
      "ACTIVO":1,
      "BLOQUEADO":2,
      "FUERA DE LÍNEA":3
    };

    List <MaterialesModels> mat = [];

    String selectedMoneda = "";
    List<String> monedaList = [];

    List<String> listFamilias = ["Seleccione una Familia"];
    List<String> familiaListIt = [ "Seleccione una Familia",];
    String selectedFamilia = "Seleccione una Familia";
    List<String> subFamiliaListIt = ["Seleccione una SubFamilia"];
    String selectedSubFamilia = "Seleccione una SubFamilia";

    List<FamiliaModel> _familiaList = [];
    List<MonedaModels> moneda = [];
    List<FamiliaModel> familia = [];
    List<ProveedorModels> selectedProveedores = [];
    List<ListaPrecio> pricesList = [];
    List<ServicioProductoProveedores> proveedoresList =[];
    List<Combination> _corridasList =[];


    late ColorFeature color;
    late SizeFeature sizeF;
    late NewMaterial colorNSize;
    late File? _image;
    late Timer timer;

    List<ColorFeature> colorFeatureList = [];
    List<SizeFeature> sizeFeatureList = [];
    List<NewMaterial> colorSizeFeatureList = [];




    bool _isLoading = true;


    final TextEditingController _searchProviderController = TextEditingController();
    final _threeFormSController = ScrollController();
    final _providersSbController = ScrollController();
    final claveSATController = ClaveSATController();

    final TextEditingController _fotoController = TextEditingController();

    final TextEditingController _codigoProductoController = TextEditingController();
    final TextEditingController _clasificacionController = TextEditingController();
    final TextEditingController _categoriaController = TextEditingController();
    final TextEditingController _estatusController = TextEditingController();
    final TextEditingController _descripcionController = TextEditingController();

    final TextEditingController _familiaNombreController = TextEditingController();
    final TextEditingController _idMaterialController = TextEditingController();
    final TextEditingController _subFamiliaNombreController = TextEditingController();
    final TextEditingController _subFamiliaIDController = TextEditingController();
    final TextEditingController _precioVentaController = TextEditingController(
        text: '0.00');
    final TextEditingController _costoController = TextEditingController(
        text: '0.00');
    final TextEditingController _fraccionArancelariaController = TextEditingController(
        text: '0.00');
    final TextEditingController _unidadMedidaCompraController = TextEditingController(
        text: '0.00');
    final TextEditingController _unidadMedidaVentaController = TextEditingController(
        text: '0.00');
    final TextEditingController _composicionController = TextEditingController();
    final TextEditingController _espesorMMController = TextEditingController(
        text: '0.00');
    final TextEditingController _anchoController = TextEditingController(
        text: '0.00');
    final TextEditingController _largoController = TextEditingController(
        text: '0.00');
    final TextEditingController _metrosXRolloController = TextEditingController(
        text: '0.00');
    final TextEditingController _igiController = TextEditingController();
    final TextEditingController _referenciaCalidadController = TextEditingController();
    final TextEditingController _referenciaColorController = TextEditingController();
    final TextEditingController _gsmController = TextEditingController();


    final TextEditingController _pesoXBultoController = TextEditingController(
        text: '0.00');

    FocusNode _focusNode = FocusNode();
    final FocusNode _focusNode2 = FocusNode();
    final FocusNode _focusNode3 = FocusNode();
    final FocusNode _focusNode4 = FocusNode();
    final FocusNode _focusNode5 = FocusNode();
    final FocusNode _focusNode6 = FocusNode();
    final FocusNode _focusNode7 = FocusNode();
    final FocusNode _focusNode8 = FocusNode();
    final FocusNode _focusNode9 = FocusNode();
    final FocusNode _focusNode10 = FocusNode();


    late TabController tabMatController;
    final GlobalKey _closeButtonKey = GlobalKey();
    final GlobalKey _saveButtonKey = GlobalKey();
    bool _pressed = false;
    bool firsWrite = true;
    String base64String = "";
    String selectedSatPass = "";


    @override
    void initState() {
      initSATData();
      getFamilias();
      getMonedas();
      _getDatos();
      initTimer();
      initControllerAnimation();
      _focusNode = FocusNode();
      Future.delayed(const Duration(milliseconds:500),(){
      _codigoRequest.requestFocus();
      });
      tabMatController = TabController(initialIndex: 0, length: 3, vsync: this,);
      super.initState();
    }
    @override
    void dispose() {
      _satController.dispose();
      timer.cancel();
      _disposeFocusNControllers();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      theme = Theme.of(context);
      size = MediaQuery.of(context).size;

      // ejemplo de uso de la clase PressedKeyListener para detectar cualquier tecla
      return PressedKeyListener(
          keyActions: {
            // Aquí puedes agregar la lógica que quieras ejecutar cuando se presione la tecla Escape
            LogicalKeyboardKey.escape: () {
              if( moveTab(0) == false ){
                moveTab(0);
                Future.delayed(const Duration( milliseconds: 400 ), (){
                  CustomAwesomeDialog(
                    title: Texts.lostData,
                    desc: Texts.lostData,
                    btnCancelOnPress: () {  },
                    btnOkOnPress: () {
                      Navigator.of(context).pop;
                    },).showQuestion(context);
                });
              } else {
                CustomAwesomeDialog(
                  title:  Texts.alertExit,
                  desc: Texts.lostData,
                  btnCancelOnPress:(){},
                  btnOkOnPress:(){
                    Navigator.of(context).pop;
                  },).showQuestion(context);
              }
              print('Escape key pressed');
            },
            LogicalKeyboardKey.f1: () {
              moveTab(0);
            },
            LogicalKeyboardKey.f2: () {
              moveTab(1);
            },
            LogicalKeyboardKey.f4: () {
            },
            // Puedes agregar tantas teclas y acciones como necesites
          },
          Gkey: altaMatKey,
          child: WillPopScope(
              key: _closeButtonKey,
              onWillPop: () async {
                bool salir = false;
                CustomAwesomeDialog(
                  title: 'Saldras de la alta de Material',
                  desc: Texts.lostData,
                  btnCancelOnPress: () {
                    salir = true; },
                  btnOkOnPress: () {
                    selectedProveedores.clear();
                    salir = false;
                  },).showQuestion(context);
                return salir;
              },
              child: Scaffold(
                backgroundColor: theme.colorScheme.background,
                appBar: size.width > 600 ? MyCustomAppBarDesktop(
                  title: 'Alta de Materiales',
                  height: 45,
                  suffixWidget: ElevatedButton(
                    key: _saveButtonKey,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.backgroundColor, elevation: 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Guardar  ', style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold),),
                        Container(
                            padding: const EdgeInsets.all(.5),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme
                                    .colorScheme.onSecondary, width: .5,),)),
                            child: Text(' f4 ', style: TextStyle(
                                color: theme.colorScheme.onPrimary),)),
                        Icon(IconLibrary.iconSave,
                          color: theme.colorScheme.onPrimary,
                          size: size.width * .012,),
                      ],),
                    onPressed: () async {
                      if( tabMatController.index == 0  ){
                      conditionalSave();
                      } else {
                        await moveTab(0);
                        Future.delayed( const Duration(milliseconds: 400),(){
                          conditionalSave();
                          Navigator.of(context).pop();
                        });
                      }

                    },
                  ),
                  context: context,
                  backButton: true,
                  defaultButtons: false,
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                ) : null,
                body: size.width > 600 ? _landScapeBody() : _portraitBody(),
              ))
      );
    }

////// BodyStructure /////

    Widget _landScapeBody() {
      return Column(
        children: [
          TabBar(onTap: (index){
            if( index != 0 ){
              setState(() {
                typeView = TypeProduct.single;
              });
            } else if(index==0){
              Future.delayed(const Duration( milliseconds: 300 ),(){
                _codigoRequest.requestFocus();
              });
            }
          },
            controller: tabMatController,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: Colors.grey[ 400 ],
            labelStyle: const TextStyle(
                fontSize: 17.0, fontWeight: FontWeight.bold),
            indicatorWeight: 5,
            padding: EdgeInsets.symmetric(horizontal: size.width * .15),
            tabs: const [
              Tab(text: "Datos Generales"),
              Tab(text: "Datos de proveedor"),
              Tab(text: "Datos Fiscales"),
            ],),
          Expanded(
            child: SizedBox(height: size.height - 140, width: size.width, child:
            TabBarView(
              controller: tabMatController,
              children: [
                _datos(),
                _providersFlexBody(),
                _datosFiscales(),
              ],
            ),
            ),
          )
        ]
        ,
      );
    }

    Widget _portraitBody() {
      return const Placeholder();
    }
    Widget _providersFlexBody() {
      return Column(
        children: [
          // _pricesExchange(),
          ..._sat(),
          _headerContainer("PROVEDORES"),
          // _miniButtonBar(),
          const SizedBox(height: 5),
          _headerSupplier(),
          _containerProviders(),
        ],);
    }

    /// [ Elements ]///


    void _toDown(){
      _threeFormSController.animateTo(
          _threeFormSController.position.extentTotal,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn);
    }
    void toUp(){
      _threeFormSController.animateTo(
          _threeFormSController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn);
    }

    void _moveMethod(){
      if(typeView == TypeProduct.single){
        toUp();
      } else {
        _toDown();
      }
    }
    Widget _datos() {
      return Form(
        key: _keey,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _threeFormSController,
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: _threeFormSController,
              child: Column(children: [
                _datosEnGeneral(),
                const SizedBox(height: 5,),
                ..._familySelector(),
                // _datosEnEspecifico(),
                _animatedDatosEnEspecifico(),
              ]),

            ),
          ),
        ),
      );
    }

    Widget _datosFiscales(){
      return Column(
        children: [
          _headerContainer("Datos Fiscales"),
          Row(
            children: [

              _littleDialog(),
            ],
          )
        ],
      );
    }
    Widget _littleDialog(){
      return IconButton(
        onPressed: () async {
          await myShowDialogScale(
            const MiddleDialogContainer(),
            context ,height: size.height*.17, width: size.width*.40,
              key: _keyDialog
          );
        },
        icon: Icon( Icons.insert_emoticon,
          color: theme.colorScheme.secondary,
          size: 30,),
      );
    }

    Widget _datosEnGeneral() {
      return Column(
          children:
          [
            _headerContainer("Datos Generales"),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  _dividedFormRow(portion: .28,
                    MyTextfieldIcon(
                        focusNode: _codigoRequest,
                        colorLineBase: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.background,
                        suffixIcon: const Icon(IconLibrary.barCode),
                        floatingLabelStyle: TextStyle(
                            color: theme.colorScheme.onPrimary),
                        labelText: 'Código',
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10)
                        ],
                        textController: _codigoProductoController,
                        validator: (value) {
                          if( value == null || value.isEmpty ){
                            return 'Este campo es requerido';
                          } else if(value.length < 5){
                            return 'El código debe tener al menos 5 caracteres.Ingresados${value.length}';
                          }if(value.length > 10){
                            return 'El código no debe tener más de 16 caracteres. Ingresados${value.length}';
                          }
                          return null;
                        }
                    ),
                    CustomDropdown(
                        labelText: "Clasificacion",
                        items: clasiItems,
                        textController: _clasificacionController,
                        onChanged: (newValue) {
                          setState(() {
                            _clasificacionController.text = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es requerido';
                          }
                          return null;
                        }
                    ),
                  ),
                  const SizedBox(height: 10,),
                  _dividedFormRow(portion: .28,
                    CustomDropdown(
                        labelText: "Categoria",
                        items: catItem,
                        textController: _categoriaController,
                        onChanged: (newValue) =>
                            setState(() {
                              _categoriaController.text = newValue!;
                            }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es requerido';
                          }
                          return null; // Indica que el valor es válido
                        }
                    ),
                    CustomDropdown(
                        labelText: 'Estatus',
                        items: listEstatus,
                        textController: _estatusController,
                        onChanged: (newValue) =>
                            setState(() {
                              _estatusController.text = newValue!;
                            }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es requerido';
                          }
                          return null; // Indica que el valor es válido
                        }
                    ),
                  ),
                  const SizedBox(height: 10),
                  _doubleSizeing(leftPortion: .36,rightPortion: .20,
                    MyTextfieldIcon(
                        formatting: true,
                        colorLineBase: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.background,
                        labelText: 'Referencia',
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100)
                        ],
                        floatingLabelStyle: TextStyle(
                            color: theme.colorScheme.onPrimary),
                        textController: _descripcionController,
                        suffixIcon: const Icon(IconLibrary.noteIcon),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo es requerido';
                          }
                          if(value.length < 10){
                            return 'La descripción debe tener al menos 10 caracteres. Ingresados (${value.length}) ';
                          }
                          return null; // Indica que el valor es válido
                        }
                    ),
                    SegmentedButton<TypeProduct>(
                      segments:const  <ButtonSegment<TypeProduct>>[
                        ButtonSegment<TypeProduct>(
                            value: TypeProduct.single,
                            label: Text('Simple', style: TextStyle(fontSize: 14),selectionColor: Colors.white,),
                          icon: Icon(IconLibrary.iconGroups),
                        ),
                        ButtonSegment<TypeProduct>(
                            value: TypeProduct.variant,
                            label: Text('Variante', style: TextStyle(fontSize: 14),selectionColor: Colors.white,),
                          icon: Icon(IconLibrary.iconGroups),
                        ),],
                      style:  ButtonStyle(
                        splashFactory: InkSplash.splashFactory,
                        side: MaterialStateProperty.resolveWith((states){
                          if(states.contains(MaterialState.selected)){return BorderSide(color: theme.colorScheme.primary, width: 2);} return BorderSide(color: theme.colorScheme.onPrimary, width: 1);/// cambio de color al seleccionar
                        }),
                       enableFeedback: true,
                        backgroundColor: MaterialStateProperty.resolveWith((states){
                          if(states.contains(MaterialState.selected)){return theme.colorScheme.primary;} return Colors.transparent;/// cambio de color al seleccionar
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith((states){
                          if(states.contains(MaterialState.selected)){ return theme.colorScheme.onPrimary;} return theme.colorScheme.onPrimary;/// cambio de color al seleccionar
                        }),
                        overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.2)), // Efecto al presionar
                        shape: MaterialStateProperty.all( RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ) ,
                        visualDensity: VisualDensity.comfortable,
                      ),
                      selected: <TypeProduct>{typeView},
                      onSelectionChanged: ( Set<TypeProduct> newSelection ){
                        setState(() {
                          typeView = newSelection.first;
                        });
                        _moveMethod();
                      },
                    )
                  ),
                ]),

                Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyImagePickerWidget(
                      holderText: 'Insertar Imagen',
                      height: size.height * .35,
                      width: size.width * .25,
                      onImagePicked: (File image) {
                        setState(() {
                          _image = image;
                        });
                      },
                    ),
                  ],),
                //const SizedBox(width: 50,),
              ],),
          ]);
    }
    TypeProduct typeView = TypeProduct.single;


    Widget _simple(){
      return Column(
        key: const ValueKey<TypeProduct>(TypeProduct.single),
        children:[
          _headerContainer("Datos en especifico"),
          _threeFormBody(),
        ]
      );
    }
    Widget _variant(){
      return Column(
        key: const ValueKey<TypeProduct>(TypeProduct.variant),
        children:[
          _headerContainer("Variantes"),
          _variantsForm(),
          const SizedBox(height: 10,),
        ]
      );
    }


    Widget _animatedDatosEnEspecifico(){
      return Column(
        children: [
          AnimatedSwitcher(
            reverseDuration: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation){
                return SlideTransition(
                    position: Tween<Offset>( begin: const Offset( 1,0 ), end: const Offset( 0,0 ) ).animate(animation),
                  child:child,
                );
            },
            child: typeView == TypeProduct.single? _simple():_variant(),
          )
        ],
      );
    }




    List<Widget> _familySelector() {
      return [
        _headerContainer("Seleccione una Familia"),
        _dividedFormRow(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Familia",
                style: TextStyle(fontSize: 15),
              ),
              MyDropdown(
                textStyle: TextStyle(
                    fontSize: 12.0, color: theme.colorScheme.onPrimary),
                dropdownItems: listFamilias,
                selectedItem: selectedFamilia,
                suffixIcon: const Icon(IconLibrary.iconGroups),
                onPressed: (String? value) async {
                  selectedFamilia = value!;
                  selectedSubFamilia = "Seleccione una SubFamilia";
                  if (value != "Seleccione una familia") {
                    subFamiliaListIt = ["Seleccione una SubFamilia"];
                    for (int i = 0; i < familia.length; i++) {
                      if (familia[i].nombre == value) {
                        selectedFamiliaModel = familia[i];
                        break;
                      }
                    }
                    for (int j = 0;
                    j < selectedFamiliaModel.subFamilia!.length;
                    j++) {
                      subFamiliaListIt
                          .add(selectedFamiliaModel.subFamilia![j].nombre);
                    }
                  }
                  setState(() {});
                },
                enabled: true,
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 310),
                reverseDuration: const Duration(milliseconds:500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: selectedFamilia != "Seleccione una Familia"
                    ? Column(
                  key: ValueKey<String>(selectedFamilia),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SubFamilia",
                      style: TextStyle(fontSize: 15),
                    ),
                    MyDropdown(
                      enabled: true,
                      textStyle: TextStyle(
                          fontSize: 12.0,
                          color: theme.colorScheme.onPrimary),
                      dropdownItems: subFamiliaListIt,
                      selectedItem: selectedSubFamilia,
                      suffixIcon: const Icon(IconLibrary.iconGroups),
                      onPressed: (String? value) async {
                        print(value);
                        setState(() {
                          selectedSubFamilia = value!;
                        });
                      },
                    )
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        )
      ];
    }


    Widget _threeFormBody() {
      return Column(
        children:
        <Widget>[
          _threeRowContainer(
              MyTextfieldIcon(
                backgroundColor: theme.colorScheme.background,
                labelText: 'GSM',
                textController: _igiController,
                suffixIcon: Icon(
                    Icons.public_off_outlined, size: size.height * .025),
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
              ),
              MyTextfieldIcon(
                focusNode: _focusNode10,
                autoSelectText: true,
                backgroundColor: theme.colorScheme.background,
                labelText: 'Peso por Bulto',
                textController: _pesoXBultoController,
                suffixIcon: Icon(
                  Icons.scale_outlined, size: size.height * .025,),
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
                validator: (value) {
                  if (!isNumeric(value!)) {
                    return 'Por favor ingrese un valor númerico';
                  }
                },
              ),
              MyTextfieldIcon(
                focusNode: _focusNode,

                autoSelectText: true,
                backgroundColor: theme.colorScheme.background,
                suffixIcon: Icon(
                    IconLibrary.iconMoney, size: size.height * .025),
                labelText: 'Precio de Venta',
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
                textController: _precioVentaController,
                validator: (value) {
                  if (!isNumeric(value!)) {
                    return "Porfavor ingrese un valor númerico";
                  }
                },
              )
          ),
          const SizedBox(height: 10,),
          _threeRowContainer(
              MyTextfieldIcon(
                focusNode: _focusNode2,
                autoSelectText: true,
                backgroundColor: theme.colorScheme.background,
                // validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                suffixIcon: Icon(Icons.payment, size: size.height * .025),
                labelText: 'Costo',
                textController: _costoController,
                validator: (value) {
                  if (!isNumeric(value!)) {
                    return 'ingrese un valor númerico';
                  }
                },
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
              ),
              MyTextfieldIcon(
                focusNode: _focusNode3,
                autoSelectText: true,
                backgroundColor: theme.colorScheme.background,
                labelText: 'Fraccion arancelaria',
                textController: _fraccionArancelariaController,
                suffixIcon: Icon(Icons.percent, size: size.height * .025),
                validator: (value) {
                  if (!isNumeric(value!)) {
                    return 'Por favor ingrese un valor númerico';
                  }
                },
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
              ),
              MyTextfieldIcon(
                focusNode: _focusNode4,
                autoSelectText: true,
                backgroundColor: theme.colorScheme.background,
                labelText: 'Unidad Medida ( Compra )',
                textController: _unidadMedidaCompraController,
                suffixIcon: Icon(
                    Icons.straighten_outlined, size: size.height * .025),
                validator: (value) {
                  if (!isNumeric(value!)) {
                    return 'Por favor ingrese un valor númerico';
                  }
                },
                floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary),
              )
          ),
          const SizedBox(height: 10),
          _threeRowContainer(
            MyTextfieldIcon(
              focusNode: _focusNode5,
              autoSelectText: true,
              backgroundColor: theme.colorScheme.background,
              labelText: 'Unidad Medida ( Venta )',
              textController: _unidadMedidaVentaController,
              suffixIcon: Icon(
                  Icons.straighten_outlined, size: size.height * .025),
              validator: (value) {
                if (!isNumeric(value!)) {
                  return 'Por favor ingrese un valor númerico';
                }
              },
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            MyTextfieldIcon(
              backgroundColor: theme.colorScheme.background,
              labelText: 'Composición',
              textController: _composicionController,
              suffixIcon: Icon(IconLibrary.callMade, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            MyTextfieldIcon(
              focusNode: _focusNode6,
              autoSelectText: true,
              backgroundColor: theme.colorScheme.background,
              labelText: 'Espesor "MM"',
              textController: _espesorMMController,
              suffixIcon: Icon(
                  Icons.square_foot_outlined, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              validator: (value) {
                if (!isNumeric(value!)) {
                  return 'Por favor ingrese un valor númerico';
                }
              },
            ),
          ),
          const SizedBox(height: 10,),
          _threeRowContainer(
            MyTextfieldIcon(
              focusNode: _focusNode7,
              autoSelectText: true,
              backgroundColor: theme.colorScheme.background,
              enabled: true,
              labelText: 'Ancho',
              textController: _anchoController,
              suffixIcon: Icon(
                  Icons.width_wide_outlined, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              validator: (value) {
                if (!isNumeric(value!)) {
                  return 'Por favor ingrese un valor númerico';
                }
              },

            ),
            MyTextfieldIcon(
              focusNode: _focusNode8,
              autoSelectText: true,
              backgroundColor: theme.colorScheme.background,
              labelText: 'Largo',
              textController: _largoController,
              suffixIcon: Icon(
                  Icons.density_large_outlined, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              validator: (value) {
                if (!isNumeric(value!)) {
                  return 'Por favor ingrese un valor númerico';
                }
              },
            ),
            MyTextfieldIcon(
              focusNode: _focusNode9,
              autoSelectText: true,
              backgroundColor: theme.colorScheme.background,
              labelText: 'Metros por rollo',
              textController: _metrosXRolloController,
              suffixIcon: const Icon(Icons.radar),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              validator: (value) {
                if (!isNumeric(value!)) {
                  return 'Por favor ingrese un valor númerico';
                }
              },
            ),
          ),
          const SizedBox(height: 10,),
          _threeRowContainer(
            MyTextfieldIcon(
              backgroundColor: theme.colorScheme.background,
              labelText: 'IGI',
              textController: _gsmController,
              suffixIcon: Icon(
                  Icons.format_underline, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            MyTextfieldIcon(
              backgroundColor: theme.colorScheme.background,
              labelText: 'Referencia de Calidad',
              textController: _referenciaCalidadController,
              suffixIcon: Icon(
                  Icons.psychology_outlined, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            MyTextfieldIcon(
              backgroundColor: theme.colorScheme.background,
              labelText: 'Referencia de Color',
              textController: _referenciaColorController,
              suffixIcon: Icon(
                  Icons.palette_outlined, size: size.height * .025),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      );
    }

    bool isNumeric(String s) {
      return double.tryParse(s) != null;
    }


    Widget _headerContainer(String text) {
      return Container(
        width: size.width * .4,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(children: [
            Text(text, style: const TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.bold),),
            Divider(thickness: 2, color: theme.colorScheme.secondary,),
          ],
          ),),);
    }





    Widget _containerProviders(){
      if(proveedoresList.length != selectedProveedores.length){
        proveedoresList = selectedProveedores.map((supplier) => ServicioProductoProveedores(
          proveedorId: supplier.idProveedor,
          costo: 0.0,
          descuento: 0.0,
          total: 0.0,
          calificacion: 0,
          compraMinima: 0.0,
          mejorConocido: '',
        )).toList();
      }
      if( selectedProveedores.isEmpty ){
        return Container(
          height: size.height-480,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),top: Radius.circular(10)

            ),
          ),
          child: Center( // Aquí en lugar de Expanded
            child: NoDataWidget(
                text: "No hay proveedor\nPor favor agregue uno."
            ),
          ),
        );
      }
      return Container(height: size.height-480 ,
        decoration:  BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10)
          ),
        ),
        child:Scrollbar(
          thumbVisibility: true,
          controller: _providersSbController,
          child: FadingEdgeScrollView.fromScrollView(
            child: ListView.builder(
              controller: _providersSbController,
                  itemCount: selectedProveedores.length,
                  padding: const EdgeInsets.all(10),
                  itemExtent: 50,
                  reverse: false,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                      final suppliers = selectedProveedores[index];
                      if(proveedoresList.length != selectedProveedores.length){
                        proveedoresList.add(ServicioProductoProveedores(
                          proveedorId: suppliers.idProveedor,
                          costo: 0.0,
                          descuento: 0.0,
                          total: 0.0,
                          calificacion: 0,
                          compraMinima: 0.0,
                          mejorConocido: '',
                        ));}
                      ServicioProductoProveedores servicioProductoProveedores =  proveedoresList[index];
                           return _priceSuppliertCard2(suppliers, servicioProductoProveedores);
                  }
              ),
          ),
        ),
      );
    }



    Widget _priceSuppliertCard2( ProveedorModels selectedProveedor, ServicioProductoProveedores servicioProductoProveedores ){
      return MySwipeTileCard(
        iconColor: theme.colorScheme.onPrimary,
        colorBasico: theme.colorScheme.background,
        key: Key( selectedProveedor.idProveedor ),
          onTapLR: (){},
          onTapRL: (){
          setState(() {
            selectedProveedores.removeAt(index);
            proveedoresList.removeAt(index);
          });
          },
          containerB: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox( width: size.width/12, height: 120,
                  child: Tooltip(
                    message: selectedProveedor.nombre,
                    child: Text(overflow: TextOverflow.ellipsis,
                      selectedProveedor.nombre,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,),
                  ),
                ),
                SizedBox( width: size.width*.04,
                  child: MiniTextFiled(
                      controller: TextEditingController(
                          text: servicioProductoProveedores.costo.toString()
                      )
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: servicioProductoProveedores.costo.toString().length
                          ),
                        ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (double.parse(value) > 0) {
                            proveedoresList[index].costo = double.parse(value);
                          }
                        }
                      },
                  ),
                ),
                SizedBox(
                  width: size.width*.04,
                  child: MiniTextFiled(
                      controller: TextEditingController(
                        text:servicioProductoProveedores.descuento.toString(),
                      ),
                      onChanged: (value){
                        if(value.isNotEmpty){
                          if( double.parse(value)>0){
                            {
                            proveedoresList[index].descuento = double.parse(value);
                            }
                          }
                        }
                      }
                  ),
                ),
                SizedBox( width: size.width*.04,
                  child: MiniTextFiled(
                      controller: TextEditingController(text: servicioProductoProveedores.total.toString(),
                      ),
                      onChanged: (value){
                        if(value.isNotEmpty){
                          if(double.parse(value)>0){
                            proveedoresList[index].total = double.parse(value);
                          }
                        }
                      }
                  ),
                ),
                SizedBox( width: size.width*.04,
                  child:MiniTextFiled(
                    controller:TextEditingController(text: servicioProductoProveedores.calificacion.toString(),
                    ),
                    onChanged: (value){
                      if(int.parse(value) > 0){
                        proveedoresList[index].calificacion = int.parse(value);
                      }
                    },
                  ),
                ),
                SizedBox( width: size.width*.04,
                  child:MiniTextFiled(
                    controller:TextEditingController(
                      text: servicioProductoProveedores.compraMinima.toString(),
                    ),
                    onChanged: (value){
                     if(value.isNotEmpty) {
                        if(double.parse(value) > 0){
                          proveedoresList[index].compraMinima = double.parse(value);
                        }
                     }
                    },
                  ),
                ),
                SizedBox( width: size.width*.04,
                  child: MiniTextFiled(
                    inputFormatters:  [ FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*$')) ],
                    controller:TextEditingController(
                      text: servicioProductoProveedores.mejorConocido?? 'Empty Field',
                    ),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        proveedoresList[index].mejorConocido = value;
                      }
                    },
                  )
                ),
                SizedBox( width: size.width*.04,
                  child: Checkbox(
                    checkColor: Colors.white,
                    value: servicioProductoProveedores.lm?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        proveedoresList[index].lm = value?? false;
                      });
                    },
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
          )
      );
    }




  Widget _dividedFormRow( Widget widgetL, Widget widgetR,{ double portion = .20,   bool betweenSpace = true } ){
      return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox( width: size.width*portion , child: widgetL,),
          betweenSpace == true ?  const SizedBox( width: 10, ): const SizedBox( width: 0,),
          SizedBox( width: size.width*portion, child: widgetR,),
        ],);
    }
    Widget _doubleSizeing( Widget widgetL, Widget widgetR,{ double leftPortion = .20, double rightPortion = .20,   bool betweenSpace = true } ){
      return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox( width: size.width*leftPortion , child: widgetL,),
          betweenSpace == true ?  const SizedBox( width: 10, ): const SizedBox( width: 0,),
          SizedBox( width: size.width*rightPortion, child: widgetR,),
        ],);
    }




  Widget _threeRowContainer( Widget widget1, Widget widget2, Widget widget3){
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children:
          [
            const SizedBox(width: 5,),
            SizedBox( width: size.width*.223, child: widget1,),
            SizedBox( width: size.width*.223, child: widget2,),
            SizedBox( width: size.width*.223, child: widget3,),
            const SizedBox(width: 5,),
          ]
      );
    }


///[second_tab_page]///
    Widget _headerSupplier() {
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
                  _provedoresDialog(context);
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

   _provedoresDialog(BuildContext context){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return Dialog(
              child: Container(
                width: size.width*.6,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomAutocomplete(
                  textController: _searchProviderController,
                  onValueChanged: (List<ProveedorModels> selectedProviders ) {
                    _onProviderSelected(selectedProviders );
                  },
                ),
              ),
            );
          }
      );
  }

  final ScrollController _variantScroll = ScrollController();

    Widget _variantsForm(){
      return Column(
          children:[
            variantsButtons(),
            const SizedBox(height: 10,),
            _featuresHeaderContainer(),
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8
                )),
              ),
              child: colorFeatureList.isNotEmpty||sizeFeatureList.isNotEmpty||
                  colorSizeFeatureList.isNotEmpty|| _corridasList.isNotEmpty?
              Scrollbar(
                controller: _variantScroll,
                child: FadingEdgeScrollView.fromScrollView(
                  child: ListView.builder(
                      controller: _variantScroll,
                      itemCount: listFeatureItem(),
                      itemBuilder: (context,index) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double>animation){
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                    begin: const Offset(0,1),
                                    end: const Offset(0,0)
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _ifCards(index),
                        );
                      }
                  ),
                ),
              ):  NoDataWidget(text: 'Presione "agregar" para añadir elemento'),
            ),
            const SizedBox(height: 20,),
          ]);

    }
    Widget _ifCards(int index){
      if(colorFeatureList.isNotEmpty){
        return  _colorsCard(colorFeatureList[index],index);
      } else if(sizeFeatureList.isNotEmpty){
        return _sizeCard( sizeFeatureList[index],index);
      }else if(colorSizeFeatureList.isNotEmpty ) {
        return _sizeNColorCard(colorSizeFeatureList[index], index);
      }else if(_corridasList.isNotEmpty){
        return _corridasCard(_corridasList[index], index);
      }else{
        return NoDataWidget(text:"No se agrego ninguna varienate");
      }
    }

    Widget _featuresHeaderContainer(){
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child:AnimatedSwitcher(
            duration: const Duration( milliseconds:300 ),
            transitionBuilder: (Widget child, Animation<double> animation ){
              return  SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0,4),
                    end: const  Offset(0,0) )
                    .animate(animation),
                child: child,
              );
            },
          child: _buildFeatureText(),
        )
      );
    }

    Widget _buildFeatureText(){
      if(feature == ProductFeature.color){
        return  Row(
          key: const Key( 'Color' ),
          children: [
            const Tooltip(
              message: "Agregar color",
              child: Icon( Icons.color_lens_outlined ),
            ),
            const SizedBox(width:5),
             Text("Color",style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const Spacer(),
            Text("Referencia", style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const Spacer(),
            Text("Referencia Origen", style: TextStyle( color: theme.colorScheme.onPrimary ),),
          ],
        );
    }
      
      else if(feature == ProductFeature.size ){
        return  Row(
          key: const Key( 'Talla' ) ,
          children: [
          const SizedBox(width: 5,),
            Text("Talla", style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const Spacer(),
            Text("Referencia Talla", style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const Spacer(),
            Tooltip(message:"Talla",child: Icon( Icons.straighten_outlined, color: theme.colorScheme.onPrimary,)),
          ],
        );
    } else if(feature == ProductFeature.sizeNColor ){
        return  Row(
          key: const Key( 'Color y Talla'),
          children: [
            const SizedBox(width: 5,),
            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(Icons.shuffle_outlined, color: theme.colorScheme.onPrimary,),
                Text("Etiqueta ", style: TextStyle( color: theme.colorScheme.onPrimary ),),
              ],),
            const Spacer(),
            Text("Referencia", style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const Spacer(),
            Text("Receferencia Color Origen", style: TextStyle( color: theme.colorScheme.onPrimary ),),
            const SizedBox(width: 5,),
          ],
        );
      }
      return Container();
    }

    Widget _columnW(Widget title1, Widget text1, Widget title2, Widget text2 ){
      return Column(
        children: [
          SizedBox(width: size.width*.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(child: title1,),
                SizedBox(child: text1,),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          SizedBox(
            width: size.width*.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(child: title2,),
                SizedBox(child: text2,),
              ],
            ),
          ),
        ],
      );
    }

    Widget variantsButtons(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SegmentedButton(
              segments: const  [
                ButtonSegment(
                    value: ProductFeature.color,
                    label: Text('Color'),
                    icon: Icon(Icons.color_lens_outlined),
                ),
                ButtonSegment(
                    value: ProductFeature.size,
                    label: Text('Talla'),
                    icon: Icon(Icons.straighten_outlined),
                ),
                ButtonSegment(
                    value: ProductFeature.sizeNColor,
                    label: Text('Color y Talla'),
                    icon: Icon(Icons.shuffle,),
                ),
              ],
              selected:{feature},
                onSelectionChanged: (Set<ProductFeature> selected){
                  print(selected);
                  conditionalDialog(selected);

                },
              style: ButtonStyle(
            splashFactory: InkSplash.splashFactory,
            side: MaterialStateProperty.resolveWith((states){
              if(states.contains(MaterialState.selected)){
                return BorderSide(color: theme.colorScheme.primary, width: 2);
              }
              return BorderSide(color: theme.colorScheme.onPrimary, width: 1);/// cambio de color al seleccionar
            }),
            enableFeedback: true,
            backgroundColor: MaterialStateProperty.resolveWith((states){
              if(states.contains(MaterialState.selected)){
                return theme.colorScheme.primary;
              }
              return Colors.transparent;
            }),
            foregroundColor: MaterialStateProperty.resolveWith((states){
              if(states.contains(MaterialState.selected)){
                return theme.colorScheme.onPrimary;
              }
              return theme.colorScheme.onPrimary;
            }),
            overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.2)), // Efecto al presionar
            shape: MaterialStateProperty.all( RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            ) ,
            visualDensity: VisualDensity.comfortable,
          ),
          ),
          const SizedBox(width: 10,),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: (){
                _showFeaturesDialogs();
                print("adding");
              },
              style: ElevatedButton.styleFrom(
                primary: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side:  BorderSide(
                      color: theme.colorScheme.secondary ,
                      width: 1,strokeAlign: BorderSide.strokeAlignCenter
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Agregar", style: TextStyle( color: theme.colorScheme.onPrimary ),),
                  Icon(Icons.add, color: theme.colorScheme.onPrimary,),
                ],
              ),
            ),
          ),
        ],
      );
    }

    void optionDialog(){
      showDialog(context: context,
          builder: (context){
        return SimpleDialog(
          title: Row(
            children: [
              const Text("Seleccione una opción"),
              const Spacer(),
              Container(
                width: 25,height: 25,
                decoration: BoxDecoration(
                  color:theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon:  Icon(Icons.close, size: size.width*.0069,color: Colors.red,),
                ),
              ),

            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.4)),
                    ),
                    onPressed: ()async {
                      Navigator.pop(context);
                       await myShowDialogScale(
                            ManualColorSize( onSaved: (List<Combination> corridas){
                              setState(() {
                                print("recive $corridas" );
                                _corridasList = corridas;
                                print(_corridasList.length);
                              });
                            }),
                           context,
                           width: size.width*.40,
                           height:size.height*.65,
                           key:_colorNSizeKeyManual
                       );
                    },
                    child:  Text("Combinación por corrida", style: TextStyle( color: theme.colorScheme.onPrimary ),),
                  ),
                  const  SizedBox(width: 1,),
                  ElevatedButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.orangeAccent.withOpacity(0.4)),
                    ),
                    onPressed: ()async {
                      Navigator.pop(context);
                        await myShowDialogScale(
                            ColorAndSize(  onSave: (List<NewMaterial> newMaterial){
                              setState(() {
                                colorSizeFeatureList = newMaterial;
                              });
                            }),
                            context,
                            width: size.width*.40,
                            height:size.height*.65,
                            key:_colorNSizeKey
                        );
                    },
                    child:  Text("Combinaciónes posibles",style: TextStyle( color: theme.colorScheme.onPrimary ),),
                  ),


                ],
              ),
            )
          ],
        );
      });
    }

    void manualcombination(){

    }

    void conditionalDialog(Set<ProductFeature> selected){
      if(colorFeatureList.isNotEmpty||colorSizeFeatureList.isNotEmpty || sizeFeatureList.isNotEmpty){
        CustomAwesomeDialog(
            title: 'Los datos se perderan.',
            desc: '¿Estas seguro de avanzar?',
            btnCancelOnPress: (){},
            btnOkOnPress: (){
              setState(() {
                feature = selected.first;
                _showFeaturesDialogs();
              });
            }).showQuestion(context);
      }else{
        setState(() {
          feature = selected.first;
          _showFeaturesDialogs();
        });
      }
    }
    
    void clearFeatureLists(){
      colorFeatureList.clear();
      sizeFeatureList.clear();
      colorSizeFeatureList.clear();
    }



    Future<void> _showFeaturesDialogs() async {
      if(feature == ProductFeature.color){
              clearFeatureLists();
              await myShowDialogScale(
              ColorFeatureDialog(onSaved: (List<ColorFeature> color) {
                setState(() {
                  colorFeatureList = color;
                });
              },),
              context,
              width: size.width*.35,
              height: size.height*.65,
              key: _colorKey
              );
      } else if(feature == ProductFeature.size){
          clearFeatureLists();
          await myShowDialogScale(
              SizeFeatureDialog( onSaved: (List<SizeFeature> size){
                setState(() {sizeFeatureList = size; });
              }),
              context,width: size.width*.35, height: size.height*.65,key: _sizeKey
          );
      } else if(feature == ProductFeature.sizeNColor){
        clearFeatureLists();
        optionDialog();
      }
    }


  /// [methods]
    ///

Future< String > compressToBase64( String base64Str, { int calidad = 50  } ) async {
    Uint8List bytes = base64.decode( base64Str );
    img.Image? image = img.decodeImage(bytes);
    Uint8List jpeg = img.encodeJpg(image!, quality: calidad);
    return base64.encode(jpeg);
}
///actualiza la lista en pantalla de provedores.
    ///
_onProviderSelected(List<ProveedorModels> selectedProveedores){
     setState(() {
      this.selectedProveedores = selectedProveedores;
     });
}

    Future<void> _getDatos() async {
      try{
        print( "getting Data" );
        List<FamiliaModel> familia = [];
        familia = await _familiaController.getFamilia();
       _familiaList = familia;

      } catch (e){
        print(e);
      }
    }

    Future <List<FamiliaModel>> getDatos () async {
    return _familiaList;
    }


  Future<void> _saveMaterial() async {
      try{
        print( "Estoy guardado" );
        MaterialesController materialesController = MaterialesController();
        MaterialesModels  material = MaterialesModels(
        categoria: _categoriaController.text.trim(),
        codigoProducto: _codigoProductoController.text.trim(),
        unidadMedidaCompra: _unidadMedidaCompraController.text.trim(),
        unidadMedidaVenta: _unidadMedidaVentaController.text.trim(),
        composicion: _composicionController.text.trim(),
        espesorMM: double.tryParse(_espesorMMController.text.trim()) ?? 0.0,
        ancho: double.tryParse(_anchoController.text.trim()) ?? 0.0,
        largo: double.tryParse(_largoController.text.trim()) ?? 0.0,
        metrosXRollo: int.tryParse(_metrosXRolloController.text.trim()) ?? 0,
        costo: double.tryParse(_costoController.text.trim()) ?? 0.0,
        precioVenta: double.tryParse(_precioVentaController.text.trim()) ?? 0.0,
        igi: double.tryParse(_igiController.text.trim()) ?? 0.0,
        referenciaCalidad: _referenciaCalidadController.text.trim(),
        referenciaColor: _referenciaColorController.text.trim(),
        gsm: double.tryParse(_gsmController.text.trim()) ?? 0.0,
        pesoXBulto: double.tryParse(_pesoXBultoController.text.trim()) ?? 0.0,
        descripcion: _descripcionController.text.trim(),
        foto: base64String,
        subFamiliaID: selectedFamiliaModel.subFamilia![index].iDSubFamilia,
        fraccionArancelaria: double.tryParse(_fraccionArancelariaController.text.trim()) ?? 0.0,
        estatus: statusMap[_estatusController.text.trim()] ?? 0,
        subFamiliaNombre: selectedSubFamilia.trim(),
        familiaNombre: selectedFamilia.trim(),
      );
        // print( $ID );
        print(statusMap[_estatusController.text.trim()] ?? 0);
        print( material.toJson() );
       final succes = await materialesController.saveMaterial(material);
       if( succes ){
         CustomAwesomeDialog(
              title: 'Material guardado',
              desc: 'El material se ha guardado correctamente',
              btnCancelOnPress: (){},
              btnOkOnPress: ( ){ Navigator.of(context).pop(); }).showSuccess(context);
         await Future.delayed(const Duration(milliseconds: 3000), (){
           _keey.currentState!.reset();
           Navigator.of(context).pop();
         });
       }
     } catch (e ){
        print('Error al guardar el material: ${e.toString()}');
     }
  }

  Future<void> _postMaterialSupplier() async {
    try {
    MaterialSupplierController materialSupp = MaterialSupplierController();
    MaterialSuppModel matSupp = MaterialSuppModel(
      // idMaterial:idMaterial,
      categoria: _categoriaController.text.trim(),
      codigoProducto: _codigoProductoController.text.trim(),
      unidadMedidaCompra: _unidadMedidaCompraController.text.trim(),
      unidadMedidaVenta: _unidadMedidaVentaController.text.trim(),
      composicion: _composicionController.text.trim(),
      espesorMm: double.tryParse(_espesorMMController.text.trim()) ?? 0.0,
      ancho: double.tryParse(_anchoController.text.trim()) ?? 0.0,
      largo: double.tryParse(_largoController.text.trim()) ?? 0.0,
      metrosXRollo: int.tryParse(_metrosXRolloController.text.trim()) ?? 0,
      costo: double.tryParse(_costoController.text.trim()) ?? 0.0,
      precioVenta: double.tryParse(_precioVentaController.text.trim()) ?? 0.0,
      igi: double.tryParse(_igiController.text.trim()) ?? 0.0,
      referenciaCalidad: _referenciaCalidadController.text.trim(),
      referenciaColor: _referenciaColorController.text.trim(),
      gsm: double.tryParse(_gsmController.text.trim()) ?? 0.0,
      pesoXBulto: double.tryParse(_pesoXBultoController.text.trim()) ?? 0.0,
      descripcion: _descripcionController.text.trim(),
      foto: base64String,
      subFamiliaId: selectedFamiliaModel.subFamilia![index].iDSubFamilia,
      fraccionArancelaria: double.tryParse(_fraccionArancelariaController.text.trim()) ?? 0.0,
      estatus: int.tryParse(_estatusController.text.trim()) ?? 0,
    );
    MaterialesWSuppliers newMaterial = MaterialesWSuppliers(
      material: matSupp,
      proveedoresIDs: selectedProveedores.map((e) => e.idProveedor).toList(),
    );

     materialSupp.postMaterialWSuppliers(newMaterial);
    } on  SocketException catch (e) {
      print('Error al guardar el material: ${e.toString()}');
    }
  }



    Future<void> conditionalSave() async {
      if (_keey.currentState!.validate()) {
        // Verificación de Familia, SubFamilia y Proveedores
        if (selectedFamilia == "Seleccione una Familia" || selectedSubFamilia == "Seleccione una SubFamilia") {
          CustomAwesomeDialog(
            title: 'Familia/subFamilia no seleccionada',
            desc: 'Por favor seleccione una Familia/subFamilia para continuar',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          ).showQuestion(context);
          return;
        }
        if (selectedProveedores.isEmpty) {
          moveTab(1);
          MyCherryToast.showWarningSnackBar(
              context, theme, 'Seleccione al menos un Proveedor.'
          );
          return;
        }
        CustomAwesomeDialog(
          title: '¿Está seguro de guardar este material?',
          desc: '',
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            await _postMaterialSupplier();
            await _saveMaterial();
          },
        ).showQuestion(context);
      }
    }

    /// buttons



  moveTab(int index) async {
    tabMatController.index = index;
    if( index == 1||index==2 ){
      typeView = TypeProduct.single;
      setState(() {});
    }

  }

    void getFamilias() {
      print("getFamilias called");
      familia = widget.familia;
      print("widget.familia length: ${familia.length}");
      for (int i = 0; i < familia.length; i++) {
        print("Adding familia: ${familia[i].nombre}");
        listFamilias.add(familia[i].nombre);
      }
      setState(() {}); // Asegurarse de actualizar el estado después de poblar la lista
    }
    getMonedas(){
     moneda = widget.moneda;
      for( int i = 0; i < moneda.length; i++ ){
        monedaList.add(moneda[i].nombre);
      }
    }
    _disposeFocusNControllers(){
      _focusNode.dispose();
      _focusNode2.dispose();
      _focusNode3.dispose();
      _focusNode4.dispose();
      _focusNode5.dispose();
      _focusNode6.dispose();
      _focusNode7.dispose();
      _focusNode8.dispose();
      _focusNode9.dispose();
      _focusNode10.dispose();


      _idMaterialController.dispose();
      _categoriaController.dispose();
      _codigoProductoController.dispose();
      _unidadMedidaCompraController.dispose();
      _unidadMedidaVentaController.dispose();
      _composicionController.dispose();
      _espesorMMController.dispose();
      _anchoController.dispose();
      _largoController.dispose();
      _metrosXRolloController.dispose();
      _costoController.dispose();
      _precioVentaController.dispose();
      _igiController.dispose();
      _referenciaCalidadController.dispose();
      _referenciaColorController.dispose();
      _gsmController.dispose();
      _pesoXBultoController.dispose();
      _descripcionController.dispose();
      _fotoController.dispose();
      _subFamiliaIDController.dispose();
      _fraccionArancelariaController.dispose();
      _estatusController.dispose();
      _subFamiliaNombreController.dispose();
      _familiaNombreController.dispose();

    }

    List<Widget >_sat(){
     return [
       _headerContainer("CLAVES CATÁLOGO CFDI"),
       _dividedFormRow(
           MyAutocomplete(
              textController: _satController,
               labelText: "Clave SAT",
               textStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary),
               dropdownItems: satList,
               colorLine: theme.colorScheme.background,
               suffixIcon: Icon(Icons.numbers_rounded ,
                 color: theme.colorScheme.onPrimary,),
               onValueChanged: handledAutoCompleteSat,
               onValueChange: handledAutoCompleteSat,
              keyboardType: TextInputType.number,
              inputFormatters: [ FilteringTextInputFormatter.digitsOnly],
           ),
         Container(
           width: size.width * 0.40,
           height: size.width * 0.035,
           padding: const EdgeInsets.all(15),
           decoration: BoxDecoration(
             border: Border.all(color: theme.colorScheme.onPrimary),
             borderRadius: BorderRadius.circular(5),
           ),
           child:
           Stack(
             children: [
               AnimatedPositioned(
                 duration: const Duration(milliseconds: 200),
                 left: claveUnidadMedida != null ? 0 : 95, // Ajusta esta distancia para mover el texto.
                 top: 0,
                 child: Text(
                   claveUnidadMedida ?? 'Clave unidad',
                   style: TextStyle(
                     fontSize: 14,
                     color: theme.colorScheme.onPrimary,
                   ),
                 ),
               ),
               if (claveUnidadMedida != null )
                 Positioned(
                   right: 0,
                   child: Text(
                     'Clave unidad',
                     style: TextStyle(
                       fontSize: 14,
                       color: theme.colorScheme.onPrimary.withOpacity(0.5),
                     ),
                   ),
                 ),
             ],
           )
         ),
       ),
     ];
    }

    void handledAutoCompleteSat (String? value){
        if( value == null|| value.isEmpty ){
          claveUnidadMedida = null;
        } else {
          selectedSatPass = value;
        }
        print(selectedSatPass);
     setState(() {});
      getSatvalues();
    }
    Future<void>initSATData()async{
      try{
        List< ClaveSATModels > claveSAT = await claveSATController.GetClavesSat();
        setState(() {
          satList = claveSAT.map((e) => e.clavePs.toString()).toList();
          Future.delayed(const Duration(milliseconds: 100));
        });
      } catch(e){
        print("object");
      }
    }

    Future<void> getSatvalues() async {
      try{
        List< ClaveSATModels > claveSAT2 = await claveSATController.GetClavesSat();
        if( selectedSatPass != null ){
          int? selectedValieClavePS = int.tryParse(selectedSatPass);
          ClaveSATModels? registroSeleccionado = claveSAT2.firstWhere(
                  (claveSat) => claveSat.clavePs == selectedValieClavePS,
              orElse: () => ClaveSATModels(
                  idClaveSat: "IDSat No encontrado",
                  descripcion: "No encontrado",
                  clavePs: 0,
                  claveUnidadMedida:"CL no encontrado"
              ));
        if( registroSeleccionado.idClaveSat != "IDSat No encontrado" ){
          iDClaveS = registroSeleccionado.idClaveSat;
          setState(() {
            claveUnidadMedida = registroSeleccionado.claveUnidadMedida;
          });
          } else {
          print("registro no encontrado");
        }
        }
      } catch (e){
        print(e);
      }
    }
    initTimer(){
      const timeLimit = Duration(milliseconds: 2500);
      timer = Timer(timeLimit, () {
        if (_familiaList.isEmpty) {
          setState(() {
            _isLoading = false;
          });
        } else {
          _isLoading = false;
        }
      });
    }

    initControllerAnimation(){
     _satController.addListener(() {
       setState(() {
         if(_satController.text.trim().isEmpty){
           claveUnidadMedida = null;
         } else {
           claveUnidadMedida = _satController.text;
         }
       });
     });
    }


    Widget _colorsCard(ColorFeature color1, index){
      return MySwipeTileCard(
        key: ValueKey<ColorFeature>(colorFeatureList[index]),
          colorBasico: theme.colorScheme.background,
          containerB: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row( children: [
              const SizedBox(width: 5,),
              SizedBox(child: Text(color1.color)),
              const Spacer(),
              SizedBox(child: Text(color1.etiqueta)),
              const Spacer(),
              SizedBox(child: Text(color1.descripcion)),
              const SizedBox(width: 50,),
            ], ),
          ),
          onTapLR: (){

          },
          onTapRL: (){}
      );

    }
    Widget _sizeCard(SizeFeature size, index){
      return MySwipeTileCard(
        key: ValueKey<SizeFeature>(sizeFeatureList[index]),
          colorBasico: theme.colorScheme.background,
          containerB: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row( children: [
              const SizedBox(width: 10,),
              SizedBox(child: Text(size.size)),
              const Spacer(),
              SizedBox(child: Text(size.nomenclatura)),
              const Spacer(),
              const SizedBox(width: 100,),
            ], ),
          ),
          onTapLR: (){
            setState(() {
              sizeFeatureList.removeAt(index);
            });
          },
          onTapRL: (){
          }
      );
    }
    Widget _sizeNColorCard(NewMaterial nM, index){
      return MySwipeTileCard(
        key: ValueKey<NewMaterial>(colorSizeFeatureList[index]),
          colorBasico: theme.colorScheme.background,
          containerB: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row( children: [
              const SizedBox(width: 10),
              SizedBox(child: _columnW(
                  Text("color: ", style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14 ),),
                  Text( nM.color, style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14 ),),
                  Text("Talla: ", style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14 )),
                  Text( nM.talla, style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14 ),),
              )),
              const Spacer(),
              SizedBox(child: _columnW(
                Text("color: ",textAlign: TextAlign.start, style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14, )),
                Text( nM.referenciaColor, textAlign: TextAlign.start,style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14),),
                Text("Talla: ",textAlign: TextAlign.start, style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14,)),
                Text( nM.referenceSize,textAlign: TextAlign.start, style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14 ),),
              )),
              // const SizedBox(width: 60,),
              const Spacer(),
              const SizedBox(child: Text( "referencia")),
              const SizedBox(width: 100,),
              // SizedBox(child: Text( nM.referenciaOrigenColor)),
            ], ),
          ),
          onTapLR: (){},
          onTapRL: (){}
      );
    }

    Widget _corridasCard(Combination obj, index){
      return MySwipeTileCard(
        colorBasico: theme.colorScheme.background,
          containerB: Row(
            children: [
              SizedBox(width: size.width*.10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Talla: ", style: TextStyle( color: theme.colorScheme.onPrimary, fontSize: 14 ),),
                    Text(obj.talla.toString(), style: TextStyle( color: theme.colorScheme.onPrimary ),),

                  ],
                ),
              ),
            ],
          ),
          onTapLR: (){},
          onTapRL: (){}
      );
    }

    void debounce( VoidCallback callback, int milliseconds ){
      Timer.periodic(Duration( milliseconds: milliseconds ), (timer) {
        timer.cancel();
        callback();
      });
    }

    listFeatureItem(){
      if(feature == ProductFeature.color){
        return colorFeatureList.length;
      }else if(feature == ProductFeature.size){
        return sizeFeatureList.length;
      }else if(feature == ProductFeature.sizeNColor){
        if( _corridasList.isNotEmpty ){
          return _corridasList.length;
        } else {
        return colorSizeFeatureList.length;
        }
      }
    }
}
