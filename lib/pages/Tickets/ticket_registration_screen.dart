import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Tickets/CustomeAwesomeDialogTickets.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_decoration.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';
import '../../controllers/ConfigControllers/PermisoController/departamentoSubmoduloController.dart';
import '../../controllers/TicketController/ticketController.dart';
import '../../models/ConfigModels/PermisoModels/departamentoSubmodulo.dart';
import '../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';
import '../../models/ConfigModels/area.dart';
import '../../models/ConfigModels/departamento.dart';
import '../../models/ConfigModels/empresa.dart';
import '../../models/ConfigModels/puesto.dart';
import '../../models/ConfigModels/usuario.dart';
import '../../models/TicketsModels/ticket.dart';
import 'loadingDialogTickets.dart';

class ticketRegistrationScreen extends StatefulWidget {
  static String id = 'ticketRegistration';
  List<SubmoduloPermisos>? listSubmoduloPermisos = [];
  List<AreaModels> areas = [];
  ticketRegistrationScreen({super.key, this.listSubmoduloPermisos, required this.areas});
  @override
  _ticketRegistrationScreenState createState() => _ticketRegistrationScreenState();
}

class _ticketRegistrationScreenState extends State<ticketRegistrationScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController(), _tituloController = TextEditingController();
  final _scrollController = ScrollController(), scrollController = ScrollController();
  late Size size;late ThemeData theme;
  List<PlatformFile> selectedFiles = [];
  FilePickerResult? result;

  Uint8List? imageBytes1, imageBytes2, imageBytes3;
  Image? image1,image2, image3;
  String? selectedFileName, selectedFileType;
  UsuarioModels? selectedUsuarioModel;
  GlobalKey globalKey = GlobalKey();

  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<AreaModels> areas = [];
  List<EmpresaModels> listEmpresas = [], listEmpresasTemp = [];

  List<String> listUsuarios = ["Selecciona el usuario (opcional)"], listAreas = ["Selecciona el Area"],
      listDepartamento = ["Selecciona el Departamento"], listPuesto = ["Selecciona el puesto"],
      titles = ['Datos del usuario', 'Empresas del usuario',], selectedFileTypes = [],
      listUrgencia = ["Selecciona la prioridad", "Importante", "Urgente", "No urgente", "Pregunta"],
      selectedFileNames = [];

  String selectedUrgencia = "Selecciona la prioridad", selectedUsuario = "Selecciona el usuario (opcional)",
      title = "et", selectedArea = "Selecciona el Area", selectedDepartamento = "Selecciona el Departamento",
      selectedPuesto = "Selecciona el puesto", empresaID = "", base64String1 = "", base64String2 = "", base64String3 = "";

  late AreaModels selectedAreaModel;
  late DepartamentoModels selectedDepartamentoModel;
  late PuestoModels selectedPuestoModel;
  bool exitDialog = false;
  late AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    getAreas();
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    super.initState();
  }
  @override
  void dispose(){
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return bodyReload();
  }
  PreferredSizeWidget? appBarWidget() {
    return MyCustomAppBarDesktop(title: "Alta de ticket", textColor: Colors.white,
        backButtonWidget: TextButton.icon(icon: const Icon(IconLibrary.iconX, color: Colors.red,),
          label: const Text("Cerrar", style: TextStyle(color: Colors.white,),),
          style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.transparent,),
          onPressed: () {
            CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData, width: !Platform.isWindows? size.width*0.9 : null,
                btnOkOnPress: () {Navigator.of(context).pop();}, btnCancelOnPress: () {}).showQuestion(context);
          },
        ), color: ColorPalette.ticketsColor, height: 45,
        suffixWidget: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor4, elevation: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Guardar  ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              Container(padding: const EdgeInsets.all(.5),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ColorPalette.ticketsColor2, width: 3,),)),
                  child: const Text(' f4 ', style: TextStyle( color: Colors.black),)),
              Icon(IconLibrary.iconSave, color: ColorPalette.ticketsColor, size: size.width *.015, ),
            ],
          ),
          onPressed: () async {comprobarSave();},
        ),
        context: context, backButton: true, defaultButtons: false,

        borderRadius: const BorderRadius.all(Radius.circular(25)));
  }

  Future<void> comprobarSave() async {
    if (_formKey.currentState!.validate()) {
      if (selectedArea != "Selecciona el Area" && selectedDepartamento != "Selecciona el Departamento" &&
          selectedUrgencia != "Selecciona la prioridad" && _descripcionController.text.isNotEmpty && _tituloController.text.isNotEmpty){
        CustomAwesomeDialogTickets(title: Texts.askSaveConfirm, desc: '', width: !Platform.isWindows? size.width*0.9 : null,
            btnOkOnPress: () async {_save();}, btnCancelOnPress: () {}).showQuestion(context);
      } else {
        CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
      }
    } else {
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }
  void getAreas() {
    areas = widget.areas;
    for (int i = 0; i < areas.length; i++) {
      listAreas.add(areas[i].nombre);
    }
  }

  Future<void> _save() async {
    try {
      TicketsModels ticket = TicketsModels(
        UsuarioAsignadoID: selectedUsuarioModel != null ? selectedUsuarioModel!.idUsuario!
            : "", DepartamentoID: selectedDepartamentoModel.idDepartamento!,
        Titulo: _tituloController.text, Descripcion: _descripcionController.text,
        Estatus: 'Abierto', Prioridad: selectedUrgencia, Imagen1: base64String1,
        Imagen2: base64String2, Imagen3: base64String3, UsuarioID: '',);
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.savingData);

      TicketController ticketController = TicketController();
      bool save = await ticketController.saveTickets(ticket);
      if (save) {
        if(Platform.isAndroid) {
          Vibration.vibrate(pattern: [400, 200, 350, 250]);
        }
        try{
          await player.setSource(AssetSource('notification.mp3'));
          await player.resume();
        }catch(e){
          print(e);
        }
        CustomAwesomeDialogTickets(title: Texts.addSuccess, desc: '', width: !Platform.isWindows? size.width*0.9 : null,
                btnOkOnPress: () {
                  LoadingDialogTickets.hideLoadingDialogTickets(context);
                  Navigator.of(context).pop();
                }, btnCancelOnPress: () {}).showSuccess(context);
        Future.delayed(const Duration(milliseconds: 2500), () {
          LoadingDialogTickets.hideLoadingDialogTickets(context);
          Navigator.of(context).pop();
        });
      } else {
        Vibration.vibrate(pattern: [100, 1200]);
        LoadingDialogTickets.hideLoadingDialogTickets(context);
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: 'Error al guardar el ticket',
          btnOkOnPress: () {}, btnCancelOnPress: () {}, width: !Platform.isWindows? size.width*0.9 : null).showError(context);
      }
    } catch (e) {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
    }
  }

  Widget bodyReload() {
    return SizedBox(height: 700,
      child: WillPopScope(
          child: PressedKeyListener(
              keyActions: <LogicalKeyboardKey, Function()>{
                LogicalKeyboardKey.escape: () {
                  CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData,
                      btnOkOnPress: () {Navigator.of(context).pop();},
                      btnCancelOnPress: () {}, width: !Platform.isWindows? size.width*0.9 : null).showQuestion(context);
                },
                LogicalKeyboardKey.f4: () async {comprobarSave();},
              },
              Gkey: globalKey,
              child: Scaffold(backgroundColor: ColorPalette.ticketsColor4,
                appBar: size.width > 600 ? appBarWidget() : MyCustomAppBarMobile(
                  confirm: true, tickets: true,
                  backgroundColor: ColorPalette.ticketsColor, color: Colors.white,
                  title: "Alta de ticket", context: context, backButton: true,),
                floatingActionButton: size.width < 600 ? buttonSave() : null,
                body: size.width > 600 ? _landscapeBody2() : _portraitBody(),
              )),
          onWillPop: () async {
            bool salir = false;
            CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData,
              btnOkOnPress: () {Navigator.of(context).pop();},
              btnCancelOnPress: () {salir = false;}, width: !Platform.isWindows? size.width*0.9 : null,).showQuestion(context);
            return salir;
          }),
    );
  }

  List<Widget> ticketData() {
    return [
      _myContainer("DATOS DEL TICKET"),
      const Text("Titulo de ticket", style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 8,),
      ConstrainedBox(constraints: BoxConstraints(maxWidth: 500),
        // Ajusta el ancho máximo según tus necesidades
        child: MyTextfieldIcon(floatingLabelStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          textStyle: TextStyle(color: Colors.black54, fontSize: 12), cursorColor: Colors.black54,
          textColor: Colors.black54, colorLineBase: Colors.black54, colorLine: Colors.black54,
          backgroundColor: ColorPalette.ticketsSelectedColor, labelText: "Ingresa titúlo del ticket",
          textController: _tituloController, minLines: 1, maxLines: 3, maxLength: 30,
        ),
      ),
      const SizedBox(height: 10,),
      _rowDivided(Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Area", style: TextStyle(color: Colors.black),),
            const SizedBox(height: 8,),
            MyDropdown(dropdownColor: ColorPalette.ticketsColor8,
              textStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: size.width < 500? 12: null),
              dropdownItems: listAreas, selectedItem: selectedArea,
              suffixIcon: const Icon(IconLibrary.iconBusiness, color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedArea = value!;
                listDepartamento = ["Selecciona el Departamento"];
                selectedDepartamento = "Selecciona el Departamento";
                selectedUsuario = "Selecciona el usuario (opcional)";
                selectedUrgencia = "Selecciona la prioridad";

                if (value != "Selecciona el Area") {
                  for (int i = 0; i < areas.length; i++) {
                    if (areas[i].nombre == value) {
                      selectedAreaModel = areas[i];
                      break;
                    }
                  }
                  for (int j = 0; j < selectedAreaModel.departamentos!.length; j++) {
                    listDepartamento.add(selectedAreaModel.departamentos![j].nombre);
                  }
                }
                setState(() {});
              }, enabled: true,
            )
          ],
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Departamento", style: TextStyle(color: Colors.black),),
            const SizedBox(height: 8,),
            MyDropdown(dropdownColor: ColorPalette.ticketsColor8, textStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: size.width < 500? 12: null),
              dropdownItems: listDepartamento, selectedItem: selectedDepartamento,
              suffixIcon: const Icon(IconLibrary.iconGroups, color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedDepartamento = value!;
                if (value != "Selecciona el Departamento") {
                  listUsuarios = ["Selecciona el usuario (opcional)"];
                  selectedUsuario = "Selecciona el usuario (opcional)";
                  for (int j = 0; j < selectedAreaModel.departamentos!.length; j++) {
                    if (selectedAreaModel.departamentos![j].nombre == value) {
                      selectedDepartamentoModel = selectedAreaModel.departamentos![j];
                      break;
                    }
                  }
                  for (int k = 0; k < selectedDepartamentoModel.usuarios!.length; k++) {
                    listUsuarios.add(selectedDepartamentoModel.usuarios![k].nombre + ' ' +
                        selectedDepartamentoModel.usuarios![k].apellidoPaterno + ' ' +
                        (selectedDepartamentoModel.usuarios![k].apellidoMaterno ?? ""));
                  }
                }
                setState(() {});
                print(value);
              },
              enabled: selectedArea != "Selecciona el Area",
            )
          ],
        ),
      ),
      const SizedBox(height: 10,),
      _rowDivided(Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Usuario", style: TextStyle(color: Colors.black),),
            const SizedBox(height: 8,),
            MyDropdown(dropdownColor: ColorPalette.ticketsColor8,
              textStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: size.width < 500? 12: null),
              dropdownItems: listUsuarios, selectedItem: selectedUsuario,
              suffixIcon: const Icon(IconLibrary.iconUser, color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedUsuario = value!;
                for (int j = 0; j < selectedDepartamentoModel.usuarios!.length; j++) {
                  if (selectedDepartamentoModel.usuarios![j].nombre + " " +
                      selectedDepartamentoModel.usuarios![j].apellidoPaterno + " " +
                      (selectedDepartamentoModel.usuarios![j].apellidoMaterno ?? "") == value) {
                    selectedUsuarioModel = selectedDepartamentoModel.usuarios![j];
                    break;
                  }
                }
                setState(() {});
                print(value);
              },
              enabled: selectedDepartamento != "Selecciona el Departamento" && selectedArea != "Selecciona el Area",
            )
          ],
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Prioridad", style: TextStyle(color: Colors.black),),
            const SizedBox(height: 8,),
            MyDropdown(dropdownColor: ColorPalette.ticketsColor8,
              textStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: size.width < 500? 12: null),
              dropdownItems: listUrgencia, selectedItem: selectedUrgencia,
              suffixIcon: const Icon(IconLibrary.iconDensity, color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedUrgencia = value!;
                setState(() {});
                print(value);
              },
              enabled: selectedDepartamento != "Selecciona el Departamento" && selectedArea != "Selecciona el Area",
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> jobData() {
    return [
      _myContainer("DETALLES DEL TICKET"),
      if(size.width<500)...[
        descripcionTicket(),
        const SizedBox(height: 10,),
        evidenciasTicket(),
      ]else...[
        _rowDivided(descripcionTicket(), evidenciasTicket(),),
      ]
    ];
  }
  Widget descripcionTicket(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Descripción de Ticket", style: TextStyle(color: Colors.black54)),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500),
          // Ajusta el ancho máximo según tus necesidades
          child: MyTextfieldIcon(textStyle: const TextStyle(color: Colors.black54, fontSize: 12),
            cursorColor: Colors.black54, textColor: Colors.black54, colorLineBase: Colors.black54,
            colorLine: Colors.black54, backgroundColor: ColorPalette.ticketsSelectedColor, labelText: "",
            textController: _descripcionController, minLines: 2, maxLines: 2, maxLength: 450,
          ),
        ),
      ],
    );
  }
  Widget evidenciasTicket(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Evidencias del ticket", style: TextStyle(color: Colors.black54),),
        const SizedBox(height: 8,),
        if(size.width<500)...[
          Column(children: [
            _archives(),
            Wrap(children: [
              if (imageBytes1 == null || imageBytes2 == null || imageBytes3 == null) ...[
                buttonAttach(),
              ],
              const SizedBox(width: 2),
              if (imageBytes1 != null || imageBytes2 != null || imageBytes3 != null) ...[
                buttonDelete(),
              ],
            ],)
          ],)
        ]else...[
          Wrap(runSpacing: 5,children: [
            ...images(),
            if (imageBytes1 == null || imageBytes2 == null || imageBytes3 == null) ...[
              buttonAttach(),
            ],
            const SizedBox(width: 2),
            if (imageBytes1 != null || imageBytes2 != null || imageBytes3 != null) ...[
              buttonDelete(),
            ],
          ],)
        ]
      ],
    );
  }
  List<Widget> images(){
    return [
      if (imageBytes1 != null) ...[
        Image.memory(imageBytes1!, width: 100, height: 100),
        const SizedBox(width: 10),
      ],
      if (imageBytes2 != null) ...[
        Image.memory(imageBytes2!, width: 100, height: 100),
        const SizedBox(width: 10),
      ],
      if (imageBytes3 != null) ...[
        Image.memory(imageBytes3!, width: 100, height: 100),
        const SizedBox(width: 10),
      ],
    ];
  }
  Widget _archives() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageWidget(base64String1),
        imageWidget(base64String2),
        imageWidget(base64String3),
      ],
    );
  }
  Widget imageWidget(String? image) {
    Uint8List? imageBytes;
    if (image != null) {
      imageBytes = base64Decode(image);
    }
    return  image != null && image != ""? GestureDetector(onTap: (){
      showDialog(context: context,
        builder: (context) => Dialog(
          surfaceTintColor: theme.colorScheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
          child: Container(
            width: size.width-50, height: size.height-200, padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              SizedBox(width: size.width-50, height: size.height-250,
                child: PhotoView(
                  backgroundDecoration: BoxDecoration(color: theme.colorScheme.background),
                  imageProvider: imageFromBase64String2(image),
                ),
              ),
            ],),
          ),
        ),
      );
    },child: SizedBox(width: 100, height: 100, child:  Image.memory(imageBytes!, fit: BoxFit.cover,),),)
        : const SizedBox();
  }
  ImageProvider imageFromBase64String2(String? base64String) {
    try {
      if(base64String == null){
        return const AssetImage('assets/avatarxl.png'); // Reemplaza esto con la ruta a tu imagen predeterminada
      } else {
        List<int> bytes = base64.decode(base64String);
        Uint8List uint8List = Uint8List.fromList(bytes);
        return MemoryImage(uint8List);
      }
    } catch (e) {
      return const AssetImage('assets/avatarxl.png'); // Reemplaza esto con la ruta a tu imagen de error
    }
  }
  Widget buttonDelete(){
    return ElevatedButton.icon(icon: const Icon(Icons.cancel), label: const Text('Eliminar'), // Texto del botón
        onPressed: () {
          setState(() {
            result = null; imageBytes1 = null; imageBytes2 = null; imageBytes3 = null;
            base64String1 = ""; base64String2 = ""; base64String3 = "";
            image1 = null; image2 = null; image3 = null;
          });
          print(result);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, // Color de fondo del botón
          onPrimary: Colors.white, // Color del texto e icono del botón
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), // Radio del borde del botón
          ),
        ),
      );
  }
  Widget buttonAttach(){
    return ElevatedButton.icon(
      icon: Icon(Icons.attach_file), // Icono del botón
      label: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 300, maxWidth: 200),
        child: Wrap(children: [
          Text(selectedFileNames.isEmpty ? 'Seleccionar archivos' : selectedFileNames.join(', '),),
        ],
        ),
      ),
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['jpg', 'png'], allowMultiple: true);

        if (result != null) {
          if (result.files.length > 3) {
            CustomSnackBar.showInfoSnackBar(context, "Solo se permiten 3 archivos");
            return;
          }
          int maxSize = 1024*1024;
          var imageBytes;
          var image;
          String base64String = "";
          for (int i = 0; i < result.files.length; i++) {
            PlatformFile file = result.files[i];
            print(file.path);
            final File imageFile = File(file.path.toString());
            int fileSize = await imageFile.length();

            if(fileSize <= maxSize){
              imageBytes = await imageFile.readAsBytes();
              image = Image.memory(imageBytes!);
              base64String = await reducirCalidadImagenBase64(base64.encode(imageBytes!));
              setState(() {});
            }else{
              CustomAwesomeDialogTickets(title: Texts.errorSavingImage, desc: '${Texts.imageSizeMb}\nArchivo: ${file.name}',
                  btnOkOnPress: () {}, btnCancelOnPress: () {}, width: !Platform.isWindows? size.width*0.9 : null,).showError(context);
              continue;
            }
            if ((i == 0 && imageBytes1 == null) || (imageBytes1 != null && imageBytes2 != null && imageBytes3 != null)) {
              imageBytes1 = imageBytes;
              image1 = image;
              base64String1 = base64String;
            } else if (i == 1 && imageBytes2 == null || (imageBytes1 != null && imageBytes2 == null)) {
              imageBytes2 = imageBytes;
              image2 = image;
              base64String2 = base64.encode(imageBytes2!);
            } else if (i == 2 || (imageBytes1 != null && imageBytes2 != null && imageBytes3 == null)) {
              imageBytes3 = imageBytes;
              image3 = image;
              base64String3 = base64.encode(imageBytes3!);
            }
            setState(() {var base64String = base64.encode(imageBytes);});
          }
        } else {
          // El usuario canceló la selección de archivos
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor,
        onPrimary: Colors.white,
        // Color del texto e icono del botón
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), // Radio del borde del botón
        ),
      ),
    );
  }

  List<Widget> userForm() {
    return [
      Form(key: _formKey,
          child: Scrollbar(controller: _scrollController, thumbVisibility: true,
            child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(controller: _scrollController,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: <Widget>[
                    ...ticketData(),
                    ...jobData(),
                  ],
                ),
              ),
            )),
          )),
    ];
  }

  Widget _landscapeBody2() {
    return SizedBox(height: size.height, width: size.width,
      child: Column(children: [...userForm()],),
    );
  }

  Widget _myContainer(String text) {
    return Container(width: size.width < 500? size.width * 0.9 : size.width * 0.4,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
      padding: const EdgeInsets.all(14.0),
      child: Center(
          child: Column(
        children: [
          Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const Divider(thickness: 2, color: ColorPalette.ticketsColor,)
        ],
      )),
    );
  }

  Widget _rowDivided(Widget widgetL, Widget widgetR) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width < 500? size.width * 0.46 : size.width * 0.35, child: widgetL,),
        SizedBox(width: size.width < 500? size.width * 0.46 : size.width * 0.35, child: widgetR,),
      ],
    );
  }

  Widget _portraitBody() {
    return SizedBox(height: size.height, width: size.width,
      child: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 5,),
        ...userForm(),
      ],),)
    );
  }

  Future<List<DepartamentoSubmodulo>> getDepartamentoSubmodulo(String idDepartamento) async {
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];
    listDepartamentoSubmodulo = await DepartamentoSubmoduloController().getDepartamentoSubmodulo(idDepartamento);
    return listDepartamentoSubmodulo;
  }
  Widget buttonSave(){
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(primary: ColorPalette.ticketsColor,
          elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () async {HapticFeedback.vibrate();comprobarSave();},icon: const Icon(Icons.save, color: Colors.white,),
      label: const Text("Guardar", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),),
    );
  }
  IconData _getIconForFileType(String? fileType) {
    if (fileType == null) {
      return Icons.attach_file_rounded;
    } else if (fileType.startsWith('image/')) {
      return Icons.image;
    } else if (fileType.startsWith('video/')) {
      return Icons.videocam;
    } else if (fileType.startsWith('audio/')) {
      return Icons.audiotrack;
    } else if (fileType.startsWith('text/')) {
      return Icons.text_snippet;
    } else {
      return Icons.file_present;
    }
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
