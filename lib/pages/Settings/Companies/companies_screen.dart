import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/empresaController.dart';
import 'package:tickets/models/ConfigModels/empresa.dart';
import 'package:tickets/pages/Settings/Companies/companies_edit_screen.dart';
import 'package:tickets/pages/Settings/Companies/companies_registration_screen.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/ConfigModels/usuarioPermiso.dart';
import '../../../shared/utils/color_palette.dart';
import '../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../shared/widgets/error/customNoData.dart';

class EmpresasScreen extends StatefulWidget {
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  BuildContext context;
  EmpresasScreen({super.key, required this.listUsuarioPermisos, required this.context});
  @override
  _EmpresasScreenState createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  late Size size; late ThemeData theme;
  FocusNode _focusNode = FocusNode();
  final _searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  double width = 0;
  final List<String> items = ['Usuario', 'Administrador', 'Super-Admin',];
  List<String> selectedItems = [];
  List<EmpresaModels> listEmpresas = [], listEmpresasTemp = [];
  final GlobalKey _gKey = GlobalKey();
  bool _isLoading = true, addCompanyP = false, editCompanyP = false, deleteCompanyP = false,
      _pressed = false;
  @override
  void initState() {
    super.initState();
    getCompanies();
    getPermisos();
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if(listEmpresas.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
        _isLoading = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context); width = size.width-350;
    return PressedKeyListener(keyActions: {
      LogicalKeyboardKey.f4: () async {
        await myShowDialogScale(const CompaniesRegistrationScreen(), context);
        getCompanies();
      },
      LogicalKeyboardKey.f5: () async {await actualizar();},
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _gKey,
    child: Scaffold(
      appBar: size.width > 600? MyCustomAppBarDesktop(title:"Empresas",context: widget.context,backButton: false) : null,
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: size.width> 600? _bodyLandscape() : _bodyPortrait(),
        ),
      ),
    ));
  }
  Widget _bodyLandscape(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
          Row(children: [
            Row(children: _filtros(),),
            const SizedBox(width: 5,),
            _tableViewButton(),
          ],),
          Row(children: [
            _customButtonAdd(),
            const SizedBox(width: 5,),
            _customButtonEdit(),
            const SizedBox(width: 5,),
            _customButtonDelete(),
          ])
        ],),
        const SizedBox(height: 5,),
        encabezados(),
        lista(),
      ],
    );
  }
  Widget _tableViewButton() {
    return Tooltip(message: _pressed? Texts.showViewCard : Texts.showViewTable,
      waitDuration: const Duration(milliseconds: 500),child: SizedBox(height: 56, width: 45,
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),),
      ),
    ),
    );
  }
  Widget encabezados(){
    return Container(height: 50,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: (_pressed? 10 :20) , vertical: 2),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 10,),
                SizedBox(width: width/6, child: const Text("Nombre",    textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                SizedBox(width: width/6, child: const Text("Telefono",  textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                SizedBox(width: width/6, child: const Text("Email",     textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                SizedBox(width: width/6, child: const Text("RFC",       textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                SizedBox(width: width/(_pressed? 3.5 : 4.4), child: const Text("Dirección", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                if(!_pressed)...[
                  const SizedBox(width: 40, child: Text("Logo", textAlign:TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.2 ))),
                ],
                const SizedBox(width: 10,),
              ],
            ))
    );
  }
  Widget lista(){
    return Container(height: size.height-180, decoration: BoxDecoration(color: theme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),),
      child:RefreshIndicator(
          onRefresh: () async {await actualizar();},
          color: theme.colorScheme.onPrimary,
          child: FutureBuilder<List<EmpresaModels>>(
            future: _getDatos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: _buildLoadingIndicator(10));
              } else {
                final listProducto = snapshot.data ?? [];
                if (listProducto.isNotEmpty) {
                  return Container(height: size.height-200,
                    decoration: BoxDecoration(color: theme.primaryColor,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
                        controller: scrollController, itemCount: listEmpresasTemp.length,
                        itemBuilder: (context, index) {
                          return _card2(listEmpresasTemp[index], index);
                        },
                      ),
                    ),
                  );
                } else {
                  if(_isLoading){
                    return Center(child: _buildLoadingIndicator(10));
                  }else{
                    return SingleChildScrollView(child: Center(child: NoDataWidget()),);
                  }
                }
              }
            },
          )
      ),
    );
  }
  Future<void> actualizar() async {
    getCompanies();
    _isLoading = true;
    setState(() {});
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if(listEmpresas.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
        _isLoading = false;
      }
    });
  }
  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {return cardEsqueleto(size.width);});
    return SingleChildScrollView(physics: const NeverScrollableScrollPhysics(),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max,
              children: buttonList)
      ),
    );
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 65,child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
        color: theme.backgroundColor, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Shimmer.fromColors(baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1), enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8))),
          ),
        )
    ),);
  }
  Widget _bodyPortrait(){
    return const Column(children: [Text("data")],);
  }
  Widget _customButtonAdd(){
    return Tooltip(message: Texts.companiesRegistration, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          if(addCompanyP){
            await myShowDialogScale(const CompaniesRegistrationScreen(), context);
            getCompanies();
          }else{
            CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
          }
        }, icon: const Icon(IconLibrary.iconAdd),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);;
  }
  Widget _customButtonEdit(){
    return Tooltip(message: Texts.companiesEdit, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          EmpresaModels? empresa = await getEmpresaSelected();
          if(empresa != null) {
            editCompany(empresa);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, Texts.errorEdit, Texts.selectCompany);
          }
        }, icon: const Icon(IconLibrary.iconEdit),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }
  Future<EmpresaModels?> getEmpresaSelected() async{
    EmpresaModels? usuarioSelected;
    try {usuarioSelected = listEmpresasTemp.firstWhere((element) => element.selected);}
    catch (e) {usuarioSelected = null;}
    return usuarioSelected;
  }
  Widget _customButtonDelete(){
    return Tooltip(message: Texts.companiesDeactivate, waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(height: 50, width: 50,
        child: IconButton(onPressed: () async {
          EmpresaModels? empresa = await getEmpresaSelected();
          if(empresa != null) {
            deleteCompany(empresa);
          }else{
            MyCherryToast.showWarningSnackBar(context, theme, Texts.errorDeactivate, Texts.selectCompany);
          }
        }, icon: const Icon(IconLibrary.iconDelete),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
            shape: MaterialStateProperty.all <RoundedRectangleBorder> (
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),),
        ),
      ),);
  }
  List<Widget> _filtros(){
    return [
      SizedBox(width: 250, child:
      MyTextfieldIcon(labelText: Texts.search, textController: _searchController, focusNode: _focusNode,
        suffixIcon: const Icon(IconLibrary.iconSearch),floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold),backgroundColor: theme.colorScheme.secondary, colorLine: theme.colorScheme.primary,
        onChanged: (value){
          aplicarFiltros();
          setState(() {
            FocusScope.of(context).requestFocus(_focusNode);
          });
        },
      ),),
    ];
  }
  Widget _card2(EmpresaModels empresa, int index) {
    return GestureDetector(onTap: (){
      if(empresa.selected){
        empresa.toggleSelected();
      }else{
        listEmpresasTemp.where((element) => element!= empresa).forEach((element) {
          if(element.selected){
            element.toggleSelected();
          }
        });
        empresa.toggleSelected();
      }
    },
      onDoubleTap: (){editCompany(empresa);},
      onLongPress: (){deleteCompany(empresa);},
      child: _pressed!=true? mySwipeCard(empresa, index) :
      mySwipeTable(empresa, index),);
  }
  Widget mySwipeCard(EmpresaModels empresa, int index){
    return ValueListenableBuilder<bool>(valueListenable: empresa.selectedNotifier,
        builder: (context, isSelected, child) {
          return MySwipeTileCard(verticalPadding: 2,
            colorBasico: !isSelected ? theme.colorScheme.background : theme.colorScheme.secondary,
            iconColor: theme.colorScheme.onPrimary, containerRL: null,
            colorRL: empresa.estatus == true ? null : ColorPalette.ok,
            containerB: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
                SizedBox(width: width / 6,
                    child: Text(empresa.nombre, textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13))),
                SizedBox(width: width / 6,
                    child: Text(empresa.telefono.trim() != "" ? empresa.telefono : "Sin telefono",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13))),
                SizedBox(width: width / 6,
                    child: Text(empresa.correo.trim() != "" ? empresa.correo : "Sin email",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13))),
                SizedBox(width: width / 6,
                    child: Text(empresa.rfc.trim() != "" ? empresa.rfc : "Sin RFC",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13))),
                SizedBox(width: width / 4.4,
                    child: Text(empresa.direccion.trim() != "" ? empresa.direccion : "Sin direccion",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13))),
                SizedBox(width: 40, height: 35,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(context: context,
                        builder: (context) => Dialog(surfaceTintColor: theme.colorScheme.background,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              child: Container(width: 200, height: 200,
                                padding: const EdgeInsets.all(20.0),
                                child: Column(children: [
                                  SizedBox(width: 140, height: 140,
                                    child: PhotoView(
                                      backgroundDecoration: BoxDecoration(color: theme.colorScheme.background),
                                      imageProvider: imageFromBase64String2(empresa.logo),
                                    ),
                                  ),
                                  Text(empresa.nombre, textAlign: TextAlign.center,)
                                ],),
                              ),
                            ),
                      );
                    },
                    child: Container(padding: const EdgeInsets.all(5.0),
                        // Ajusta este valor para cambiar el tamaño de la imagen
                        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary),
                        child: imageFromBase64String(empresa.logo)
                    ),
                  ),
                ),
                const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
              ],
            ),
            onTapRL: () {deleteCompany(empresa);},
            onTapLR: () {editCompany(empresa);},
          );
        }
    );
  }
  ImageProvider imageFromBase64String2(String? base64String) {
    try {
      if(base64String == null){
        return const AssetImage('assets/multinacional.png'); // Reemplaza esto con la ruta a tu imagen predeterminada
      } else {
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        return MemoryImage(uint8List);
      }
    } catch (e) {
      print("Error decoding Base64: $e");
      return const AssetImage('assets/multinacional.png'); // Reemplaza esto con la ruta a tu imagen de error
    }
  }
  Widget imageFromBase64String(String? base64String) {
    try {
      if(base64String == null){
        return const CircleAvatar(
            backgroundImage: AssetImage('assets/multinacional.png'),);
      }else{
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        Image image = Image.memory(uint8List);
        return Container(child: image);
      }
    } catch (e) {
      print("Error decoding Base64: $e");
      return const CircleAvatar(
          backgroundImage: AssetImage('assets/avatar.png'),);
    }
  }
  Widget mySwipeTable(EmpresaModels empresa, int index){
    return MySwipeTileCard(
      radius: 0, horizontalPadding: 2, verticalPadding: 0.5,
      colorBasico: index%2 == 0? theme.colorScheme.background : (theme.colorScheme == GlobalThemData.lightColorScheme
          ? ColorPalette.backgroundLightColor
          : ColorPalette.backgroundDarkColor), iconColor: theme.colorScheme.onPrimary,
      containerRL: null, colorRL: empresa.estatus == true? null : ColorPalette.ok,
      containerB: Padding(padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
            SizedBox(width: width/6  ,child: Text(empresa.nombre, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11))),
            SizedBox(width: width/6 ,child: Text(empresa.telefono.trim()!=""?empresa.telefono : "Sin telefono",
                textAlign: TextAlign.left,style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11))),
            SizedBox(width: width/6  ,child: Text(empresa.correo.trim()!=""?empresa.correo : "Sin email",
                textAlign: TextAlign.left,style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11))),
            SizedBox(width: width/6  ,child: Text(empresa.rfc.trim()!=""?empresa.rfc : "Sin RFC",
                textAlign: TextAlign.left,style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11))),
            SizedBox(width: width/3.5,child: Text(empresa.direccion.trim()!=""?empresa.direccion : "Sin direccion",
                textAlign: TextAlign.left,style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11))),
            const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
          ],
        ),
      ),
      onTapRL: () {deleteCompany(empresa);},
      onTapLR: () {editCompany(empresa);},
    );
  }
  void editCompany(EmpresaModels empresa){
    if(editCompanyP) {
      CustomAwesomeDialog(title: Texts.askEditConfirm, desc: 'Empresa: ${empresa.nombre}', btnOkOnPress: () async {
        await myShowDialogScale(CompaniesEditScreen(empresaModels: empresa,), context);
        getCompanies();
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void deleteCompany(EmpresaModels empresa){
    if(deleteCompanyP){
      CustomAwesomeDialog(title: Texts.askDeleteConfirm, desc: 'Empresa: ${empresa.nombre}', btnOkOnPress: () async {
        try{
          LoadingDialog.showLoadingDialog(context, Texts.savingData);
          bool delete = false;
          EmpresaController empresaController = EmpresaController();
          delete = await empresaController.deleteEmpresa(empresa.idEmpresa!);
          LoadingDialog.hideLoadingDialog(context);
          if(delete){
            CustomAwesomeDialog(title: Texts.deleteSuccess, desc: '', btnOkOnPress: (){},
                btnCancelOnPress: (){}).showSuccess(context);
            getCompanies();
          }else{
            CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected, btnOkOnPress: (){},
                btnCancelOnPress: (){}).showError(context);
          }
        }catch(e){
          LoadingDialog.hideLoadingDialog(context);
          ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
          String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
          CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: error, btnOkOnPress: (){},
              btnCancelOnPress: (){}).showError(context);
        }
      }, btnCancelOnPress: (){}).showQuestion(context);
    }
  }
  Future<List<EmpresaModels>> _getDatos() async {
    try {
      return listEmpresasTemp;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }
  Future<void> getCompanies() async {
    try{
      listEmpresas = [];
      UserPreferences userPreferences = UserPreferences();
      String usuarioId = await userPreferences.getUsuarioID();
      print(usuarioId);
      EmpresaController empresaController = EmpresaController();
      listEmpresas = await empresaController.getEmpresas(usuarioId);
      listEmpresasTemp = listEmpresas;
      aplicarFiltros();
      setState(() {});
    }catch(e){
      print(e);
    }
  }
  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for(int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId == Texts.permissionsCompanyAdd) {
        addCompanyP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsCompanyEdit){
        editCompanyP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsCompanyDelete) {
        deleteCompanyP = true;
      }
    }
  }
  void aplicarFiltros() {
    listEmpresasTemp = listEmpresas;
    if(_searchController.text.isNotEmpty){
      listEmpresasTemp = listEmpresasTemp.where((empresa) =>
      empresa.nombre.toLowerCase().contains(_searchController.text.toLowerCase())
          || "${empresa.nombre} ${empresa.rfc} ${empresa.direccion}".
      toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }
    setState(() {});
  }
}