import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_decoration.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../../controllers/ConfigControllers/usuarioController.dart';
import '../../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';
import '../../../models/ConfigModels/area.dart';
import '../../../models/ConfigModels/departamento.dart';
import '../../../models/ConfigModels/empresa.dart';
import '../../../models/ConfigModels/puesto.dart';
import '../../../models/ConfigModels/usuario.dart';
import '../../../shared/utils/user_preferences.dart';
import '../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../shared/widgets/my_expandable/my_expandable.dart';

class UserEditScreen extends StatefulWidget {
  static String id = 'userEdit';

  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  List<AreaModels> areas = [];
  UsuarioModels usuario;
  List<EmpresaModels> listEmpresas = [];
  List<String> listEmpresasIDs = [];
  UserEditScreen({super.key, required this.listSubmoduloPermisos, required this.usuario,
  required this.listUsuarioPermisos, required this.areas, required this.listEmpresas, required this.listEmpresasIDs});
  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); final GlobalKey _key = GlobalKey();
  final _usernameController = TextEditingController(), _nombreController = TextEditingController(),
      _apellidoPController = TextEditingController(), _apellidoMController = TextEditingController(),
      _passwordController = TextEditingController(), _passwordConfirmController = TextEditingController();
  final ScrollController scrollController = ScrollController(), _scrollController = ScrollController();
  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  late Size size; late ThemeData theme;
  List<String> listTipoUsuario = ["Selecciona el tipo de usuario","Usuario", "Administrador", "SuperAdmin"];
  List<String> listAreas = ["Selecciona el area"], listDepartamento = ["Selecciona el departamento"],
      listPuesto = ["Selecciona el puesto"], empresasIDs = [];
  List<AreaModels> areas = [];
  String selectedTipoUsuario = "Selecciona el tipo de usuario", selectedArea = "Selecciona el area",
      selectedDepartamento = "Selecciona el departamento", selectedPuesto = "Selecciona el puesto",
      empresaID = "";
  late AreaModels selectedAreaModel;
  late DepartamentoModels selectedDepartamentoModel;
  late PuestoModels selectedPuestoModel;
  SwiperController swiperController = SwiperController();
  List<EmpresaModels> listEmpresas = [], listEmpresasTemp = [];
  Image? image;Uint8List? imageBytes;String base64String = "";
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    listSubmoduloPermisos = widget.listSubmoduloPermisos;
    listEmpresas = widget.listEmpresas;
    empresasIDs = widget.listEmpresasIDs;
    getEmpresaDefault();
    getUsuario();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return WillPopScope(child: PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
        LogicalKeyboardKey.escape : () {
          CustomAwesomeDialog(title: Texts.alertExit, desc: Texts.lostData,
              btnOkOnPress: (){Navigator.of(context).pop();}, btnCancelOnPress: (){}).showQuestion(context);
        },
        LogicalKeyboardKey.f1 : () async {tabController.index = 0;},
        LogicalKeyboardKey.f2 : () async {tabController.index = 1;},
        LogicalKeyboardKey.f4 : () async {
          if(tabController.index == 0) {
            if (_formKey.currentState!.validate()) {
              _save();
            }else{
              CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
            }
          }else{
            await swiperController.move(0);
            Future.delayed(const Duration(milliseconds: 400), () {
              if (_formKey.currentState!.validate()) {
                _save();
              }else{
                CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
              }
            });
          }
        },
      }, Gkey: _key,child: Scaffold(backgroundColor: theme.backgroundColor,
      appBar: size.width > 600? MyCustomAppBarDesktop(title:"Editar usuario",height: 45,
          suffixWidget: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.backgroundColor, elevation: 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Guardar  ", style: TextStyle(color: theme.colorScheme.onPrimary),),
                Container(padding: const EdgeInsets.all(.5),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: theme.colorScheme.secondary, width: 3,),)),
                    child: Text(' f4 ', style: TextStyle( color: theme.colorScheme.onPrimary ),)),
                Icon(IconLibrary.iconSave, color: theme.colorScheme.onPrimary, size: size.width *.015, ),
              ],),
            onPressed: () async {
              tabController.index = 0;
              await Future.delayed(Duration(milliseconds: 400));
              if (_formKey.currentState!.validate()) {
                _save();
              }else{
                CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
              }
            },
          ),
          context: context,backButton: true, defaultButtons: false,
          borderRadius: const BorderRadius.all(Radius.circular(25))
      ) : null,
      body: size.width > 600? _landscapeBody() : _portraitBody(),
    ),
    ), onWillPop: () async {
      bool salir = false;
      CustomAwesomeDialog(title: Texts.alertExit, desc: Texts.lostData, btnOkOnPress:(){salir  = true;},
        btnCancelOnPress: () {salir = false;},).showQuestion(context);
      return salir;
    }
    );
  }
  List<Widget> userData(){
    return [
      _myContainer("DATOS DEL USUARIO"),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _rowDivided(
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Nombre(s)", textController: _nombreController,
                suffixIcon: const Icon(IconLibrary.iconPerson),validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Texts.completeField;
                  }else if(value.length > 50){
                    return 'El nombre debe tener menos de 50 caracteres';
                  }
                  return null;
                }),
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Apellido paterno", textController: _apellidoPController,
                suffixIcon: const Icon(IconLibrary.iconPerson),validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Texts.completeField;
                  }else if(value.length > 50){
                    return 'El apellido paterno debe tener menos de 20 caracteres';
                  }
                  return null;
                }),
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Apellido materno", textController: _apellidoMController,
                suffixIcon: const Icon(IconLibrary.iconPerson),validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }else if(value.length > 50){
                    return 'El apellido materno debe tener menos de 20 caracteres';
                  }
                  return null;
                }),
          ),
          const SizedBox(height: 5,),
          _rowDivided(
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Usuario", textController: _usernameController,
                suffixIcon: const Icon(IconLibrary.iconPerson,),formatting: false, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Texts.completeField;
                  }else if(value.length > 20){
                    return 'El usuario debe tener menos de 20 caracteres';
                  }
                  return null;
                }),
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Contraseña", textController: _passwordController,
                suffixIcon: const Icon(IconLibrary.iconLock),formatting: false,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Texts.completeField;
                  }else if(value.length > 20){
                    return 'La contraseña debe tener menos de 20 caracteres';
                  }
                  return null;
                }),
            MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "Confirmar contraseña", textController: _passwordConfirmController,
                suffixIcon: const Icon(IconLibrary.iconLock),formatting: false,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Texts.completeField;
                  }else if(value != _passwordController.text){
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                }),
          ),
        ],),
        Column(children: [SizedBox(width: size.width*.06,child: _imageField())]),
      ],),
    ];
  }
  Widget _imageField() {
    return Column(
      children: [
        imageBytes != null ? Image.memory(imageBytes!,
          height: size.width * 0.06, width: size.width *.06, fit: BoxFit.cover,)
            : Container(height: size.width * 0.06, width: size.width *.06,
          color: theme.colorScheme.onPrimaryContainer, child: const Icon(Icons.image, size: 40,),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [IconButton(icon: const Icon(Icons.photo_library), onPressed: () => _pickImage())],
        ),
      ],
    );
  }
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],);
    if (result != null) {
      PlatformFile file = result.files.single;
      final File imageFile = File(file.path.toString());
      int fileSize = await imageFile.length();
      int maxSize = 1024*1024;
      if(fileSize <= maxSize){
        imageBytes = await imageFile.readAsBytes();
        image = Image.memory(imageBytes!);
        base64String = maxSize/10 > fileSize? base64.encode(imageBytes!) : await reducirCalidadImagenBase64(base64.encode(imageBytes!));
        setState(() {});
      }else{
        CustomAwesomeDialog(title: Texts.errorSavingData, desc: Texts.imageSizeMb,
            btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
      }
    } else {
      // El usuario canceló la selección de archivos
    }
  }
  List<Widget> jobData(){
    return [
      _myContainer("DATOS DE PUESTO"),
      _rowDivided2(
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          const Text("Tipo de usuario"),
          MyDropdown(textStyle: theme.textTheme.bodyText2, dropdownItems: listTipoUsuario,
            selectedItem: selectedTipoUsuario, suffixIcon: const Icon(IconLibrary.iconGroups),
            onPressed: (String? value) {
              selectedTipoUsuario = value!;
              setState(() {});
            }, enabled: true,
          )
        ],),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          const Text("Área"),
          MyDropdown(textStyle: theme.textTheme.bodyText2, dropdownItems: listAreas, selectedItem: selectedArea,
            suffixIcon: const Icon(IconLibrary.iconUser),
            onPressed: (String? value) {
              selectedArea = value!;
              selectedDepartamento = "Selecciona el departamento";
              selectedPuesto = "Selecciona el puesto";
              listDepartamento = ["Selecciona el departamento"];
              listPuesto = ["Selecciona el puesto"];
              if(value!= "Selecciona el area"){
                listDepartamento = ["Selecciona el departamento"];
                for(int i = 0; i<areas.length; i++){
                  if(areas[i].nombre == value){
                    selectedAreaModel = areas[i];
                    break;
                  }
                }
                for(int j = 0; j<selectedAreaModel.departamentos!.length; j++){
                  listDepartamento.add(selectedAreaModel.departamentos![j].nombre);
                }
              }
              setState(() {});
              print(value);
            }, enabled: true,
          )
        ],),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          const Text("Departamento"),
          MyDropdown(textStyle: theme.textTheme.bodyText2, suffixIcon: const Icon(IconLibrary.iconPerson),
            dropdownItems: listDepartamento, selectedItem: selectedDepartamento,
            onPressed: (String? value) {
              selectedDepartamento = value!;
              if(value != "Selecciona el departamento"){
                listPuesto = ["Selecciona el puesto"];
                selectedPuesto = "Selecciona el puesto";
                for(int j = 0; j<selectedAreaModel.departamentos!.length; j++){
                  if(selectedAreaModel.departamentos![j].nombre == value){
                    selectedDepartamentoModel = selectedAreaModel.departamentos![j];
                    break;
                  }
                }
                for(int k = 0; k<selectedDepartamentoModel.puestos!.length; k++){
                  listPuesto.add(selectedDepartamentoModel.puestos![k].nombre);
                }
              }
              setState(() {});
              print(value);
            }, enabled: true,
          )
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          const Text("Puesto"),
          MyDropdown(textStyle: theme.textTheme.bodyText2, suffixIcon: const Icon(IconLibrary.iconBusiness2),
            dropdownItems: listPuesto, selectedItem: selectedPuesto,
            onPressed: (String? value) {
              selectedPuesto = value!;
              for(int i = 0; i<selectedDepartamentoModel.puestos!.length; i++){
                if(selectedDepartamentoModel.puestos![i].nombre == value){
                  selectedPuestoModel = selectedDepartamentoModel.puestos![i];
                  break;
                }
              }
              setState(() {});
            }, enabled: true,
          )
        ],),
      ),
    ];
  }
  List<Widget> permisos(){
    return [
      _myContainer("PERMISOS"),
      Wrap(alignment: WrapAlignment.start,
        spacing: 5, runSpacing: 5, children: _buildSubmoduloPermiso(listSubmoduloPermisos),)
    ];
  }
  List<Widget> _buildSubmoduloPermiso(List<SubmoduloPermisos> listSubmoduloPermisos){
    List<Widget> departments = [];
    for (SubmoduloPermisos submoduloPermiso in listSubmoduloPermisos){
      departments.add(_myContainerPermisos2(submoduloPermiso.nombreSubmodulo, submoduloPermiso, 270));
    }
    return departments;
  }
  Widget _myContainerPermisos2(String text,SubmoduloPermisos groupPermiso,double width){
    return SizedBox(width: width,child: MyExpandable(backgroundColor: theme.primaryColor, isExpanded: false,
      header: Padding(padding: const  EdgeInsets.all(8.0),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          Text(text, style:const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
          Switch(hoverColor: theme.colorScheme.onSecondaryContainer,
            inactiveTrackColor: theme.colorScheme.onSecondaryContainer,
            activeTrackColor: theme.colorScheme.secondary, value: groupPermiso.activo,
            onChanged: (value) {
              setState(() {
                groupPermiso.activo = value;
                if(value){
                  for(int i = 0; i<groupPermiso.permisos!.length; i++){
                    if(selectedTipoUsuario == "SuperAdmin") {
                      groupPermiso.permisos![i].activo = true;
                    }else if(selectedTipoUsuario == "Administrador"){
                      if(groupPermiso.permisos![i].tipoUsuario == "Administrador" || groupPermiso.permisos![i].tipoUsuario == "Usuario") {
                        groupPermiso.permisos![i].activo = true;
                      }
                    }else if(selectedTipoUsuario == "Usuario"){
                      if(groupPermiso.permisos![i].tipoUsuario == "Usuario") {
                        groupPermiso.permisos![i].activo = true;
                      }
                    }
                  }
                }else{
                  for(int i = 0; i<groupPermiso.permisos!.length; i++){
                    groupPermiso.permisos![i].activo = false;
                  }
                }
              });
            },
          ),
        ]),
      ),
      expanded: Padding(padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Divider(thickness: 2,color: theme.colorScheme.secondary,),
          for(int i = 0; i<groupPermiso.permisos!.length; i++)...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[
              SizedBox(width: size.width/6,child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                Tooltip(waitDuration: const Duration(milliseconds: 500),
                  message: groupPermiso.permisos![i].descripcion,
                  child: SizedBox(width: size.width/6-60,child: Text(groupPermiso.permisos![i].nombre),),
                ),
                Switch(hoverColor: theme.colorScheme.onSecondaryContainer,
                  inactiveTrackColor: theme.colorScheme.onSecondaryContainer,
                  activeTrackColor: theme.colorScheme.secondary,
                  value: groupPermiso.permisos![i].activo,
                  onChanged: (value) {_updatePermiso(value, groupPermiso, i);},
                ),
              ],),),
            ])
          ]
        ],),
      ),));
  }
  Widget _landscapeBody(){
    return Column(children: [
      TabBar(controller: tabController,// Color de fondo del TabBar
        labelColor: theme.colorScheme.onPrimary, unselectedLabelColor: Colors.grey[400], // Color de las pestañas no seleccionadas
        labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Estilo de texto de las pestañas
        indicatorWeight: 5, padding: EdgeInsets.symmetric(horizontal: size.width*.15),
        tabs: const [
          Tab(text: "Datos Generales",),
          Tab(text: "Empresas del Usuario",),
        ],
      ),
      Expanded( // Agrega este widget
        child: SizedBox(height: size.height-140,width: size.width,child:
        TabBarView(controller: tabController,
          children: [
            userForm()[0],
            userForm()[1]
          ],),
        ),
      ),
    ],);
  }
  List<Widget> userForm(){
    return [
    Form(key: _formKey,
        child: Scrollbar(thumbVisibility: true,controller: _scrollController, child: FadingEdgeScrollView.fromSingleChildScrollView(child:
        SingleChildScrollView(controller: _scrollController,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child: Column(
              children: <Widget>[
                ...userData(),
                ...jobData(),
                ...permisos(),
              ],
            )))))
    ),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _myContainer("Asignar empresa(s)"),
            encabezados(),
            Container(height: size.height/2,
                decoration: BoxDecoration(color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child:FadingEdgeScrollView.fromScrollView(
                  child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController, itemCount: listEmpresasTemp.length,
                    itemBuilder: (context, index) {
                      return _card(listEmpresasTemp[index]);
                    },
                  ),
                ))
          ],),),)
    ];
  }
  Widget _card(EmpresaModels empresa){
    return MySwipeTileCard(
      colorBasico: theme.colorScheme.background, iconColor: theme.colorScheme.onPrimary,
      containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
        SizedBox(width: size.width/7,child: Text(empresa.nombre, textAlign: TextAlign.left,),),
        SizedBox(width: size.width/7,child: Text(empresa.rfc.trim()!=""?empresa.rfc : "Sin RFC",
          textAlign: TextAlign.left,),),
        SizedBox(width: size.width/4,child: Text(empresa.direccion.trim()!=""?empresa.direccion : "Sin dirección",
          textAlign: TextAlign.left,),),
        const SizedBox(width: 40,),
        const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
      ],),),
      onTapRL: (){deleteCompany(empresa);},
      onTapLR: (){editCompany(empresa);},
    );
  }
  Widget encabezados(){
    return Container(height: 50,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 15,),
                SizedBox(width: size.width/7, child: const Text("Nombre", textAlign: TextAlign.left, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ))),
                SizedBox(width: size.width/7, child: const Text("RFC",  textAlign: TextAlign.left, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ))),
                SizedBox(width: size.width/4, child: const Text("Dirección",  textAlign: TextAlign.left, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ))),
                IconButton(onPressed: (){
                  List<EmpresaModels> empresasNoIncluidas = listEmpresas.where((empresa) => !listEmpresasTemp.contains(empresa)).toList();
                  if(empresasNoIncluidas.isNotEmpty) {
                    showDialog(context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Agregar empresa', style: TextStyle(color: theme.colorScheme.onPrimary),),
                          content: SizedBox(width: size.width/2,
                            child: ListView.builder(shrinkWrap: true,
                              itemCount: empresasNoIncluidas.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(empresasNoIncluidas[index].nombre),
                                  onTap: () {
                                    setState(() {
                                      listEmpresasTemp.add(empresasNoIncluidas[index]);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }else{
                    CustomSnackBar.showInfoSnackBar(context, Texts.companiesNoAvailable);
                  }
                }, icon: const Icon(IconLibrary.iconAdd),
                  hoverColor: theme.colorScheme.background, style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
                    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                const SizedBox(width: 15,),
              ],
            ))
    );
  }
  Widget _myContainer(String text){
    return Container(width: size.width/3,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
      padding: const EdgeInsets.only(top: 5.0),
      child: Center(
          child: Column(children: [
            Text(text, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,),),
            Divider(thickness: 2,color: theme.colorScheme.secondary,)
          ],)
      ),
    );
  }
  Widget _rowDivided(Widget widgetL, Widget widgetC, Widget widgetR,){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
      SizedBox(width: size.width*0.20,child: widgetL,),
      const SizedBox(width: 3,),
      SizedBox(width: size.width * 0.20,child: widgetC,),
      const SizedBox(width: 3,),
      SizedBox(width: size.width*0.20,child: widgetR,),
    ],);
  }
  Widget _rowDivided2(Widget widgetL, Widget widgetC1, Widget widgetC2, Widget widgetR){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.15,child: widgetL,),
        SizedBox(width: size.width * 0.15,child: widgetC1,),
        SizedBox(width: size.width * 0.15,child: widgetC2,),
        SizedBox(width: size.width * 0.15,child: widgetR,),
      ],);
  }
  Widget _portraitBody(){
    return const Column(children: [Text("data")],);
  }
  void _updatePermiso(bool value, SubmoduloPermisos groupPermiso, int index){
    if(value && !groupPermiso.activo){
      groupPermiso.activo = true;
    }
    setState(() {
      groupPermiso.permisos![index].activo = value;
    });
    bool activo = false;
    for(int i = 0; i<groupPermiso.permisos!.length; i++){
      if(groupPermiso.permisos![i].activo){
        activo = true;
        break;
      }
    }
    if(!activo){
      groupPermiso.activo = false;
    }
  }
  Future<void> _save() async {
    CustomAwesomeDialog(title: Texts.askEditConfirm,
      desc: '', btnOkOnPress:() async {
        if(selectedTipoUsuario != "Selecciona el tipo de usuario" && selectedArea != "Selecciona el area" &&
            selectedDepartamento != "Selecciona el departamento" && selectedPuesto != "Selecciona el puesto") {
          try{
            UsuarioModels usuario = UsuarioModels(
                idUsuario: widget.usuario.idUsuario,
                nombre: _nombreController.text.trim(),
                apellidoPaterno: _apellidoPController.text.trim(),
                apellidoMaterno: _apellidoMController.text.trim(),
                userName: _usernameController.text.trim(),
                contrasenia: _passwordController.text.trim(),
                tipoUsuario: selectedTipoUsuario,
                puestoId: selectedPuestoModel.idPuesto,
                imagen: base64String
            );
            LoadingDialog.showLoadingDialog(context, Texts.savingData);
            List<UsuarioPermisoModels> listUsuarioPermisos = [];
            for(int i = 0; i<listSubmoduloPermisos.length; i++){
              for(int j = 0; j<listSubmoduloPermisos[i].permisos!.length; j++){
                if(listSubmoduloPermisos[i].permisos![j].activo){
                  print(listSubmoduloPermisos[i].permisos![j].nombre);
                  listUsuarioPermisos.add(UsuarioPermisoModels(
                      permisoId: listSubmoduloPermisos[i].permisos![j].idPermiso));
                }
              }
            }

            bool result = await UsuarioController().updateUsuario(usuario,listUsuarioPermisos,
                listEmpresasTemp.map((e) => e.idEmpresa?? "").toList());
            await Future.delayed(const Duration(milliseconds: 150), () {
              LoadingDialog.hideLoadingDialog(context);
            });
            if (result) {
              CustomAwesomeDialog(title: Texts.editSuccess, desc: '',
                  btnOkOnPress: () {Navigator.of(context).pop(usuario);},
                  btnCancelOnPress: () {}).showSuccess(context);
              Future.delayed(const Duration(milliseconds: 2500), () {
                Navigator.of(context).pop();
              });
            }else{
              CustomAwesomeDialog(title: Texts.errorSavingData, desc: Texts.errorUnexpected,
                btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
            }
          }catch(e){
            await Future.delayed(const Duration(milliseconds: 150), () {
              LoadingDialog.hideLoadingDialog(context);
            });
            ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
            String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
            CustomAwesomeDialog(title: Texts.errorSavingData, desc: error,
              btnOkOnPress: () {}, btnCancelOnPress: () {},).showError(context);
          }
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
      btnCancelOnPress: () {},).showQuestion(context);
  }
  void getUsuario(){
    _usernameController.text = widget.usuario.userName;
    _nombreController.text = widget.usuario.nombre;
    _apellidoPController.text = widget.usuario.apellidoPaterno;
    _apellidoMController.text = widget.usuario.apellidoMaterno?? "";
    _passwordController.text = widget.usuario.contrasenia;
    _passwordConfirmController.text = widget.usuario.contrasenia;
    selectedTipoUsuario = widget.usuario.tipoUsuario;
    if(widget.usuario.imagen!=null){
      base64String = widget.usuario.imagen!;
      imageBytes = base64.decode(base64String);
    }
    getAreas();
    for(int i = 0; i< areas.length; i++){
      for(int j = 0; j < areas[i].departamentos!.length; j++){
        for(int k = 0; k < areas[i].departamentos![j].puestos!.length; k++){
          if(areas[i].departamentos![j].puestos![k].idPuesto == widget.usuario.puestoId){
            selectedArea = areas[i].nombre;
            selectedPuestoModel = areas[i].departamentos![j].puestos![k];
            selectedDepartamentoModel = areas[i].departamentos![j];
            selectedAreaModel = areas[i];
            break;
          }
        }
      }
    }
    if(selectedArea!= "Selecciona el area"){
      for(int i = 0; i < selectedAreaModel.departamentos!.length; i++){
        listDepartamento.add(selectedAreaModel.departamentos![i].nombre);
      }
      for(int i = 0; i < selectedDepartamentoModel.puestos!.length; i++){
        listPuesto.add(selectedDepartamentoModel.puestos![i].nombre);
      }
      selectedDepartamento = selectedDepartamentoModel.nombre;
      selectedPuesto = selectedPuestoModel.nombre;
    }else{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomAwesomeDialog(title: 'El puesto no se encuentra en el sistema',
          desc: 'Se tendrá que actualizar su puesto', btnOkOnPress: () {}, btnCancelOnPress: () {},).showWarning(context);
      });
    }
    for(int i = 0; i<listSubmoduloPermisos.length; i++){
      for(int j = 0; j<listSubmoduloPermisos[i].permisos!.length; j++){
        for(int k = 0; k<widget.listUsuarioPermisos.length; k++){
          if(listSubmoduloPermisos[i].permisos![j].idPermiso == widget.listUsuarioPermisos[k].permisoId){
            listSubmoduloPermisos[i].activo = true;
            listSubmoduloPermisos[i].permisos![j].activo = true;
            break;
          }
        }
      }
    }
    setState(() {});
  }
  void getAreas(){
    areas = widget.areas;
    for(int i = 0; i<areas.length; i++){
      listAreas.add(areas[i].nombre);
    }
  }
  Future<void> deleteCompany(EmpresaModels empresa) async {
    //if(empresa.idEmpresa != empresaID){
    if(listEmpresasTemp.length > 1){
      CustomAwesomeDialog(title: Texts.askDeleteConfirm, desc: '', btnOkOnPress: () async {
        listEmpresasTemp.remove(empresa);
        setState(() {});
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.userErrorWCompany);
    }
  }
  void editCompany(EmpresaModels empresa) {
    if(empresa.idEmpresa != empresaID){
      List<EmpresaModels> empresasNoIncluidas = listEmpresas.where((empresa) => !listEmpresasTemp.contains(empresa)).toList();

      if(empresasNoIncluidas.isNotEmpty) {
        showDialog(context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Agregar empresa', style: TextStyle(color: theme.colorScheme.onPrimary),),
              content: SizedBox(width: size.width/2,
                child: ListView.builder(shrinkWrap: true,
                  itemCount: empresasNoIncluidas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(empresasNoIncluidas[index].nombre),
                      onTap: () {
                        setState(() {
                          listEmpresasTemp.remove(empresa);
                          listEmpresasTemp.add(empresasNoIncluidas[index]);
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }else{
        CustomSnackBar.showInfoSnackBar(context, Texts.companiesNoAvailable);
      }
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.companiesErrorDefault);
    }
  }
  Future<void> getEmpresaDefault() async {
    UserPreferences userPreferences = UserPreferences();
    empresaID = await userPreferences.getEmpresaId();
    listEmpresasTemp.addAll(listEmpresas.where((element) => empresasIDs.contains(element.idEmpresa)));
    setState(() {});
  }
  Future<String> reducirCalidadImagenBase64(String base64Str, {int calidad = 50}) async {
    // Decodificar la imagen base64 a Uint8List
    Uint8List bytes = base64.decode(base64Str);
    // Decodificar la imagen para obtener un objeto Image de 'image'
    img.Image? image = img.decodeImage(bytes);
    // Codificar la imagen a JPEG con una calidad reducida
    Uint8List jpeg = img.encodeJpg(image!, quality: calidad);
    // Convertir la imagen optimizada a base64
    return base64.encode(jpeg);
  }
}
