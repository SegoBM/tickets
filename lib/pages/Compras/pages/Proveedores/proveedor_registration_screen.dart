import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ComprasController/DatosBancariosController/DatosBancariosController.dart';
import 'package:tickets/pages/Compras/pages/Proveedores/bank_details_modal.dart';
import 'package:tickets/pages/Compras/pages/Proveedores/proveedor_origin_check.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import '../../../../models/ComprasModels/DatosBancariosModels/datosBancarios.dart';
import '../../../../models/ConfigModels/GeneralSettingsModels/monedas.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';
import 'Accounting _Account.dart';

class ProveedorRegistrationScreen extends StatefulWidget {
  static String id = 'proveedorRegistration';
  List<MonedaModels> monedas;
  ProveedorRegistrationScreen({super.key, required this.monedas});

  @override
  _ProveedorRegistrationScreenState createState() => _ProveedorRegistrationScreenState();
}

class _ProveedorRegistrationScreenState extends State<ProveedorRegistrationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Size size;
  late ThemeData theme;
  bool editDatosBancariosP = true, servicio = false, fabricante = false, distribuidor = false, local = false, extranjero = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final GlobalKey _pressedGlobalKey = GlobalKey();
  final  _scrollController = ScrollController();
  final List<Map<String, String>> _datosBancariosList =[];
  final TextEditingController _nombreController = TextEditingController(), _razonSocialController = TextEditingController(),
      _rfcController = TextEditingController(), _correoElectronicoController = TextEditingController(), _telefonoController = TextEditingController(),
      _descripcionController = TextEditingController(), _coloniaController = TextEditingController(), _calleController = TextEditingController(),
      _numExtController = TextEditingController(), _numIntController = TextEditingController(), _codigoPostalController = TextEditingController(),
      _ciudadController = TextEditingController(), _estadoController = TextEditingController(), _paisController = TextEditingController(),
      bancoController = TextEditingController(), clabeController = TextEditingController(), tipoCuentaController = TextEditingController(),
      bancoIntController = TextEditingController(), clabeIntController = TextEditingController(), tipoCuentaIntController = TextEditingController(),
      curpController = TextEditingController(), sucursalfiscalController = TextEditingController(), callefiscalController = TextEditingController(),
      coloniafiscalController = TextEditingController(), numExtfiscalController = TextEditingController(), numIntfiscalController = TextEditingController(),
      codigoPostalfiscalController = TextEditingController(), ciudadfiscalController = TextEditingController(), estadofiscalController = TextEditingController(),
      paisfiscalController = TextEditingController(), nombreTitularController = TextEditingController();
  ScrollController datosPagoScrollController = ScrollController();
  final List<Map<String, dynamic>>paymentOptions=[
    {"option": "Crédito", "value": false},
    {"option": "Contado", "value": false}];
  List<DatosBancariosController> listDatosBancarios = [];
  List<MonedaModels> listMonedas = [];
  List<String> listMonedasString = [], tipoCuenta = ["Débito", "Crédito","SPEI"], metodosPago = ["Transferencia", "Cheque", "Efectivo"];
  String selectedMoneda = "", selectedMetodoPago = "Transferencia", selectedTipoCuenta = "Débito";

  @override
  void initState() {
    getMoneda();
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void clearControllers(){
    bancoController.clear();
    clabeController.clear();
    nombreTitularController.clear();
    tipoCuentaController.clear();
    selectedMoneda = listMonedasString.first;
    selectedMetodoPago = "Transferencia";
    bancoIntController.clear();
    clabeIntController.clear();
    tipoCuentaIntController.clear();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return WillPopScope(child: PressedKeyListener(
      Gkey: _pressedGlobalKey, keyActions: {
      LogicalKeyboardKey.escape: () {
        CustomAwesomeDialog(title: "Saldras de la pantalla", desc: Texts.lostData, btnOkOnPress: () {
          Navigator.of(context).pop();
        },
            btnCancelOnPress:() {}).showQuestion(context);
      },
    },
      child: Scaffold(
        backgroundColor: theme.backgroundColor, appBar: size.width > 600 ?
      MyCustomAppBarDesktop(title: "Alta de proveedores", suffixWidget:
      Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
        child:ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text("Guardar", style: TextStyle(color: theme.colorScheme.onPrimary),),
              Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary,)],),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
            } else {
              CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
            }},),),
          context: context, backButton: true, defaultButtons: false, borderRadius: const BorderRadius.all(Radius.circular(25))) : null,
        body: Column(
          children: [TabBar(controller: _tabController, labelColor: theme.colorScheme.onPrimary, unselectedLabelColor: Colors.grey[400],
            labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), indicatorWeight: 5, padding: EdgeInsets.symmetric(horizontal: size.width*.15),
            tabs: const [Tab(text: "Datos del Proveedor"), Tab(text: "Datos Fiscales"), Tab(text: "Datos Adicionales",)],),
            Expanded(
              child: TabBarView(controller: _tabController,
                children: [_datosProveedorTab(), _datosFiscalesTab(), _datosAdicionalesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
      onWillPop: () async { bool salir = false;
      CustomAwesomeDialog(title: Texts.alertExit, desc: Texts.lostData,
        btnOkOnPress:() { salir = true;},
        btnCancelOnPress:() { salir = false;},
      ).showQuestion(context);
      return salir;},);}

  Widget _datosProveedorTab(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _landscapeBody(),
    );
  }

  Widget _datosAdicionalesTab(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _landscapeBody2(),
    );
  }

  Widget _datosFiscalesTab(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _landscapeBody3(),
    );
  }

  Widget _myContainer(String text){
    return Container(width: size.width/3,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),padding: const EdgeInsets.all(5.0),
      child: Center(child: Column(children: [
        Text(text, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,),),
        Divider(thickness: 2,color: theme.colorScheme.secondary,)],)
      ),
    );
  }

  Widget _myContainerCuenta(String text){
    return Container(width: size.width/3,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),padding: const EdgeInsets.all(5.0),
      child: Center(child: Column(children: [
        Text(text, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,),),
        Divider(thickness: 2,color: theme.colorScheme.secondary,)],)
      ),
    );
  }

  Widget _landscapeBody() {
    return Form(key: _formKey,
      child: Scrollbar(controller: _scrollController, child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(controller: _scrollController, child: Column(
          children: <Widget>[
            _myContainer("DATOS DEL PROVEEDOR"),
            _rowDivided(
              MyTextfieldIcon(toUpperCase: true, backgroundColor: theme.colorScheme.background, labelText: "Nombre", textController: _nombreController, suffixIcon: const Icon(IconLibrary.iconBusiness,),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';} return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Razón social",toUpperCase: true, textController: _razonSocialController, suffixIcon: const Icon(IconLibrary.iconBusiness2),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';} return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "RFC", toUpperCase: true, textController: _rfcController, suffixIcon: const Icon(IconLibrary.iconBusiness2),
                  validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';} else if (value.length != 12 && value.length != 13) {
                      return 'Ingrese un RFC válido ${value.length}/12(P.Moral) o 13(P.Física)';} return null;}),),
            const SizedBox(height: 5,),
            _rowDivided(
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Correo Electrónico", textController: _correoElectronicoController, suffixIcon: const Icon(IconLibrary.iconEmail),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';} return null;},),
              MyTextfieldIcon(formatting: false, backgroundColor: theme.colorScheme.background, labelText: "Teléfono", textController: _telefonoController, suffixIcon: const Icon(IconLibrary.iconPhone,),
                validator: (value) { Pattern pattern = r'^\d{10}$';RegExp regex = RegExp(pattern as String);
                  if (value == null || value.isEmpty) { return null; } else if (!regex.hasMatch(value)) {return 'Por favor ingresa un número de teléfono válido';}return null;
                },),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Descripción", textController: _descripcionController, suffixIcon: const Icon(IconLibrary.iconDescription),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';}return null;},),),
            const  SizedBox(height: 5), _myContainer("DIRECCIÓN"),
            _rowDivided(
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Colonia", textController: _coloniaController, suffixIcon: const Icon(IconLibrary.iconLocation,),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';}return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Calle", textController: _calleController, suffixIcon: const Icon(IconLibrary.iconLocation),
                validator: (value) { if (value == null || value.isEmpty) { return 'Por favor completa este campo';}return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Número interior", textController: _numIntController, suffixIcon: const Icon(IconLibrary.iconNumber),
                validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';}return null;},),),
            const SizedBox(height: 5,),
            _rowDivided(
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Número exterior", textController: _numExtController, suffixIcon: const Icon(IconLibrary.iconNumber),
                validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';}return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Código postal", textController: _codigoPostalController, suffixIcon: const Icon(IconLibrary.iconLocation),
                  validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';} else if (value.length != 5 || double.tryParse(value) == null) {
                      return 'Ingrese un codigo postal valido (${value.length}/5)';}return null;}),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Ciudad", textController: _ciudadController, suffixIcon: const Icon(IconLibrary.iconMap),
                validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';}return null;},),),
            const SizedBox(height: 5,),
            _rowDividedTwo(
              MyTextfieldIcon(formatting: false, backgroundColor: theme.colorScheme.background, labelText: "Estado", textController: _estadoController, suffixIcon: const Icon(IconLibrary.iconMap,),
                validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';}return null;},),
              MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "País", textController: _paisController, suffixIcon: const Icon(IconLibrary.iconMap),
                  validator: (value) {if (value == null || value.isEmpty) {return 'Por favor completa este campo';}return null;}),),
            _myContainer('DATOS DE PAGO'), _bancoWidget (),],
        ),),
      ),),
    );}

  Widget _landscapeBody2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(key: _formKey2, child: Scrollbar(controller: _scrollController, child: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(controller: _scrollController, child: Column(children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(children: [
            _myContainer("DATOS DEL PROVEEDOR"), Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [Flexible(child: SizedBox(width: size.width * 0.2,
                child: MyTextfieldIcon(toUpperCase: true, backgroundColor: theme.colorScheme.background, labelText: "CURP", textController: curpController, suffixIcon: const Icon(IconLibrary.iconBusiness),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor completa este campo';
                    }
                    return null;
                  },),),),
                const SizedBox(width: 10),
                Flexible(child: SizedBox(width: size.width * 0.2, child:
                MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Sucursal", textController: sucursalfiscalController, suffixIcon: const Icon(IconLibrary.iconMap), validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor completa este campo';
                  }
                  return null;
                },),),),],),],),),
            Expanded(child: Column(children: [
              _myContainer("FORMAS DE PAGO"),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: paymentOptions.map((option) {
                return Container(margin: const EdgeInsets.symmetric(vertical: 5.0), padding: const EdgeInsets.all(8.0), decoration: BoxDecoration(color: theme.colorScheme.background, borderRadius: BorderRadius.circular(10),),
                  child: Row(children: [Text(option["option"]), Transform.scale(scale: 0.8, child: Switch(value: option["value"], onChanged: (bool newValue) {
                    setState(() { option["value"] = newValue;
                    if (newValue){ for (var otherOption in paymentOptions){
                      if (otherOption != option){ otherOption["value"] = false;}}}
                    });
                  },
                    activeColor: Colors.green, inactiveThumbColor: Colors.red,),),],),);
              }).toList(),),
              if (paymentOptions[0]["value"])
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Flexible(child: SizedBox(width: size.width * 0.2, child :
                  MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Días de Crédito", textController: TextEditingController(), suffixIcon: const Icon(IconLibrary.iconNumber),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor completa este campo';}
                      return null;
                    },),),),
                  Flexible(child: SizedBox(width: size.width * 0.2, child :
                  MyTextfieldIcon(backgroundColor: theme.colorScheme.background, labelText: "Límite de Crédito", textController: TextEditingController(), suffixIcon: const Icon(IconLibrary.iconMoney), validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor completa este campo';}
                    return null;},),
                  ),),
                ],),
            ],),)
          ],),
        ],),),
      ),),),
    );
  }
  Widget _landscapeBody3() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey3,
        child: Scrollbar(
          controller: _scrollController,
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  _myContainer("DOMICILIO FISCAL"),
                  _rowDivided(
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Calle",
                      textController: callefiscalController,
                      suffixIcon: const Icon(IconLibrary.iconLocation),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Número exterior",
                      textController: numExtfiscalController,
                      suffixIcon: const Icon(IconLibrary.iconNumber),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Número interior",
                      textController: numExtfiscalController,
                      suffixIcon: const Icon(IconLibrary.iconNumber),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

                  _rowDivided(
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Colonia",
                      textController: coloniafiscalController,
                      suffixIcon: const Icon(IconLibrary.iconLocation),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Código postal",
                      textController: codigoPostalfiscalController,
                      suffixIcon: const Icon(IconLibrary.iconLocation),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        } else if (value.length != 5 || double.tryParse(value) == null) {
                          return 'Ingrese un código postal válido (${value.length}/5)';
                        }
                        return null;
                      },
                    ),
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Ciudad",
                      textController: ciudadfiscalController,
                      suffixIcon: const Icon(IconLibrary.iconMap),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 5),
                  _rowDividedTwo(
                    MyTextfieldIcon(
                      formatting: false,
                      backgroundColor: theme.colorScheme.background,
                      labelText: "Estado",
                      textController: estadofiscalController,
                      suffixIcon: const Icon(IconLibrary.iconMap),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                    MyTextfieldIcon(
                      backgroundColor: theme.colorScheme.background,
                      labelText: "País",
                      textController: paisfiscalController,
                      suffixIcon: const Icon(IconLibrary.iconMap),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor completa este campo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _myContainerCuenta("CUENTA CONTABLE"),
                  const AccountingAccount(),
                  const SizedBox(height: 20),
                  _myContainer("ORIGEN DEL PROVEEDOR"),
                  ProveedorOriginCheck(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _bancoWidget (){
    return Column(children: [_fullBody(), _cardsLabel(),]);
  }

  Widget _fullBody() {
    return Container(height: 40, width: size.width - 370, decoration: BoxDecoration(color: theme.primaryColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const SizedBox(width: 20),
          const Expanded(child: Text("Nombre del Titular", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
          const Expanded(child: Text("Banco", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
          const Expanded(child: Text("Clabe", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
          SizedBox(width: 35, child: IconButton(onPressed: () {_showAddBankDetailsModal(context);},
            icon: const Icon(IconLibrary.iconAdd), hoverColor: theme.colorScheme.background, style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary), padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(3)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),),),),],),),);}


  Widget _cardsLabel(){
    return Container(height: 300, width: size.width-370, decoration: BoxDecoration(color: theme.primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),),
      child: Scrollbar(controller: datosPagoScrollController, thumbVisibility: true,
        child: FadingEdgeScrollView.fromScrollView(child: ListView.builder(
            controller: datosPagoScrollController, itemCount: _datosBancariosList.length, itemBuilder: (BuildContext context, int index){
          final datos = _datosBancariosList[index];
          return _card2(datos, index);}),),),);}

  Widget _card2(Map<String, String> datos, int index) {
    final String banco = datos['Banco']?.isNotEmpty == true
        ? datos['Banco']!
        : datos['Banco Internacional'] ?? '';
    final String clabe = datos['Clabe']?.isNotEmpty == true
        ? datos['Clabe']!
        : datos['Clabe Internacional'] ?? '';

    return Tooltip(
      message: 'Banco: $banco\n'
          'Clabe: $clabe\n'
          'Nombre del Titular: ${datos['Nombre del Titular']}\n'
          'Tipo de Cuenta: ${datos['Tipo de cuenta']}\n'
          'Moneda: ${datos['Moneda']}\n'
          'Método de Pago: ${datos['Método de pago']}\n'
          'Banco Internacional: ${datos['Banco Internacional']}\n'
          'Clabe Internacional: ${datos['Clabe Internacional']}\n'
          'Tipo de Cuenta Internacional: ${datos['Tipo de cuenta Internacional']}',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(onDoubleTap: () {_showCardDetailsDialog(context, datos);},
        child: MySwipeTileCard(colorBasico: theme.colorScheme.background, containerB: SizedBox(height: 45,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 20,),
            Expanded(child: Text(datos['Nombre del Titular'] ?? '', textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
            Expanded(child: Text(banco, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
            Expanded(child: Text(clabe, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),),
            const SizedBox(width: 35,),],),),
          onTapLR: () {
            setState(() {});
            DatosBancariosModels datosBancarios = DatosBancariosModels(
              banco: datos['Banco'] ?? '',
              clabe: datos['Clabe'] ?? '',
              nombreTitular: datos['Nombre del Titular'] ?? '',
              tipoCuenta: datos['Tipo de cuenta'] ?? '',
              moneda: datos['Moneda'] ?? '',
              metodoPago: datos['Método de pago'] ?? '',
              bancoInternacional: datos['Banco Internacional'] ?? '',
              clabeInternacional: datos['Clabe Internacional'] ?? '',
              tipoCuentaInternacional: datos['Tipo de cuenta Internacional'] ?? '',
              proveedorId: datos['Proveedor ID'] ?? '',
              idDatosBancarios: datos['Datos Bancarios ID'] ?? '',);
            editDatosBancarios(datosBancarios, index, );},
          onTapRL: () {deleteElement( index );},
        ),
      ),
    );
  }

  void _showCardDetailsDialog(BuildContext context, Map<String, String> datos) {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
      return AlertDialog(title: Center (child: Text('Datos de Pago', style: TextStyle(color: theme.colorScheme.onPrimary),)),
        content: SingleChildScrollView(
          child: Column(children: [Divider(thickness: 3, color: theme.colorScheme.secondary),
            Row(children: [Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,children: [
              RichText(text: TextSpan(children: <TextSpan>[
                TextSpan(text: 'Banco: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                TextSpan(text: '${datos['Banco']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
              RichText(text: TextSpan(children: <TextSpan>[
                TextSpan(text: 'Clabe: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                TextSpan(text: '${datos['Clabe']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
              RichText(text: TextSpan(children: <TextSpan>[
                TextSpan(text: 'Nombre del Titular: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                TextSpan(text: '${datos['Nombre del Titular']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
              RichText(text: TextSpan(children: <TextSpan>[
                TextSpan(text: 'Tipo de Cuenta: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                TextSpan(text: '${datos['Tipo de cuenta']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
              RichText(text: TextSpan(children: <TextSpan>[
                TextSpan(text: 'Moneda: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                TextSpan(text: '${datos['Moneda']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),],),
            ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Método de Pago: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                  TextSpan(text: '${datos['Método de pago']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
                RichText(text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Banco Internacional: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                  TextSpan(text: '${datos['Banco Internacional']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
                RichText(text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Clabe Internaional: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                  TextSpan(text: '${datos['Clabe Internacional']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),
                RichText(text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Tipo de Cuenta Internacional: ', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.bold)),
                  TextSpan(text: '${datos['Tipo de cuenta Internacional']}', style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),],),),],
              ),),],),],),),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {setState(() {});Navigator.of(context).pop();},
            style: TextButton.styleFrom(backgroundColor: theme.colorScheme.inversePrimary, primary: theme.colorScheme.onPrimary,),
            child: const Text('Cerrar'),),],);
    },);}

  Widget _rowDivided(Widget widgetL, Widget widgetC,Widget widgetR){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(width: size.width * 0.23, child: widgetL,),
      SizedBox(width: size.width * 0.23,child: widgetC,),
      SizedBox(width: size.width * 0.23,child: widgetR,),],);}


  Widget _rowDividedTwo(Widget widgetL, Widget widgetR){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(width: size.width*0.23,child: widgetL,),
      SizedBox(width: size.width*0.23,child: widgetR,),],);}


  void editDatosBancarios(DatosBancariosModels datosBancarios, int index) {
    if (editDatosBancariosP) {
      bancoController.text = datosBancarios.banco;
      clabeController.text = datosBancarios.clabe;
      nombreTitularController.text = datosBancarios.nombreTitular;
      tipoCuentaController.text = datosBancarios.tipoCuenta;
      selectedMoneda = datosBancarios.moneda;
      selectedMetodoPago = datosBancarios.metodoPago;
      bancoIntController.text = datosBancarios.bancoInternacional;
      clabeIntController.text = datosBancarios.clabeInternacional;
      tipoCuentaIntController.text = datosBancarios.tipoCuentaInternacional;
      Map<String, String> datos = {
        'Banco': datosBancarios.banco,
        'Clabe': datosBancarios.clabe,
        'Nombre del Titular': datosBancarios.nombreTitular,
        'Tipo de cuenta': datosBancarios.tipoCuenta,
        'Moneda': datosBancarios.moneda,
        'Método de pago': datosBancarios.metodoPago,
        'Banco Internacional': datosBancarios.bancoInternacional,
        'Clabe Internacional': datosBancarios.clabeInternacional,
        'Tipo de cuenta Internacional': datosBancarios.tipoCuentaInternacional,
      };

      CustomAwesomeDialog(title: Texts.askEditConfirm, desc: 'Datos de Pago: ${datosBancarios.nombreTitular}',
        btnOkOnPress: () async {
          await _showEditBankDetailsModal(datos, datosBancarios, index);getMoneda();},
        btnCancelOnPress: () {},).showQuestion(context);} else {
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);}
  }

  Future<void> _showEditBankDetailsModal(  Map<String, String > datos, DatosBancariosModels datosBancarios, int index) async {
    showModalBottomSheet(context: context, backgroundColor: theme.backgroundColor, isScrollControlled: true, isDismissible: false,
      builder: (BuildContext context) {return BankDetailsModal(initialData: datos, onSave: ( Map<String, String> newData ){
        setState(() {
          _datosBancariosList[index] = newData;});});
      },
    );
  }

  void _showAddBankDetailsModal (BuildContext context) async {
    showModalBottomSheet(context: context, backgroundColor: theme.backgroundColor, isScrollControlled: true, isDismissible: false,
      builder: (BuildContext context){clearControllers();
      return BankDetailsModal(
        onSave: ( Map<String , String> newData ){
        setState(() {_datosBancariosList.add(newData);});},
      );},
    );
  }

  void getMoneda() {
    listMonedas = widget.monedas;listMonedasString = listMonedas.map((e) => e.nombre).toList();selectedMoneda = listMonedasString.first;
  }

  deleteElement( index ) async {
    CustomAwesomeDialog(title: Texts.askDeleteConfirm, desc: 'Datos de Pago:', btnOkOnPress: () {
      setState(() {_datosBancariosList.removeAt(index);});
    },
      btnCancelOnPress: () {},).showQuestion(context);
  }
}