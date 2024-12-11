import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/GeneralSettingsController/listaPrecioController.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/listaPrecio.dart';
import 'package:tickets/pages/Settings/GeneralSettings/widgets_settings.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/utils/color_palette.dart';
import '../../../shared/utils/icon_library.dart';
import '../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../shared/widgets/error/customNoData.dart';
import '../../../shared/widgets/textfields/my_textfield_icon.dart';

class SalesSettingsScreen extends StatefulWidget {
  ThemeData theme; Size size;
  SalesSettingsScreen({super.key, required this.theme, required this.size});

  @override
  _SalesSettingsScreenState createState() => _SalesSettingsScreenState();
}
class _SalesSettingsScreenState extends State<SalesSettingsScreen> with TickerProviderStateMixin{
  late ThemeData theme; late Size size;
  bool _isLoading = true;
  List<ListaPrecio> listaPrecio = [];
  ScrollController controllerPrecios = ScrollController();
  TextEditingController nombrePriceController = TextEditingController(),
      descPriceController = TextEditingController(), porcentajePriceController = TextEditingController(),
      montoPriceController = TextEditingController();
  late WidgetsSettings ws;
  ListaPrecioController listaPrecioController = ListaPrecioController();
  bool valuePorcentaje = false;
  Map<String, AnimationController> _animationControllers = {};
  final List<Map<String, dynamic>>paymentOptions=[
    {"option": "Porcentaje", "value": false},
    {"option": "Monto", "value": false},
    {"option": "Captura manual", "value": false},
  ];
  bool listaBase = false;
  @override
  void initState() {
    super.initState();
    size = widget.size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getListaPrecios();
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    ws = WidgetsSettings(theme);

    return ventasForm();
  }

