import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_decoration.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
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

class ticketEditScreenTest extends StatefulWidget {
  static String id = 'ticketRegistration';
  List<SubmoduloPermisos>? listSubmoduloPermisos = [];
  List<AreaModels> areas = [];
  TicketsModels ticket;

  ticketEditScreenTest(
      {super.key,
      this.listSubmoduloPermisos,
      required this.areas,
      required this.ticket});

  @override
  _ticketEditScreenTestState createState() => _ticketEditScreenTestState();
}

class _ticketEditScreenTestState extends State<ticketEditScreenTest>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _tituloController = TextEditingController();
  final _scrollController = ScrollController();
  final scrollController = ScrollController();
  late Size size;
  late ThemeData theme;
  List<PlatformFile> selectedFiles = [];
  List<String> selectedFileNames = [];
  List<String> selectedFileTypes = [];
  FilePickerResult? result;

  Uint8List? imageBytes1;
  Uint8List? imageBytes2;
  Uint8List? imageBytes3;
  Image? image1;
  Image? image2;
  Image? image3;
  String base64String1 = "";
  String base64String2 = "";
  String base64String3 = "";

  UsuarioModels? selectedUsuarioModel;
  String? selectedFileName;
  String? selectedFileType;
  GlobalKey globalKey = GlobalKey();
  List<SubmoduloPermisos> listSubmoduloPermisos = [];
  List<String> listUsuarios = ["Selecciona el usuario (opcional)"];
  List<String> listAreas = ["Selecciona el Area"];
  List<String> listDepartamento = ["Selecciona el Departamento"];
  List<String> listPuesto = ["Selecciona el puesto"];
  List<AreaModels> areas = [];
  List<String> listUrgencia = [
    "Selecciona la prioridad",
    "Importante",
    "Urgente",
    "No urgente",
    "Pregunta"
  ];

  String selectedUrgencia = "Selecciona la prioridad";
  String selectedUsuario = "Selecciona el usuario (opcional)";
  String title = "et";
  String selectedArea = "Selecciona el Area";
  String selectedDepartamento = "Selecciona el Departamento";
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

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    getTicketData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return bodyReload();
  }

  PreferredSizeWidget? appBarWidget() {
    return size.width > 600
        ? MyCustomAppBarDesktop(
            title: "Editar ticket",
            textColor: Colors.white,
            backButtonWidget: TextButton.icon(
              icon: const Icon(
                IconLibrary.iconBack,
                color: Colors.white,
              ),
              label: Text(
                "Atras",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.transparent, // Color de fondo
              ),
              onPressed: () {
                CustomAwesomeDialog(
                        title: Texts.alertExit,
                        desc: Texts.lostData,
                        btnOkOnPress: () {
                          Navigator.of(context).pop();
                        },
                        btnCancelOnPress: () {})
                    .showQuestion(context);
              },
            ),
            color: ColorPalette.ticketsColor,
            height: 45,
            suffixWidget: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.ticketsColor4, elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Actualizar  ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Icon(
                    IconLibrary.iconSave,
                    color: ColorPalette.ticketsColor,
                  )
                ],
              ),
              onPressed: () async {
                if (tabController.index == 0) {
                  comprobarSave();
                } else {
                  await moverTab(0);
                  Future.delayed(const Duration(milliseconds: 400), () {
                    comprobarSave();
                  });
                }
              },
            ),
            context: context,
            backButton: true,
            defaultButtons: false,
            borderRadius: const BorderRadius.all(Radius.circular(25)))
        : null;
  }

  Future<void> comprobarSave() async {
    if (_formKey.currentState!.validate()) {
      if (selectedArea != "Selecciona el Area" &&
          selectedDepartamento != "Selecciona el Departamento" &&
          selectedUrgencia != "Selecciona la prioridad") {
        CustomAwesomeDialog(
                title: Texts.askSaveConfirm,
                desc: '',
                btnOkOnPress: () async {
                  _update();
                },
                btnCancelOnPress: () {})
            .showQuestion(context);
      } else {
        CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
      }
    } else {
      CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
    }
  }

  Future<void> moverTab(int index) async {
    tabController.index = index;
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
        UsuarioAsignadoID: selectedUsuarioModel != null
            ? selectedUsuarioModel!.idUsuario!
            : "",
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
      TicketsModels? ticke = await ticketController.updateTicket(ticket);
      if (ticket != null) {
        CustomAwesomeDialog(
                title: Texts.addSuccess,
                desc: '',
                btnOkOnPress: () {
                  LoadingDialog.hideLoadingDialog(context);
                  Navigator.of(context).pop();
                },
                btnCancelOnPress: () {})
            .showSuccess(context);
        Future.delayed(const Duration(milliseconds: 2500), () {
          LoadingDialog.hideLoadingDialog(context);

          Navigator.of(context).pop();
        });
      } else {
        LoadingDialog.hideLoadingDialog(context);
        CustomAwesomeDialog(
                title: Texts.errorSavingData,
                desc: 'Error al guardar el ticket',
                btnOkOnPress: () {},
                btnCancelOnPress: () {})
            .showError(context);
      }
    } catch (e) {
      LoadingDialog.hideLoadingDialog(context);
    }
  }

  Widget bodyReload() {
    return WillPopScope(
        child: PressedKeyListener(
            keyActions: <LogicalKeyboardKey, Function()>{
              LogicalKeyboardKey.escape: () {
                CustomAwesomeDialog(
                        title: Texts.alertExit,
                        desc: Texts.lostData,
                        btnOkOnPress: () {
                          Navigator.of(context).pop();
                        },
                        btnCancelOnPress: () {})
                    .showQuestion(context);
              },
              LogicalKeyboardKey.f1: () async {
                moverTab(0);
              },
              LogicalKeyboardKey.f2: () async {
                moverTab(1);
              },
              LogicalKeyboardKey.f4: () async {
                if (tabController.index == 0) {
                  comprobarSave();
                } else {
                  await moverTab(0);
                  Future.delayed(const Duration(milliseconds: 400), () {
                    comprobarSave();
                  });
                }
              },
            },
            Gkey: globalKey,
            child: Scaffold(
              backgroundColor: ColorPalette.ticketsColor4,
              appBar: appBarWidget(),
              body: size.width > 600 ? _landscapeBody2() : _portraitBody(),
            )),
        onWillPop: () async {
          bool salir = false;
          CustomAwesomeDialog(
            title: Texts.alertExit,
            desc: Texts.lostData,
            btnOkOnPress: () {
              salir = true;
            },
            btnCancelOnPress: () {
              salir = false;
            },
          ).showQuestion(context);
          return salir;
        });
  }

  List<Widget> ticketData() {
    return [
      _myContainer("DATOS DEL TICKET"),
      const Text("Titulo de ticket", style: TextStyle(color: Colors.black)),
      const SizedBox(
        height: 8,
      ),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        // Ajusta el ancho máximo según tus necesidades
        child: Text(
          widget.ticket.Titulo,
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      _rowDivided(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Area",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 8,
            ),
            MyDropdown(
              dropdownColor: ColorPalette.ticketsColor8,
              textStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              dropdownItems: listAreas,
              selectedItem: selectedArea,
              suffixIcon: const Icon(IconLibrary.iconBusiness,
                  color: ColorPalette.ticketsColor),
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
                  for (int j = 0;
                      j < selectedAreaModel.departamentos!.length;
                      j++) {
                    listDepartamento
                        .add(selectedAreaModel.departamentos![j].nombre);
                  }
                }

                setState(() {});
                print(value);
              },
              enabled: true,
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Departamento",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 8,
            ),
            MyDropdown(
              dropdownColor: ColorPalette.ticketsColor8,
              textStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              dropdownItems: listDepartamento,
              selectedItem: selectedDepartamento,
              suffixIcon: const Icon(IconLibrary.iconGroups,
                  color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedDepartamento = value!;
                if (value != "Selecciona el Departamento") {
                  listUsuarios = ["Selecciona el usuario (opcional)"];
                  selectedUsuario = "Selecciona el usuario (opcional)";
                  for (int j = 0;
                      j < selectedAreaModel.departamentos!.length;
                      j++) {
                    if (selectedAreaModel.departamentos![j].nombre == value) {
                      selectedDepartamentoModel =
                          selectedAreaModel.departamentos![j];
                      break;
                    }
                  }
                  for (int k = 0;
                      k < selectedDepartamentoModel.usuarios!.length;
                      k++) {
                    listUsuarios.add(selectedDepartamentoModel
                            .usuarios![k].nombre +
                        ' ' +
                        selectedDepartamentoModel.usuarios![k].apellidoPaterno +
                        ' ' +
                        (selectedDepartamentoModel
                                .usuarios![k].apellidoMaterno ??
                            ""));
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
      const SizedBox(
        height: 20,
      ),
      _rowDivided(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Usuario",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 8,
            ),
            MyDropdown(
              dropdownColor: ColorPalette.ticketsColor8,
              textStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              dropdownItems: listUsuarios,
              selectedItem: selectedUsuario,
              suffixIcon: const Icon(IconLibrary.iconUser,
                  color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedUsuario = value!;
                for (int j = 0;
                    j < selectedDepartamentoModel.usuarios!.length;
                    j++) {
                  if (selectedDepartamentoModel.usuarios![j].nombre +
                          " " +
                          selectedDepartamentoModel
                              .usuarios![j].apellidoPaterno +
                          " " +
                          (selectedDepartamentoModel
                                  .usuarios![j].apellidoMaterno ??
                              "") ==
                      value) {
                    selectedUsuarioModel =
                        selectedDepartamentoModel.usuarios![j];
                    break;
                  }
                }
                setState(() {});
                print(value);
              },
              enabled: selectedDepartamento != "Selecciona el Departamento" &&
                  selectedArea != "Selecciona el Area",
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prioridad",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 8,
            ),
            MyDropdown(
              dropdownColor: ColorPalette.ticketsColor8,
              textStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              dropdownItems: listUrgencia,
              selectedItem: selectedUrgencia,
              suffixIcon: const Icon(IconLibrary.iconDensity,
                  color: ColorPalette.ticketsColor),
              onPressed: (String? value) async {
                selectedUrgencia = value!;
                setState(() {});
                print(value);
              },
              enabled: selectedDepartamento != "Selecciona el Departamento" &&
                  selectedArea != "Selecciona el Area",
            )
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      _descripcion(),
    ];
  }

  getDepartamentos() {
    for (int j = 0; j < selectedAreaModel.departamentos!.length; j++) {
      listDepartamento.add(selectedAreaModel.departamentos![j].nombre);
    }
  }

  getUsuarios() {
    for (int k = 0; k < selectedDepartamentoModel.usuarios!.length; k++) {
      listUsuarios.add(selectedDepartamentoModel.usuarios![k].nombre +
          ' ' +
          selectedDepartamentoModel.usuarios![k].apellidoPaterno +
          ' ' +
          (selectedDepartamentoModel.usuarios![k].apellidoMaterno ?? ""));
    }
  }

  List<Widget> userForm() {
    return [
      Form(
          key: _formKey,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    ...ticketData(),
                  ],
                ),
              ),
            )),
          )),
    ];
  }

  Widget _landscapeBody2() {
    return Container(
      height: size.height,
      width: size.width,
      child: Column(
        children: [...userForm()],
      ),
    );
  }

  Widget _descripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Descripción de Ticket",
            style: TextStyle(color: Colors.black)),
        const SizedBox(
          height: 8,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: MyTextfieldIcon(
            textStyle: TextStyle(color: Colors.black54, fontSize: 12),
            cursorColor: Colors.black54,
            textColor: Colors.black54,
            colorLineBase: Colors.black54,
            colorLine: Colors.black54,
            backgroundColor: ColorPalette.ticketsSelectedColor,
            labelText: "",
            textController: _descripcionController,
            minLines: 2,
            // Número mínimo de líneas
            maxLines: 2,
            // Número máximo de líneas
            maxLength: 450,
          ),
        ),
      ],
    );
  }

  Widget _myContainer(String text) {
    return Container(
      width: size.width / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Center(
          child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Divider(
            thickness: 2,
            color: ColorPalette.ticketsColor,
          )
        ],
      )),
    );
  }

  Widget _rowDivided(Widget widgetL, Widget widgetR) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: size.width * 0.35,
          child: widgetL,
        ),
        SizedBox(
          width: size.width * 0.35,
          child: widgetR,
        ),
      ],
    );
  }

  Widget _portraitBody() {
    return const Column(
      children: [Text("data")],
    );
  }

  Future<List<DepartamentoSubmodulo>> getDepartamentoSubmodulo(
      String idDepartamento) async {
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];
    listDepartamentoSubmodulo = await DepartamentoSubmoduloController()
        .getDepartamentoSubmodulo(idDepartamento);
    return listDepartamentoSubmodulo;
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

  getTicketData() {
    getAreas();
    for (int k = 0; k < areas.length; k++) {
      for (int j = 0; j < areas[k].departamentos!.length; j++) {
        if (areas[k].departamentos![j].idDepartamento ==
            widget.ticket.DepartamentoID) {
          selectedArea = areas[k].nombre;
          selectedAreaModel = areas[k];
          getDepartamentos();
          selectedDepartamento = areas[k].departamentos![j].nombre;
          selectedDepartamentoModel = areas[k].departamentos![j];
          getUsuarios();

          for (int i = 0;
              i < areas[k].departamentos![j].usuarios!.length;
              i++) {
            if (areas[k].departamentos![j].usuarios![i].idUsuario ==
                widget.ticket.UsuarioAsignadoID) {
              selectedUsuario = areas[k].departamentos![j].usuarios![i].nombre +
                  " " +
                  areas[k].departamentos![j].usuarios![i].apellidoPaterno +
                  " " +
                  (areas[k].departamentos![j].usuarios![i].apellidoMaterno ??
                      "");
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
