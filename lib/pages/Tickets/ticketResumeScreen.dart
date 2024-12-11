import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Tickets/CustomeAwesomeDialogTickets.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:photo_view/photo_view.dart';
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

class ticketResumeScreen extends StatefulWidget {
  static String id = 'ticketRegistration';
  List<SubmoduloPermisos>? listSubmoduloPermisos;
  List<AreaModels> areas;
  TicketsModels ticket;
  ticketResumeScreen({super.key, this.listSubmoduloPermisos, required this.areas, required this.ticket});

  @override
  _ticketResumeScreenState createState() => _ticketResumeScreenState();
}

class _ticketResumeScreenState extends State<ticketResumeScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _tituloController = TextEditingController();
  final _scrollController = ScrollController(), scrollController = ScrollController();
  late Size size;late ThemeData theme;
  List<PlatformFile> selectedFiles = [];
  List<String> selectedFileNames = [], selectedFileTypes = [];
  FilePickerResult? result;

  Uint8List? imageBytes1, imageBytes2, imageBytes3;
  Image? image1, image2, image3;
  String base64String1 = "", base64String2 = "", base64String3 = "";

  UsuarioModels? selectedUsuarioModel;
  String? selectedFileName;
  String? selectedFileType;
  GlobalKey globalKey = GlobalKey();
  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<String> listUsuarios = ["Selecciona el usuario (opcional)"], listAreas = ["Selecciona el Area"],
      listDepartamento = ["Selecciona el Departamento"], listPuesto = ["Selecciona el puesto"],
      listUrgencia = ["Selecciona la prioridad", "Importante", "Urgente", "No urgente", "Pregunta"];
  List<AreaModels> areas = [];

  String selectedUrgencia = "Selecciona la prioridad", selectedUsuario = "Selecciona el usuario (opcional)",
      title = "et", selectedArea = "Selecciona el Area", selectedDepartamento = "Selecciona el Departamento",
      selectedPuesto = "Selecciona el puesto", empresaID = "";

  late AreaModels selectedAreaModel;
  late DepartamentoModels selectedDepartamentoModel;
  late PuestoModels selectedPuestoModel;

  List<EmpresaModels> listEmpresas = [], listEmpresasTemp = [];
  SwiperController swiperController = SwiperController();
  List<String> titles = ['Datos del usuario', 'Empresas del usuario',];
  bool exitDialog = false;

  @override
  void initState() {
    getTicketData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return bodyReload();
  }

  PreferredSizeWidget? appBarWidget() {
    return size.width > 600 ? myAppBarDesktop() : myAppBarMobile();
  }
  PreferredSizeWidget myAppBarDesktop(){
    return MyCustomAppBarDesktop(title: "Resumen de ticket", textColor: Colors.white,
        backButtonWidget: TextButton.icon(
          icon: const Icon(IconLibrary.iconBack, color: Colors.white,),
          label: const Text("Atras", style: TextStyle(color: Colors.white,),),
          style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.transparent),
          onPressed: () {
            CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData,
                width: size.width>500? null : size.width * 0.9,
                btnOkOnPress: () {Navigator.of(context).pop();},
                btnCancelOnPress: () {}).showQuestion(context);
          },
        ), color: ColorPalette.ticketsColor, height: 45,
        context: context, backButton: true, defaultButtons: false,
        borderRadius: const BorderRadius.all(Radius.circular(25)));
  }
  PreferredSizeWidget myAppBarMobile(){
    return MyCustomAppBarMobile(backgroundColor: ColorPalette.ticketsColor, color: Colors.white,
      tickets: true,
      confirm: true, title: "Resumen de ticket", context: context, backButton: true,confirmButton: false,);
  }
  Future<void> comprobarSave() async {
    if (_formKey.currentState!.validate()) {
      if (selectedArea != "Selecciona el Area" && selectedDepartamento != "Selecciona el Departamento" &&
          selectedUrgencia != "Selecciona la prioridad") {
        CustomAwesomeDialogTickets(title: Texts.askSaveConfirm, desc: '',width: size.width>500? null : size.width * 0.9,
            btnOkOnPress: () async {_update();}, btnCancelOnPress: () {}).showQuestion(context);
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
      print(areas[i].nombre);
      listAreas.add(areas[i].nombre);
    }
  }

  Future<void> _update() async {
    try {
      TicketsModels ticket = TicketsModels(
        IDTickets: widget.ticket.IDTickets,
        UsuarioAsignadoID: selectedUsuarioModel != null ? selectedUsuarioModel!.idUsuario! : "",
        DepartamentoID: selectedDepartamentoModel.idDepartamento!,
        Titulo: _tituloController.text,
        Descripcion: _descripcionController.text,
        Estatus: 'Abierto',
        Prioridad: selectedUrgencia,
        Imagen1: base64String1,
        Imagen2: base64String2,
        Imagen3: base64String3,
        UsuarioID: '',
      );
      LoadingDialog.showLoadingDialog(context, Texts.savingData);

      TicketController ticketController = TicketController();
      TicketsModels? ticket1 = await ticketController.updateTicket(ticket);
      if (ticket1 != null) {
        CustomAwesomeDialogTickets(title: Texts.addSuccess, desc: '', btnOkOnPress: () {
          LoadingDialog.hideLoadingDialog(context);
          Navigator.of(context).pop();
        }, btnCancelOnPress: () {},width: size.width>500? null : size.width * 0.9,).showSuccess(context);
        Future.delayed(const Duration(milliseconds: 2500), () {
          LoadingDialog.hideLoadingDialog(context);
          Navigator.of(context).pop();
        });
      } else {
        LoadingDialog.hideLoadingDialog(context);
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: Texts.ticketErrorSave,
            width: size.width>500? null : size.width * 0.9,
            btnOkOnPress: () {}, btnCancelOnPress: () {}).showError(context);
      }
    } catch (e) {
      LoadingDialog.hideLoadingDialog(context);
    }
  }

  Widget bodyReload() {
    return WillPopScope(
        child: PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()>{
          LogicalKeyboardKey.escape: () {
            CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData,
                width: size.width>500? null : size.width * 0.9,
                btnOkOnPress: () {Navigator.of(context).pop();},
                btnCancelOnPress: () {}).showQuestion(context);
          },
          LogicalKeyboardKey.f4: () async {comprobarSave();},
        }, Gkey: globalKey,
            child: Scaffold(backgroundColor: ColorPalette.ticketsColor4,
              appBar: appBarWidget(),
              body: size.width > 600 ? _landscapeBody2() : _portraitBody(),
            )),
        onWillPop: () async {
          bool salir = false;
          CustomAwesomeDialogTickets(title: Texts.alertExit, desc: Texts.lostData,
            width: size.width>500? null : size.width * 0.9, btnOkOnPress: () {Navigator.of(context).pop();},
            btnCancelOnPress: () {salir = false;},).showQuestion(context);
          return salir;
        });
  }

  List<Widget> ticketData() {
    return [
      _myContainer("DATOS DEL TICKET"),
      const Text("Titulo de ticket", style: TextStyle(color: Colors.black, fontSize: 16,
          fontWeight: FontWeight.bold),),
      const SizedBox(height: 2,),
      ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500),
        // Ajusta el ancho máximo según tus necesidades
        child: Text(widget.ticket.Titulo, style: const TextStyle(color: Colors.black54, fontSize: 14),),
      ),
      const SizedBox(height: 8,),
      _rowDivided(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: areaList(),),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: departamentoList(),),
      ),
      const SizedBox(height: 10,),
      _rowDivided(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: usuarioList(),),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: prioridadList()),
      ),
      const SizedBox(height: 10,),
      Row(children: [_descripcion(),],),
      const SizedBox(height: 8,),
      const Row(children: [Text("Evidencias del ticket", style: TextStyle(color: Colors.black),),],),
      const SizedBox(height: 8,),
      _archives(),
    ];
  }

  getDepartamentos() {
    for (int j = 0; j < selectedAreaModel.departamentos!.length; j++) {
      listDepartamento.add(selectedAreaModel.departamentos![j].nombre);
    }
  }

  getUsuarios() {
    for (int k = 0; k < selectedDepartamentoModel.usuarios!.length; k++) {
      listUsuarios.add('${selectedDepartamentoModel.usuarios![k].nombre} '
          '${selectedDepartamentoModel.usuarios![k].apellidoPaterno} '
          '${selectedDepartamentoModel.usuarios![k].apellidoMaterno ?? ""}');
    }
  }

  Widget userForm() {
    return Form(key: _formKey,
        child: Scrollbar(controller: _scrollController, thumbVisibility: true,
          child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(controller: _scrollController,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: <Widget>[...ticketData(),],),
                ),
              )),
        ));
  }
  List<Widget> areaList(){
    return [
      const Text("Area", style: TextStyle(color: Colors.black),),
      const SizedBox(height: 8,),
      Text(selectedArea, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),),
    ];
  }
  List<Widget> departamentoList(){
    return [
      const Text("Departamento", style: TextStyle(color: Colors.black),),
      const SizedBox(height: 8,),
      Text(selectedDepartamento, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
    ];
  }
  List<Widget> usuarioList(){
    return [
      const Text("Usuario", style: TextStyle(color: Colors.black),),
      const SizedBox(height: 8,),
      Text(selectedUsuario, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
    ];
  }
  List<Widget> prioridadList(){
    return [
      const Text("Prioridad", style: TextStyle(color: Colors.black),),
      const SizedBox(height: 8,),
      Text(selectedUrgencia, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
    ];
  }

  Widget _landscapeBody2() {
    return SizedBox(height: size.height, width: size.width,
      child: Column(children: [userForm()],),
    );
  }

  Widget _descripcion() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Descripción de Ticket", style: TextStyle(color: Colors.black)),
        const SizedBox(height: 3,),
        SizedBox(width: size.width-20, child:
        Text(_descripcionController.text, style: const TextStyle(color: Colors.black54, fontSize: 12),),),
      ],
    );
  }

  Widget _archives() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageWidget(widget.ticket.Imagen1),
        imageWidget(widget.ticket.Imagen2),
        imageWidget(widget.ticket.Imagen3),
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
    } catch (_) {
      return const AssetImage('assets/avatarxl.png'); // Reemplaza esto con la ruta a tu imagen de error
    }
  }
  Widget _myContainer(String text) {
    return Container(width: size.width>500? size.width / 3 : size.width*.7, padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
      child: Center(
          child: Column(children: [
            Text(text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),),
            const Divider(thickness: 2, color: ColorPalette.ticketsColor,)
          ],
          )),
    );
  }

  Widget _rowDivided(Widget widgetL, Widget widgetR) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: size.width>500? size.width * 0.35 : size.width * 0.46, child: widgetL,),
        SizedBox(width: size.width>500? size.width * 0.35 : size.width * 0.46, child: widgetR,),
      ],
    );
  }

  Widget _portraitBody() {
    return  Column(children: [userForm()],);
  }

  Future<List<DepartamentoSubmodulo>> getDepartamentoSubmodulo(String idDepartamento) async {
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];
    listDepartamentoSubmodulo = await DepartamentoSubmoduloController().getDepartamentoSubmodulo(idDepartamento);
    return listDepartamentoSubmodulo;
  }


  getTicketData() {
    getAreas();
    for (int k = 0; k < areas.length; k++) {
      for (int j = 0; j < areas[k].departamentos!.length; j++) {
        if (areas[k].departamentos![j].idDepartamento == widget.ticket.DepartamentoID) {
          selectedArea = areas[k].nombre;
          selectedAreaModel = areas[k];
          getDepartamentos();
          selectedDepartamento = areas[k].departamentos![j].nombre;
          selectedDepartamentoModel = areas[k].departamentos![j];
          getUsuarios();

          for (int i = 0; i < areas[k].departamentos![j].usuarios!.length; i++) {
            if (areas[k].departamentos![j].usuarios![i].idUsuario == widget.ticket.UsuarioAsignadoID) {
              selectedUsuario = areas[k].departamentos![j].usuarios![i].nombre + " " +
                  areas[k].departamentos![j].usuarios![i].apellidoPaterno + " " +
                  (areas[k].departamentos![j].usuarios![i].apellidoMaterno ?? "");
              selectedUsuarioModel = areas[k].departamentos![j].usuarios![i];
            }
          }
        }
      }
    }
    selectedUrgencia = widget.ticket.Prioridad;
    _descripcionController.text = widget.ticket.Descripcion;
  }
}
