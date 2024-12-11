import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/usuarioController.dart';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/models/ConfigModels/puesto.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_decoration.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../../controllers/ConfigControllers/PermisoController/departamentoSubmoduloController.dart';
import '../../../models/ConfigModels/PermisoModels/departamentoSubmodulo.dart';
import '../../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';
import '../../../models/ConfigModels/area.dart';
import '../../../models/ConfigModels/empresa.dart';
import '../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../shared/widgets/my_expandable/my_expandable.dart';
class UserRegistrationScreen2 extends StatefulWidget {
  static String id = 'userRegistration';
  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<AreaModels> areas = [];
  List<EmpresaModels> listEmpresas = [];
  List<bool> listAjustesUsuarios = [];
  UserRegistrationScreen2({super.key, required this.listSubmoduloPermisos, required this.areas,
    required this.listEmpresas, required this.listAjustesUsuarios});
  @override
  _UserRegistrationScreen2State createState() => _UserRegistrationScreen2State();
}

class _UserRegistrationScreen2State extends State<UserRegistrationScreen2> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _key = GlobalKey();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoPController = TextEditingController();
  final _apellidoMController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _scrollController = ScrollController();
  final scrollController = ScrollController();
  late Size size;
  late ThemeData theme;

  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<String> listTipoUsuario = ["Selecciona el tipo de usuario","Usuario", "Administrador", "SuperAdmin"];
  List<String> listAreas = ["Selecciona el area"];
  List<String> listDepartamento = ["Selecciona el departamento"];
  List<String> listPuesto = ["Selecciona el puesto"];
  List<AreaModels> areas = [];

  String selectedTipoUsuario = "Selecciona el tipo de usuario";
  String selectedArea = "Selecciona el area";
  String selectedDepartamento = "Selecciona el departamento";
  String selectedPuesto = "Selecciona el puesto";
  String empresaID = "";

  late AreaModels selectedAreaModel;
  late DepartamentoModels selectedDepartamentoModel;
  late PuestoModels selectedPuestoModel;

  List<EmpresaModels> listEmpresas = [];
  List<EmpresaModels> listEmpresasTemp = [];
  SwiperController swiperController = SwiperController();
  List<String> titles = [
    'Datos del usuario',
    'Empresas del usuario',
  ];
  late TabController tabController;
  bool exitDialog = false;
  Image? image;Uint8List? imageBytes;
  String base64String = "";
  List<bool> listAjustes = [];
  @override
  void initState() {
    listAjustes = widget.listAjustesUsuarios;
    tabController = TabController(length: 2, vsync: this);
    listSubmoduloPermisos = widget.listSubmoduloPermisos;
    getAreas();
    listEmpresas = widget.listEmpresas;
    getEmpresaDefault();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);

    return bodyReload();
  }
  PreferredSizeWidget? appBarWidget(){
    return size.width > 600? MyCustomAppBarDesktop(title:"Alta de usuarios",color: theme.colorScheme.background,
        height: 25, borderRadius: const BorderRadius.all(Radius.circular(0)),padding: 10,
        context: context,backButton: false, defaultButtons: false,
    ) : null;
  }
  Future<void>  comprobarSave() async {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes manejar la lógica para guardar el área y sus departamentos
      // y los permisos del usuario
      if(selectedTipoUsuario != "Selecciona el tipo de usuario" && selectedArea != "Selecciona el area" &&
          selectedDepartamento != "Selecciona el departamento" && selectedPuesto != "Selecciona el puesto") {
        bool permiso = false;
        for(int i = 0; i<listSubmoduloPermisos.length; i++){
          for(int j = 0; j<listSubmoduloPermisos[i].permisos!.length; j++){
            if(listSubmoduloPermisos[i].permisos![j].activo){
              permiso = true;
              break;
            }
          }
        }
        if(permiso){
          CustomAwesomeDialog(title: Texts.askSaveConfirm, desc: '', btnOkOnPress: () async {
            _save();
          }, btnCancelOnPress: (){}).showQuestion(context);
        }else{
          if(listAjustes.first){
            CustomAwesomeDialog(title: 'No fue posible guardar el usuario', desc: 'El usuario no contiene permisos',
                btnOkOnPress: () async {}, btnCancelOnPress: (){}).showError(context);
          }else{
            CustomAwesomeDialog(title: Texts.askSaveConfirm, desc: 'El usuario no contiene permisos', btnOkOnPress: () async {
              _save();
            }, btnCancelOnPress: (){}).showWarning(context);
          }
        }
      }else{
        CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
      }
    }else{
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
  Future<void> moverTab(int index) async {
    tabController.index = index;
  }
  Widget bodyReload(){
    return WillPopScope(child: PressedKeyListener(
      keyActions: <LogicalKeyboardKey, Function()> {
        LogicalKeyboardKey.escape : () {
          CustomAwesomeDialog(title: Texts.alertExit,
              desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
              btnCancelOnPress: (){}).showQuestion(context);
        },
        LogicalKeyboardKey.f1 : () async {
          moverTab(0);
        },
        LogicalKeyboardKey.f2 : () async {
          moverTab(1);
        },
        LogicalKeyboardKey.f4 : () async {
          if(tabController.index == 0) {
            comprobarSave();
          }else{
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
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
            child: Text("Guardar (f4)", style: TextStyle(color: theme.colorScheme.onPrimary),),
            onPressed: () async {
              if(tabController.index == 0) {
                comprobarSave();
              }else{
                await moverTab(0);
                Future.delayed(const Duration(milliseconds: 400), () {
                  comprobarSave();
                });
              }
            },
          ),
          SizedBox(width: 10,),
          TextButton(
            style: TextButton.styleFrom(
              // Change icon color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              primary: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary, // Color de fondo
            ),
            onPressed: () {
              CustomAwesomeDialog(title: Texts.alertExit,
                  desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
                  btnCancelOnPress: (){}).showQuestion(context);
            }, child: Text("Cancelar"),
          )
        ],),
        body: size.width > 600? _landscapeBody2() : _portraitBody(),
      )), onWillPop: () async {
      bool salir = false;
      CustomAwesomeDialog(title: Texts.alertExit,
        desc: Texts.lostData, btnOkOnPress:(){salir  = true;},
        btnCancelOnPress: () {salir = false;},).showQuestion(context);
      return salir;
    });
  }
  List<Widget> userData(){
    return [
      _myContainer("DATOS DEL USUARIO"),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _rowDivided(
            Row(children: [
              Text("Nombre:"),
              SizedBox(width: 215, height: 35, child: MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "", textController: _nombreController,
                radius: 0,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor completa este campo';
                  }else if(value.length > 50){
                    return 'El nombre debe tener menos de 50 caracteres';
                  }
                  return null;
                },),)
            ],),
            Row(children: [
              Text("Apellido paterno:"),
              SizedBox(width: 170,height: 35,child: MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "", textController: _apellidoPController,
                radius: 0,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor completa este campo';
                  }else if(value.length > 50){
                    return 'El apellido paterno debe tener menos de 20 caracteres';
                  }
                  return null;
                },),)
            ],),
            Row(children: [
              Text("Apellido materno:"),
              SizedBox(width: 165,height: 35,child: MyTextfieldIcon(backgroundColor: theme.colorScheme.background,labelText: "", textController: _apellidoMController,
                radius: 0,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor completa este campo';
                  }else if(value.length > 50){
                    return 'El apellido materno debe tener menos de 20 caracteres';
                  }
                  return null;
                },),)
            ],)
          ),
          const SizedBox(height: 5,),
          _rowDivided(
            Row(children: [
              Text("Usuario:"),
              SizedBox(width: 220,height: 35,child: myTextfieldUserForm("", _usernameController, IconLibrary.iconPerson, false,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor completa este campo';
                    }else if(value.length > 20){
                      return 'El usuario debe tener menos de 20 caracteres';
                    }
                    return null;
                  }),)
            ],),
            Row(children: [
              Text("Contraseña:"),
              SizedBox(width: 200,height: 35,child: myTextfieldUserForm("", _passwordController, IconLibrary.iconLock, false,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor completa este campo';
                    }else if(value.length < 8){
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  }),)
            ],),
            Row(children: [
              Text("Confirmar contraseña:"),
              SizedBox(width: 140,height: 35,child: myTextfieldUserForm("", _passwordConfirmController, IconLibrary.iconLock, false,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor completa este campo';
                    }else if(value != _passwordController.text){
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  }),)
            ],),
          ),
        ],),
      ],),
      const SizedBox(height: 5,),
      Row(mainAxisAlignment: MainAxisAlignment.center,children: [
        Text("Fotografia:"),
        const SizedBox(width: 20,),
        SizedBox(width: size.width*.06,child: _imageField(),),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20,),
            Text("Seleccionar imagen"),
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () => _pickImage(),
            ),
          ],
        ),
      ],)
    ];
  }
  Widget myTextfieldUserForm(String labelText, TextEditingController controller, IconData icon, bool formatting,
      String? Function(String?)? validator){
    return MyTextfieldIcon(backgroundColor: theme.colorScheme.background,
        labelText: labelText,radius: 0,
        textController: controller, formatting: formatting, validator: validator
    );
  }
  Widget _imageField() {
    return Column(
      children: [
        imageBytes != null ? Image.memory(imageBytes!,
          height: size.width * 0.06, width: size.width *.06, fit: BoxFit.cover,)
            : Container(
          height: size.width * 0.06, width: size.width *.06, color: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.image, size: 40,),
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
        base64String = await reducirCalidadImagenBase64(base64.encode(imageBytes!));
        setState(() {});
      }else{
        CustomAwesomeDialog(title: Texts.errorSavingData, desc: 'La imagen debe tener un tamaño menor a 1MB',
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
          MyDropdown(
            textStyle: TextStyle(fontSize: 12.0, color: theme.colorScheme.onPrimary),
            dropdownItems: listTipoUsuario,
            selectedItem: selectedTipoUsuario,
            onPressed: (String? value) async {
              selectedTipoUsuario = value!;
              setPermisos();
              setState(() {});
              print(value);
            },
            enabled: true,
          )
        ],),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          const Text("Área"),
          MyDropdown(
            textStyle: TextStyle(fontSize: 12.0, color: theme.colorScheme.onPrimary),
            dropdownItems: listAreas,
            selectedItem: selectedArea,
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
            },
            enabled: true,
          )
        ],),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
            if(selectedArea != "Selecciona el area")...[
              const Text("Departamento"),
              MyDropdown(
                textStyle: TextStyle(fontSize: 12.0, color: theme.colorScheme.onPrimary),
                dropdownItems: listDepartamento,
                selectedItem: selectedDepartamento,
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
                  setPermisos();
                  setState(() {});
                  print(value);
                },
                enabled: true,
              )
            ]
        ],),
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          if(selectedDepartamento != "Selecciona el departamento")...[
            const Text("Puesto"),
            MyDropdown(
              textStyle: TextStyle(fontSize: 12.0, color: theme.colorScheme.onPrimary),
              dropdownItems: listPuesto,
              selectedItem: selectedPuesto,
              onPressed: (String? value) {
                selectedPuesto = value!;
                for(int i = 0; i<selectedDepartamentoModel.puestos!.length; i++){
                  if(selectedDepartamentoModel.puestos![i].nombre == value){
                    selectedPuestoModel = selectedDepartamentoModel.puestos![i];
                    break;
                  }
                }
                setState(() {});
                print(value);
              },
              enabled: true,
            )
          ]
        ],),
      ),
    ];
  }
  List<Widget> permisos(){
    return [
      _myContainer("PERMISOS"),
      Wrap(alignment: WrapAlignment.start,
        spacing: 10, runSpacing: 10, children: _buildSubmoduloPermiso(listSubmoduloPermisos),)
    ];
  }
  List<Widget> _buildSubmoduloPermiso(List<SubmoduloPermisos> listSubmoduloPermisos){
    List<Widget> departments = [];
    for (SubmoduloPermisos submoduloPermiso in listSubmoduloPermisos){
      departments.add(_myContainerPermisos2(submoduloPermiso.nombreSubmodulo, submoduloPermiso, 270));
    }
    return departments;
  }
  List<Widget> userForm(){
    return [
      Form(
          key: _formKey,
          child: Scrollbar(controller: _scrollController,thumbVisibility: true,
            child: FadingEdgeScrollView.fromSingleChildScrollView(child:
            SingleChildScrollView(controller: _scrollController,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child: Column(
                children: <Widget>[
                  ...userData(),
                  ...jobData(),
                  ...permisos(),
                ],
              ),),)),)
      ),
      Container(padding: const EdgeInsets.symmetric(horizontal: 25),
        child:SingleChildScrollView(child: Column(children: [
          _myContainer("ASIGNAR EMPRESA(S)"),
          encabezados(),
          Container(height: size.height*0.55-20,
              decoration: BoxDecoration(color: theme.primaryColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
              ),
              child:FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: listEmpresasTemp.length,
                  itemBuilder: (context, index) {
                    return _card(listEmpresasTemp[index]);
                  },
                ),
              ))
        ],),),)
    ];
  }
  Widget encabezados(){
    return Container(height: 50,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 15,),
                SizedBox(width: size.width/5, child: const Text("Nombre", textAlign: TextAlign.center,style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ),)),
                SizedBox(width: size.width/5, child: const Text("RFC",  textAlign: TextAlign.center,  style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ),)),
                listAjustes.last? IconButton(onPressed: (){
                  List<EmpresaModels> empresasNoIncluidas = listEmpresas.where((empresa) => !listEmpresasTemp.contains(empresa)).toList();

                  if(empresasNoIncluidas.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Agregar empresa', style: TextStyle(color: theme.colorScheme.onPrimary),),
                          content: SizedBox(
                            width: size.width/2,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: empresasNoIncluidas.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(empresasNoIncluidas[index].nombre),
                                  onTap: () {
                                    // Agrega la empresa seleccionada a listEmpresasTemp
                                    setState(() {
                                      listEmpresasTemp.add(empresasNoIncluidas[index]);
                                    });
                                    // Cierra el diálogo
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
                    CustomSnackBar.showInfoSnackBar(context, "No hay empresas disponibles, todas han sido asignadas");
                  }
                }, icon: const Icon(IconLibrary.iconAdd),
                  hoverColor: theme.colorScheme.background, style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
                    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
                    ),
                  ),
                ) : const SizedBox(),
                const SizedBox(width: 15,),
              ],
            ))
    );
  }
  Widget _card(EmpresaModels empresa){
    return MySwipeTileCard(radius: 0,
      colorBasico: theme.colorScheme.background, iconColor: theme.colorScheme.onPrimary,
      containerB: Padding(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
        SizedBox(width: size.width/5,child: Text(empresa.nombre, textAlign: TextAlign.center, style: const TextStyle( fontSize: 13.5, fontWeight: FontWeight.normal ), ),),
        SizedBox(width: size.width/5,child: Text(empresa.rfc.trim()!=""?empresa.rfc : "Sin RFC",
          textAlign: TextAlign.center, style: const TextStyle( fontSize: 13.5, fontWeight: FontWeight.normal )),),
        const SizedBox(width: 30,),
        const Icon(IconLibrary.iconDrag, size: 15, color: Colors.grey,),
      ],),),
      onTapRL: (){deleteCompany(empresa);},
      onTapLR: (){editCompany(empresa);},
      // Agrega los demás datos del usuario según sea necesario
    );
  }
  Widget _landscapeBody2(){
    return Column(children: [
      TabBar(
        controller: tabController,// Color de fondo del TabBar
        labelColor: theme.colorScheme.onPrimary, // Color de las pestañas seleccionadas
        unselectedLabelColor: Colors.grey[400], // Color de las pestañas no seleccionadas
        labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        padding: EdgeInsets.symmetric(horizontal: size.width*.15),
        tabs: const [Tab(text: "Datos Generales"), Tab(text: "Empresas del Usuario")],
      ),
      Expanded( // Agrega este widget
        child: SizedBox(height: size.height-140,width: size.width,child:
        TabBarView(controller: tabController,
          children: userForm(),),
        ),
      ),
    ],);
  }
  Widget _myContainer(String text){
    return Container(width: size.width/3,decoration: BoxDecoration(borderRadius: BorderRadius.circular(0),),
      padding: const EdgeInsets.only(top: 5),
      child: Center(
        child: Column(children: [
          Text(text, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
        ],)
      ),
    );
  }
  Widget _myContainerPermisos2(String text,SubmoduloPermisos groupPermiso,double width){
    return SizedBox(width: width,child: MyExpandable(backgroundColor: theme.primaryColor, isExpanded: false, borderRadius: 0,
      header: Padding(padding: const  EdgeInsets.all(8.0),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          Text(text, style:const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),),
          Switch(
            hoverColor: theme.colorScheme.onSecondaryContainer, inactiveTrackColor: theme.colorScheme.onSecondaryContainer,
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
      expanded: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(children: [
          Divider(thickness: 2,color: theme.colorScheme.secondary,),
          for(int i = 0; i<groupPermiso.permisos!.length; i++)...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[
              SizedBox(width: width-15,child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                Tooltip(
                  waitDuration: const Duration(milliseconds: 500),
                  message: groupPermiso.permisos![i].descripcion,
                  child: SizedBox(width: width-75,child: Text(groupPermiso.permisos![i].nombre),),
                ),
                Switch(
                  hoverColor: theme.colorScheme.onSecondaryContainer,
                  inactiveTrackColor: theme.colorScheme.onSecondaryContainer,
                  activeTrackColor: theme.colorScheme.secondary,
                  value: groupPermiso.permisos![i].activo,
                  onChanged: (value) {
                    _updatePermiso(value, groupPermiso, i);
                  },
                ),
              ],),),
            ])
          ]
        ],),
      ),));
  }
  Widget _rowDivided(Widget widgetL, Widget widgetC,Widget widgetR){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width * 0.20, child: widgetL,),
        const SizedBox(width: 3,),
        SizedBox(width: size.width * 0.20,child: widgetC,),
        const SizedBox(width: 3,),
        SizedBox(width: size.width * 0.20,child: widgetR,),
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
    return const Column(children: [
      Text("data")
    ],);
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
    try{
      UsuarioController usuarioController = UsuarioController();
      bool check = await usuarioController.checkUser(_usernameController.text.trim(),
          _passwordController.text.trim());
      if(!check){
        UsuarioModels usuario = UsuarioModels(
          nombre: _nombreController.text.trim(),
          apellidoPaterno: _apellidoPController.text.trim(),
          apellidoMaterno: _apellidoMController.text.trim(),
          userName: _usernameController.text.trim(),
          contrasenia: _passwordController.text.trim(),
          tipoUsuario: selectedTipoUsuario,
          estatus: true,
          puestoId: selectedPuestoModel.idPuesto,/// ojito aqui
          imagen: base64String,
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
        //listUsuarioPermisos.add(UsuarioPermisoModels(permisoId: "3E33716E-6B9B-479E-8999-81656B88CF49"));
        bool result = await usuarioController.saveUsuarioConPermiso(usuario, listUsuarioPermisos,
            listEmpresasTemp.map((e) => e.idEmpresa?? "").toList());
        LoadingDialog.hideLoadingDialog(context);

        if (result) {
          CustomAwesomeDialog(title: Texts.addSuccess,
              desc: '', btnOkOnPress: () {
                Navigator.of(context).pop(usuario);
              }, btnCancelOnPress: () {}).showSuccess(context);
          Future.delayed(const Duration(milliseconds: 2500), () {
            Navigator.of(context).pop();
          });
        } else {
          CustomAwesomeDialog(title: Texts.errorSavingData,
              desc: 'Error inesperado. Contacte soporte', btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
        }
      }else{
        CustomAwesomeDialog(title: Texts.errorSavingData,
            desc: Texts.errorNameUser,
            btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
      }
    }catch(e){
      ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
      String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: Texts.errorSavingData,
          desc: error, btnOkOnPress: () {
            Navigator.of(context).pop();
          }, btnCancelOnPress: () {}).showError(context);
      print('Error al enviar la solicitud: $e');
    }
  }
  void getAreas(){
    areas = widget.areas;
    for(int i = 0; i<areas.length; i++){
      listAreas.add(areas [i].nombre);
    }
  }

  Future<List<DepartamentoSubmodulo>> getDepartamentoSubmodulo(String idDepartamento) async {
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];
    listDepartamentoSubmodulo = await DepartamentoSubmoduloController().getDepartamentoSubmodulo(idDepartamento);
    return listDepartamentoSubmodulo;
  }
  Future<void> setPermisos() async {
    if(selectedTipoUsuario != "Selecciona el tipo de usuario" && selectedDepartamento != "Selecciona el departamento"){
      List<DepartamentoSubmodulo> listDepartamentoSubmodulo = await getDepartamentoSubmodulo(selectedDepartamentoModel.idDepartamento!);
      for(int i = 0; i<listDepartamentoSubmodulo.length; i++){
        for(int j = 0; j<listSubmoduloPermisos.length; j++){
          if(listDepartamentoSubmodulo[i].subModuloId == listSubmoduloPermisos[j].submoduloId){
            listSubmoduloPermisos[j].activo = true;
            for(int k = 0; k<listSubmoduloPermisos[j].permisos!.length; k++){
              if(selectedTipoUsuario == "SuperAdmin") {
                listSubmoduloPermisos[j].permisos![k].activo = true;
              }else if(selectedTipoUsuario == "Administrador"){
                if(listSubmoduloPermisos[j].permisos![k].tipoUsuario == "Administrador" || listSubmoduloPermisos[j].permisos![k].tipoUsuario == "Usuario") {
                  listSubmoduloPermisos[j].permisos![k].activo = true;
                }
              }else if(selectedTipoUsuario == "Usuario"){
                if(listSubmoduloPermisos[j].permisos![k].tipoUsuario == "Usuario") {
                  listSubmoduloPermisos[j].permisos![k].activo = true;
                }
              }
            }
          }
        }
      }
    }
    setState(() {});
  }
  Future<void> deleteCompany(EmpresaModels empresa) async {
    if(listEmpresasTemp.length > 1){
      CustomAwesomeDialog(title: Texts.askDeleteConfirm, desc: '', btnOkOnPress: () async {
        listEmpresasTemp.remove(empresa);
        setState(() {});
      }, btnCancelOnPress: (){}).showQuestion(context);
    }else{
      CustomSnackBar.showWarningSnackBar(context, "No puedes eliminar todas las empresas, es necesario al menos una");
    }
  }
  void editCompany(EmpresaModels empresa) {
    List<EmpresaModels> empresasNoIncluidas = listEmpresas.where((empresa) => !listEmpresasTemp.contains(empresa)).toList();

    if(empresasNoIncluidas.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Agregar empresa'),
            content: SizedBox(
              width: size.width/2,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: empresasNoIncluidas.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(empresasNoIncluidas[index].nombre),
                    onTap: () {
                      // Agrega la empresa seleccionada a listEmpresasTemp
                      setState(() {
                        listEmpresasTemp.remove(empresa);
                        listEmpresasTemp.add(empresasNoIncluidas[index]);
                      });
                      // Cierra el diálogo
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
      CustomSnackBar.showInfoSnackBar(context, "No hay empresas disponibles, todas han sido asignadas");
    }
  }
  Future<void> getEmpresaDefault() async {
    UserPreferences userPreferences = UserPreferences();
    empresaID = await userPreferences.getEmpresaId();
    listEmpresasTemp.add(listEmpresas.firstWhere((element) => element.idEmpresa == empresaID));
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