  Widget ventasForm(){
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3,child: myContainer2("    Lista de precios",listaPrecios(),null,
                  Tooltip(message: Texts.gsPriceAdd, waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(onTap: (){
                        preciosDialog();
                      },
                        child: Container(
                          decoration: BoxDecoration(color: theme.colorScheme.secondary,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),),
                          padding: const EdgeInsets.all(10.0),
                          child: const Icon(IconLibrary.iconAdd, size: 20,),
                        ),))),),
              const Expanded(flex: 3,child: SizedBox())
            ],
          ),
          const SizedBox(height: 10,),
        ],),));
  }
  Widget listaPrecios(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SizedBox(height: 5,),
      Container(height: 160,decoration: BoxDecoration(color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(5)),),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,children: [
            SizedBox(height: 158,child: futureListPrecios(),)
          ],),
      )
    ],);
  }
  Widget futureListPrecios(){
    return FutureBuilder<List<ListaPrecio>>(future: getDatosPrecios(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: _buildLoadingIndicator(10));
          } else {
            final listSnapshot = snapshot.data ?? [];
            if (listSnapshot.isNotEmpty) {
              return Scrollbar(controller: controllerPrecios, thumbVisibility: true,
                child: RefreshIndicator(onRefresh: () async {getListaPrecios();},
                    child: FadingEdgeScrollView.fromScrollView(
                  gradientFractionOnEnd: 0.2,gradientFractionOnStart: 0.2,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controllerPrecios, itemCount: listSnapshot.length,
                    itemBuilder: (context, index) {
                      return cardScaleListPrecio(listSnapshot[index]);
                    },
                  ),
                )));
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
        });
  }

  Widget cardPrecio(ListaPrecio listPrecio){
    return Tooltip(message: 'Descripción:\n${listPrecio.descripcion}', waitDuration: const Duration(milliseconds: 200),
      child: MySwipeTileCard(horizontalPadding: 3, verticalPadding: 2, radius: 4, colorBasico: theme.colorScheme.background,
        containerRL: true == true? null: Row(children: [Icon(IconLibrary.iconDone, color: theme.colorScheme.onPrimary,)],),
        colorRL: true == true? null : ColorPalette.ok,
        containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 10,
            vertical: 2),child: Row(children: [
          Expanded(child: Wrap(alignment: WrapAlignment.spaceBetween,spacing: 5,runSpacing: 2,children: [
            ws.filaEspecial("Nombre", listPrecio.precio!, textOverflow: null, width: 125),
            ws.filaEspecial("Descripción", listPrecio.descripcion!, width: 255),
            ws.filaEspecial("Estatus", listPrecio.estatus != null? (listPrecio.estatus==true? "Activo" : "Inactivo") : "Inactivo", width: 100,
                color: listPrecio.estatus == true? ColorPalette.ok : ColorPalette.err),
          ],),),
        ],),),
        onTapLR: (){
          CustomAwesomeDialog(title: Texts.gsPriceWannaEdit,
            desc: 'Lista de precio: ${listPrecio.precio}', btnOkOnPress: () async {
              nombrePriceController.text = listPrecio.precio!;
              descPriceController.text = listPrecio.descripcion!;
              porcentajePriceController.text = listPrecio.porcentajeValue.toString();
              montoPriceController.text = listPrecio.montoValue.toString();
              paymentOptions[0]["value"] = listPrecio.porcentaje;
              paymentOptions[1]["value"] = listPrecio.monto;
              paymentOptions[2]["value"] = listPrecio.capturaManual;
              listaBase = listPrecio.listaBase;
              editDialog(listPrecio);
            }, btnCancelOnPress: () {  },).showQuestion(context);

        }, onTapRL: (){
            if(listPrecio.listaBase == false) {
              CustomAwesomeDialog(title: '¿Desea ${(listPrecio.estatus!? "desactivar" : "activar")} la lista de precio?',
                desc: 'Lista de precio: ${listPrecio.precio}',
                btnOkOnPress: () async {deleteDialog(listPrecio);}, btnCancelOnPress:(){},).showWarning(context);
            }else{
              MyCherryToast.showWarningSnackBar(context, theme, "No es posible dar de baja la lista base");
            }
        }
    ));
  }
  void editDialog(ListaPrecio listPrecio){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsPriceEdit, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: bodyDialogEditPrice(listPrecio, context1, setState1),
                        ))
                ));
              }
          );
        });
  }
  Widget bodyDialogEditPrice(ListaPrecio listPrecio, BuildContext context1, StateSetter setState1){
    return Column(mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(children: [
          textFieldPreciosNombre(listPrecio.precio),
          const SizedBox(width: 5,),
          textFieldPreciosDescripcion(),
        ]),
        const SizedBox(height: 10,),
        !listaBase? switchButtonAddPrice(setState1) : const SizedBox(),
        Row(children: [
          paymentOptions[0]["value"] && !listaBase? textFieldPorcentaje(null) : const SizedBox(width: 130,),
          const SizedBox(width: 10),
          paymentOptions[1]["value"] && !listaBase? textFieldMonto(null) : const SizedBox(),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.end,children: [
          ws.buttonCancelar((){
            Navigator.of(context1).pop(); cleanAddPriceDialog();
          }),
          const SizedBox(width: 10),
          ws.buttonAceptar(() async {
            if(nombrePriceController.text.isNotEmpty){
              LoadingDialog.showLoadingDialog(context1, Texts.gsPriceEditLoading);
              ListaPrecio listaPrecio1 = await getListPrice();
              listaPrecio1.idListaPrecio = listPrecio.idListaPrecio;
              String userId = await UserPreferences().getUsuarioID();
              ListaPrecio? precio = await listaPrecioController.updateListaPrecio(listaPrecio1, userId);
              if(precio != null){
                CustomAwesomeDialog(title: Texts.gsPriceEditSuccess, desc: '',
                  btnOkOnPress:(){}, btnCancelOnPress:(){},).showSuccess(context);
                Future.delayed(const Duration(milliseconds: 2500), () async {
                  Navigator.of(context1).pop();
                  LoadingDialog.hideLoadingDialog(context);
                  await setListPrice(listPrecio);
                  setState(() {});
                  cleanAddPriceDialog();
                });
              }
            }else{CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);}
          })
        ],)
      ],
    );
  }
  Future<void> deleteDialog(ListaPrecio listPrecio) async {
    LoadingDialog.showLoadingDialog(context, '${(listPrecio.estatus!? "Desactivando" : "Activando")} precio...');
    String userId = await UserPreferences().getUsuarioID();
    bool result = await listaPrecioController.changeStatusListaPrecio(listPrecio.idListaPrecio, !listPrecio.estatus!, userId);
    if(result){
      CustomAwesomeDialog(title: 'Precio ${(listPrecio.estatus!? "desactivado" : "activado")} exitosamente', desc: '',
        btnOkOnPress:(){}, btnCancelOnPress:(){},).showSuccess(context);
      Future.delayed(const Duration(milliseconds: 2500), () {
        LoadingDialog.hideLoadingDialog(context);
        listPrecio.estatus = !listPrecio.estatus!;
        setState(() {});
      });
    }else{
      CustomAwesomeDialog(title: 'Error al ${(listPrecio.estatus!? "desactivar" : "activar")} precio', desc: '',
        btnOkOnPress:(){LoadingDialog.hideLoadingDialog(context);},
        btnCancelOnPress:(){},).showError(context);
    }
  }
  Widget _buildLoadingIndicator(int n) {
    List<Widget> cardList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max,
            children: cardList)
    );
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 35,child: Card(
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),),
        color: theme.colorScheme.background, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Shimmer.fromColors(
            baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(7),),
            ),
          ),
        )
    ),);
  }

  Widget myContainer2(String title,Widget child, double? width, Widget widget){
    return Container(width: width,decoration: BoxDecoration(color: theme.primaryColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[
          customTitleDivider(title, theme),
          widget
        ]),
        const SizedBox(height: 10,),
        child
      ],),);
  }
  Widget customTitleDivider(String title, ThemeData theme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          maxLines: 1, textDirection: TextDirection.ltr,
        )..layout(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final textWidth = textPainter.width;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(" $title", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary)),
            Container(width: textWidth*1.2,height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.secondary,borderRadius: BorderRadius.circular(10)),),
          ],
        );
      },
    );
  }
  Future<List<ListaPrecio>> getDatosPrecios() async {
    try {
      return listaPrecio;
    } catch (e) {
      print('Error al obtener monedas: $e');
      return [];
    }
  }
  void preciosDialog(){
    showDialog(context: context, barrierDismissible: false,
        builder:(BuildContext context1){
          return StatefulBuilder(
              builder: (BuildContext context1, StateSetter setState1) {
                return ScaffoldMessenger(child: Builder(
                    builder: (context1) => Scaffold(
                        backgroundColor: Colors.transparent,
                        body: AlertDialog(
                          title: Text(Texts.gsPriceAdd, style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                          content: bodyDialogAddPrice(context1, setState1),
                        ))
                ));
              }
          );
        });
  }
  Widget bodyDialogAddPrice(BuildContext context1, StateSetter setState1){
    return Column(mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(children: [
          textFieldPreciosNombre(null),
          const SizedBox(width: 5),
          textFieldPreciosDescripcion(),
        ]),
        const SizedBox(height: 10,),
        !listaBase? switchButtonAddPrice(setState1) : const SizedBox(),
        Row(children: [
          paymentOptions[0]["value"] && !listaBase? textFieldPorcentaje(null) : const SizedBox(width: 130,),
          const SizedBox(width: 10),
          paymentOptions[1]["value"] && !listaBase? textFieldMonto(null) : const SizedBox(),
        ],),
        const SizedBox(height: 10,),
        buttonsAgregarPrecio(context1)
      ],
    );
  }
  Widget buttonsAgregarPrecio(BuildContext context1){
    return Row(mainAxisAlignment: MainAxisAlignment.end,children: [
      ws.buttonCancelar((){
        Navigator.of(context1).pop(); cleanAddPriceDialog();
      }),
      const SizedBox(width: 10,),
      ws.buttonAceptar(() async {
        if(nombrePriceController.text.isNotEmpty){
          LoadingDialog.showLoadingDialog(context1, Texts.gsPriceAddLoading);
          UserPreferences user = UserPreferences();
          String userId = await user.getUsuarioID();
          ListaPrecio? listPrecio = await listaPrecioController.saveListaPrecio(await getListPrice(), userId);
          if(listPrecio != null){
            CustomAwesomeDialog(title: Texts.gsPriceAddSuccess, desc: '',
              btnOkOnPress:(){}, btnCancelOnPress:(){},).showSuccess(context);
            Future.delayed(const Duration(milliseconds: 2500), () {
              Navigator.of(context1).pop();
              LoadingDialog.hideLoadingDialog(context);
              listaPrecio.add(listPrecio);
              cleanAddPriceDialog();
              _triggerCardAnimationUnidad(listPrecio);
              setState(() {});
              Future.delayed(const Duration(milliseconds: 800), () {
                if (controllerPrecios.hasClients) {
                  final position = controllerPrecios.position.maxScrollExtent;
                  controllerPrecios.animateTo(
                    position, duration: const Duration(seconds: 1), curve: Curves.easeOut,
                  );
                }
              });
            });
          }
        }else{
          CustomSnackBar.showWarningSnackBar(context1, Texts.completeField);
        }
      })
    ],);
  }
  void cleanAddPriceDialog(){
    nombrePriceController.text = ''; descPriceController.text = '';
    porcentajePriceController.text = ''; montoPriceController.text = ''; listaBase = false;
    for (var option in paymentOptions){ option["value"] = false;}
  }
  Future<ListaPrecio> getListPrice() async {
    return ListaPrecio(idListaPrecio: '', precio: nombrePriceController.text, descripcion: descPriceController.text,
        porcentaje: !listaBase? paymentOptions[0]["value"] : false,
        porcentajeValue: paymentOptions[0]["value"] && !listaBase? double.parse(porcentajePriceController.text) : 0,
        monto: !listaBase? paymentOptions[1]["value"] : false,
        montoValue: paymentOptions[1]["value"] && !listaBase? double.parse(montoPriceController.text) : 0,
        capturaManual: !listaBase? paymentOptions[2]["value"] : false,
        listaBase: listaBase
    );
  }
  Future<void> setListPrice(ListaPrecio listPrecio) async {
    listPrecio.precio = nombrePriceController.text;
    listPrecio.descripcion = descPriceController.text;
    listPrecio.listaBase = listaBase;
    if(listaBase){
      for (var otherList in listaPrecio){
        if(otherList != listPrecio){
          otherList.listaBase = false;
        }
      }
      listPrecio.porcentaje = false;
      listPrecio.porcentajeValue = 0;
      listPrecio.monto = false;
      listPrecio.montoValue = 0;
      listPrecio.capturaManual = false;
    }else{
      listPrecio.porcentaje = paymentOptions[0]["value"];
      listPrecio.porcentajeValue = paymentOptions[0]["value"]? double.parse(porcentajePriceController.text) : 0;
      listPrecio.monto = paymentOptions[1]["value"];
      listPrecio.montoValue = paymentOptions[1]["value"]? double.parse(montoPriceController.text) : 0;
      listPrecio.capturaManual = paymentOptions[2]["value"];
    }
  }
  Widget switchButtonAddPrice(StateSetter setState1){
    return Row(children: paymentOptions.map((option) {
      return Container(margin: const EdgeInsets.symmetric(vertical: 5.0), padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Text(option["option"]),
          Transform.scale(scale: 0.8, child: Switch(value: option["value"], onChanged: (bool newValue) {
            setState1(() { option["value"] = newValue;
            if (newValue){ for (var otherOption in paymentOptions){
              if (otherOption != option){ otherOption["value"] = false;}}}
            });
          }, activeColor: Colors.green, inactiveThumbColor: Colors.red,),),
        ],),);
    }).toList());
  }
  Widget textFieldPreciosNombre(String? exception){
    return ws.boxWithTextField('Nombre', nombrePriceController, IconLibrary.iconMoney,
        validator: (String? value){
          if(value == null || value.isEmpty){
            return Texts.completeField;
          }else if(exception != null && value == exception){
            return null;
          }else if(listaPrecio.any((element) => element.precio == value)){
            return Texts.gsPriceAlreadyExists;
          }else if(value.length > 20){
            return 'El nombre no puede tener más\n de 20 caracteres';
          }
          return null;
        });
  }

  Widget textFieldPorcentaje(String? exception){
    return ws.boxWithTextField('Porcentaje', porcentajePriceController, IconLibrary.iconPercentage,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}'))],
        validator: (String? value){
          if(value == null || value.isEmpty){
            return "Por favor completa \neste campo";
          }else{
            return null;
          }
        }, width: 130);
  }
  Widget textFieldMonto(String? exception){
    return ws.boxWithTextField('Monto', montoPriceController, IconLibrary.iconMoney,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}'))],
        validator: (String? value){
          if(value == null || value.isEmpty){
            return "Por favor completa \neste campo";
          }else{
            return null;
          }
        }, width: 110);
  }
  Widget cardScaleListPrecio(ListaPrecio listPrecio){
    final controller = _animationControllers[listPrecio.idListaPrecio];
    final scaleAnimation = controller != null ? Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)) : const AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: scaleAnimation.value, child: cardPrecio(listPrecio));
        });
  }
  Widget textFieldPreciosDescripcion(){
    return ws.boxWithTextField('Descripción', descPriceController, IconLibrary.iconMoney,
        validator: (String? value){
          if(value == null || value.isEmpty){
            return null;
          }else if(value.length > 50){
            return 'La descripción no puede tener\n más de 50 caracteres';
          }
          return null;
        },);
  }
  Widget boxWithTextField(String title, TextEditingController controller, IconData icon, {bool enable = true,
    String? Function(String?)? validator}){
    return SizedBox(width: 200,child: MyTextfieldIcon(
        errorStyle: const TextStyle(fontSize: 10.5, color: ColorPalette.err),
        backgroundColor: theme.colorScheme.background, labelText: title, enabled: enable,
        labelStyle: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
        floatingLabelStyle: TextStyle( fontWeight: FontWeight.bold,color: theme.colorScheme.onPrimary),
        textController: controller, suffixIcon: Icon(icon),validator: validator??(value){
      if(value == null || value.isEmpty){
        return Texts.completeField;
      }
      return null;
    }
    ));
  }
  Future<void> getListaPrecios() async {
    try {
      List<ListaPrecio> listPrecio = await listaPrecioController.getListaPrecio();
      if(listPrecio.isNotEmpty){
        listaPrecio = listPrecio;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener lista de precios: $e');
    }
  }
  void _triggerCardAnimationUnidad(ListaPrecio listaPrecio) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Guardar el controlador de la animación
    _animationControllers[listaPrecio.idListaPrecio] = controller;
    // Iniciar la animación
    Future.delayed(const Duration(milliseconds: 1600), () {
      controller.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.reverse();
      });
    });
  }
}
