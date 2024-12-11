import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/TicketsModels/Comentario.dart';
import 'package:tickets/pages/Tickets/satisfactionTickets.dart';
import 'package:tickets/pages/Tickets/tickets_conversation.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/TicketController/StatusController.dart';
import '../../controllers/TicketController/TicketConComentaryController.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../controllers/TicketController/ticketViewController.dart';
import '../../models/TicketsModels/status.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/pdf/pw_pdf/generate_material_report.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/Calendar/calendar.dart';
import '../../shared/widgets/Loading/loadingDialog.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/buttons/custom_button.dart';
import '../../shared/widgets/buttons/custom_dropdown_button.dart';
import '../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../shared/widgets/error/customNoData.dart';
import '../../shared/widgets/textfields/my_textfield_icon.dart';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class TicketsRecibidosAdminTest extends StatefulWidget {
  static String id = 'TicketsRecibidosAdmin';
  BuildContext context;
  TicketsRecibidosAdminTest({super.key, required this.context});

  @override
  State<TicketsRecibidosAdminTest> createState() => _TicketsLevantados();
}

class _TicketsLevantados extends State<TicketsRecibidosAdminTest> {
  late Size size;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<String> items = ["Abierto", "En Progreso", "Resuelto", "Cerrado"];
  List<String> selectedItems1 = [];
  List<String> selectedItems2 = [];
  List<String> attachedFiles = ['archivo1.pdf', 'archivo2.docx', 'imagen.png'];
  List<String> status = ['Abierto', 'En Progreso', 'Resuelto'];
  List<String> Importancia = ['Importante', 'Urgente', 'No urgente', 'Pregunta'];
  List<Color> statusColors = [Colors.green, Colors.orange, Colors.blue];
  List<TicketsModels> listTicketsTemp = [],listTicketsTempReport=[];
  String currentStatus = 'Abierto';
  Color currentColor = Colors.green;
  DateTime today = DateTime.now();
  TextEditingController _dateInitial = TextEditingController();
  List<TicketsModels> listTickets = [];
  bool isEmpty = false;
  bool _isLoading = true;
  int itemCount = 0;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startDateReport;
  DateTime? endDateReport;

  @override
  void initState() {
    super.initState();
    _getDatos();

    const timeLimit = Duration(seconds: 15);
    Timer(timeLimit, () {
      if (listTickets.isEmpty) {
        if (!isEmpty) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _isLoading = false;
      }
    });
  }

  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return _desktopBody(size, context);
  }

  List<Widget> _filtros() {
    return [
      SizedBox(
        width: 250,
        height: 55,
        child: MyTextfieldIcon(
          labelText: "Buscar ticket",
          colorLineBase: Colors.black54,
          textController: _searchController,
          textColor: Colors.black54,
          cursorColor: Colors.black54,
          suffixIcon: const Icon(IconLibrary.iconSearch, color: Colors.black),
          floatingLabelStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          backgroundColor: ColorPalette.ticketsSelectedColor,
          formatting: false,
          colorLine: Colors.black54,
          textStyle: TextStyle(color: Colors.black54),
          onChanged: (value) {
            aplicarFiltro();
          },
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        width: 250,
        decoration: BoxDecoration(
            color: ColorPalette.ticketsSelectedColor,
            borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(
            context: context,
            items: status,
            selectedItems: selectedItems1,
            textColor: Colors.black54,
            backgroundColor: ColorPalette.ticketsColor4,
            setState: setState,
            text: "Selecciona el estatus del ticket",
            color: Colors.black54,
            onTap: () {
              aplicarFiltro();
            }),
      ),
      const SizedBox(
        width: 10,
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        width: 250,
        decoration: BoxDecoration(
            color: ColorPalette.ticketsSelectedColor,
            borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(
            context: context,
            items: Importancia,
            selectedItems: selectedItems2,
            setState: setState,
            text: "Selecciona la importancia del ticket",
            color: Colors.black54,
            textColor: Colors.black54,
            backgroundColor: ColorPalette.ticketsColor4,
            onTap: () {
              aplicarFiltro();
            }),
      ),
      const SizedBox(
        width: 10,
      ),
      FloatingActionButton(
        onPressed: () {
          showDialog<DateTimeRange>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
              content: SizedBox(
                width: 338, height: 800,
                child: CustomDateRangePicker(
                  minimumDate: DateTime.now().subtract(const Duration(days: 100)),
                  maximumDate: DateTime.now().add(const Duration(days: 100)),
                  backgroundColor: Colors.white, primaryColor: ColorPalette.ticketsColor,
                  onApplyClick: (start, end) {
                    setState(() {
                      endDate = end.add(Duration(days: 1));
                      startDate = start;
                      aplicarFiltroFecha();
                    });
                  },
                  onCancelClick: () {
                    setState(() {
                      endDate = null;
                      startDate = null;
                    });
                  },
                ),
              ),
            ),
          );
        },
        tooltip: 'Selecciona la fecha en las que quieres obtener los tickets',
        backgroundColor: ColorPalette.ticketsColor,
        child: const Icon(Icons.calendar_today_outlined, color: Colors.white,),
      ),

      const SizedBox(width: 10,),
      FloatingActionButton(
        onPressed: () {
          CustomAwesomeDialog(
              title: "¿Estas seguro que deseas generar un reporte de tickets?\n",
              desc: "Recuerda que puedes seleccionar un rango de fechas para generar el reporte.",
              btnOkOnPress: () async {
                showDialog<DateTimeRange>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
                    content: SizedBox(
                      width: 338, height: 800,
                      child: CustomDateRangePicker(
                        minimumDate: DateTime.now().subtract(const Duration(days: 100)),
                        maximumDate: DateTime.now().add(const Duration(days: 100)),
                        backgroundColor: Colors.white, primaryColor: ColorPalette.ticketsColor,
                        onApplyClick: (start, end) {
                          setState(() {
                            endDateReport = end.add(Duration(days: 1));
                            startDateReport = start;
                            aplicarFiltroFechaReporte();
                          });
                        },
                        onCancelClick: () {
                          setState(() {
                            endDateReport = null;
                            startDateReport = null;
                          });
                        },
                      ),
                    ),
                  ),
                );},
              btnCancelOnPress: () {}).showQuestion(context);
        },
        tooltip: 'Selecciona la fecha en las que quieres generar el reporte',
        backgroundColor: ColorPalette.ticketsColor,
        child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white,),
      ),
    ];
  }

  Widget _customButtonShowConversation(String idTickets) {
    return CustomButton(
        text: size.width > 1050 ? Texts.conversacion : "",
        onPressed: () async {
          showConversation(idTickets);
        },
        icon: IconLibrary.iconConversation,
        width: size.width < 1050 ? 30 : 108,
        height: 50,
        color: ColorPalette.ticketsColor.withOpacity(0.9),
        colorText: Colors.white);
  }

  Widget body() {
    return Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: MyCustomAppBarDesktop(
          title: "Recibidos Departamento",
          context: context,
          textColor: Colors.white,
          backButton: true,
          defaultButtons: false,
          color: ColorPalette.ticketsColor,
          backButtonWidget: TextButton.icon(
            icon: const Icon(
              IconLibrary.iconBack,
              color: Colors.white,
            ),
            label: const Text(
              "Salir de tickets",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.transparent, // Color de fondo
            ),
            onPressed: () {
              Navigator.of(widget.context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (size.width > 1260) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ..._filtros(),
                        ],
                      ),
                    ],
                  )
                ] else ...[
                  Row(
                    children: [
                      _filtros()[0],
                      const SizedBox(
                        width: 10,
                      ),
                      _filtros()[2],
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _filtros()[4],
                          const SizedBox(
                            width: 10,
                          ),
                          _filtros()[6],
                          const SizedBox(
                            width: 10,
                          ),
                          _filtros()[8],
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    height: size.height - 140,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: futureList(),
                    ))
              ],
            ),
          ),
        )); //body: Column(children: [..._filtros()],),);
  }

  Widget futureList() {
    return FutureBuilder<List<TicketsModels>>(
      future: _getDatos2(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: _buildLoadingIndicator(10));
        } else {
          final listTickets = snapshot.data ?? [];
          if (listTickets.isNotEmpty) {
            return Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: listTicketsTemp.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return card(listTicketsTemp[index]);
                  },
                ),
              ),
            );
          } else {
            if (_isLoading) {
              return Center(child: _buildLoadingIndicator(4));
            } else {
              return SingleChildScrollView(
                child: Center(child: NoDataWidget()),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: buttonList,
      ),
    );
  }

  Widget cardEsqueleto(double width) {
    return SizedBox(
      width: width,
      height: max(152 * (size.width / 1200), 180.0),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorPalette.ticketsColor7,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Shimmer.fromColors(
            baseColor: ColorPalette.ticketsColor7,
            highlightColor: ColorPalette.ticketsColor2 == Brightness.light
                ? const Color.fromRGBO(195, 193, 186, 1.0)
                : const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget card(TicketsModels tickets) {
    return Container(
      height: max(153 * (size.width / 1200), 180.0),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: ColorPalette.ticketsColor7, elevation: 0,
        child: Padding(padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 1,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: ColorPalette.ticketsColor,
                          borderRadius: BorderRadius.circular(7.0)),
                      height: 40, width: 250, transformAlignment: Alignment.center,
                      child: Text(tickets.Titulo, style: TextStyle(color: Colors.white,
                          fontSize: 15 * (size.width / 1400), fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text("Ticket # ${tickets.NumeroTicket}",
                      style: TextStyle(color: Colors.tealAccent, fontSize: 12,
                      ),),
                    SizedBox(height: 8,),
                    Text("Usuario: ${tickets.UsuarioNombre}",
                      style: TextStyle(color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400), fontWeight: FontWeight.bold),),
                    SizedBox(height: 5,),
                    Text("Departamento: ${tickets.NombreDepartamento}",
                      style: TextStyle(color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400), fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(alignment: Alignment.centerLeft,
                      child: Container(
                        width: 600, padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.ticketsColor6,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text("Descripción:  ${tickets.Descripcion}", maxLines: 3,
                          style: TextStyle(color: Colors.white,
                              fontSize: 11 * (size.width / 1200), fontWeight: FontWeight.w800),),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[
                      Expanded(child:
                      Text(
                        "Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: min(17 * (size.width / 1200), 12.0),
                        ),
                      ),),
                      Expanded(child:
                      Text("fecha de finalización : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: min(17 * (size.width / 1200), 12.0)),),),
                    ]),
                    const SizedBox(height: 15,),
                    tickets.Imagen1!.isEmpty &&
                        tickets.Imagen2!.isEmpty &&
                        tickets.Imagen3!.isEmpty
                        ? Text(
                      "",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    )
                        : Text(
                      "Archivos adjuntos:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (tickets.Imagen1 != null &&
                            tickets.Imagen1!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  print(tickets.Imagen1?.length);
                                  _showImageDialog(tickets.Imagen1!);
                                },
                                child: Icon(Icons.insert_drive_file,
                                    color: Colors.white), // Icono de archivo
                              ),
                            ),
                          ),
                        ],
                        if (tickets.Imagen2 != null &&
                            tickets.Imagen2!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  print(tickets.Imagen2);
                                  _showImageDialog(tickets.Imagen2!);
                                },
                                child: Icon(Icons.insert_drive_file,
                                    color: Colors.white), // Icono de archivo
                              ),
                            ),
                          ),
                        ],
                        if (tickets.Imagen3 != null &&
                            tickets.Imagen3!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  _showImageDialog(tickets.Imagen3!);
                                },
                                child: Icon(Icons.insert_drive_file,
                                    color: Colors.white), // Icono de archivo
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        if (size.width > 1240) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 6,
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [buttons(tickets)[0]],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    children: [buttons(tickets)[1]],
                                  ),
                                  //_customButtonDownload(),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                        ] else ...[
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [buttons(tickets)[0]],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [buttons(tickets)[1]],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: _customButtonShowConversation(
                                tickets.IDTickets!)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buttons(TicketsModels tickets) {
    return [
      tickets.Estatus == "Cerrado"
          ? Container(
          alignment: Alignment.center,
          color: Colors.black,
          height: 25,
          width: 100,
          child: Text(
            "Cerrado",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ))
          : Container(
        alignment: Alignment.center,
        color: statusColors[status.indexOf(tickets.Estatus)],
        height: 28,
        width: 100,
        child: DropdownButton<String>(
          dropdownColor: ColorPalette.ticketsColor,
          alignment: Alignment.center,
          value: tickets.Estatus,
          style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold),
          underline: Container(),
          onChanged: (String? newValue) async {
            bool result = await comprobarSave();
            print("result: $result");
            if (result) {
              await changeStatus(
                  id: tickets.IDTickets!,
                  estatus: newValue!);
              listTickets.where((element) => element.IDTickets == tickets.IDTickets).first.Estatus = newValue;
              tickets.Estatus = newValue;
              setState(() {
              });
            }
          },
          items: status.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      Container(
          alignment: Alignment.center,
          color: ColorPalette.ticketsColor10,
          height: 25,
          width: 100,
          child: Text(
            " ${tickets.Prioridad}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          )),
    ];
  }

  Widget _desktopBody(Size size, BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.ticketsTextSelectedColor,
      body: body(),
    );
  }

  Future<void> aplicarFiltroFechaReporte() async {
    if (startDateReport != null && endDateReport != null) {
      try {
        UserPreferences userPreferences = UserPreferences();
        String idPuesto = await userPreferences.getPuestoID();
        String idUsuario = await userPreferences.getUsuarioID();

        final departamentoController = departamentController();
        String departament = await departamentoController.getPuesto(idPuesto) as String;

        final ticketViewController = TicketViewController();
        DateTime before = today.subtract(const Duration(days: 5));
        DateTime after = today.add(Duration(days: 1));
        _dateInitial.text =
        "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
        listTickets = await ticketViewController.getTicketsRecibidosAdmin(
            "${startDateReport}", "${endDateReport},", departament);
        listTicketsTempReport = listTickets;
        if (listTicketsTempReport.isEmpty) {
          isEmpty = true;
        }
        print("Si llega aqui");
        print(listTicketsTempReport.first.IDTickets);
        setState(() {});
        //generatedTicketsReport(context,listTicketsTempReport,startDateReport!,endDateReport!);
      } catch (e) {
        CustomSnackBar.showErrorSnackBar(context, "No se puede generar un reporte en ese rango porque no existen tickets disponibles");
        //final connectionExceptionHandler = ConnectionExceptionHandler();
        //connectionExceptionHandler.handleConnectionException(context, e);
        //print('Error al obtener datos: $e');
      }
    }
  }

  Future<void> changeStatus({required String id, required String estatus}) async {
    try {
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      StatusModels status = StatusModels(idTicket: id, status: estatus);
      StatusController statusController = StatusController();
      bool save = await statusController.changueStatus(status);
      if (save) {
        await Future.delayed(const Duration(milliseconds: 500), () async {
          LoadingDialog.hideLoadingDialog(context);
          await Future.delayed(const Duration(milliseconds: 200), () async {
            CustomAwesomeDialog(title: Texts.updateSuccess, desc: '',
                btnOkOnPress: () {}, btnCancelOnPress: () {}).showSuccess(context);
            await Future.delayed(const Duration(milliseconds: 2550), () async {
            });
          });
        });
      } else {
        CustomAwesomeDialog(title: Texts.errorSavingData, desc: 'Error al guardar el ticket',
            btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
            btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);}).showError(context);
      }
    } catch (e) {
      CustomAwesomeDialog(title: Texts.errorSavingData, desc: 'Error al guardar el ticket. $e',
          btnOkOnPress: () {LoadingDialog.hideLoadingDialog(context);},
          btnCancelOnPress: () {LoadingDialog.hideLoadingDialog(context);}).showError(context);
    }
  }

  Future<bool> comprobarSave() {
    var completer = Completer<bool>();

    CustomAwesomeDialog(
        title: Texts.askSaveConfirmStatus,
        desc: '',
        btnOkOnPress: () {
          print("Botón OK presionado");
          completer.complete(true);
        },
        btnCancelOnPress: () {
          print("Botón Cancelar presionado");
          completer.complete(false);
        }).showQuestion(context);

    return completer.future;
  }

  void _showImageDialog(String base64Image) {
    try {
      // Attempt to decode the image
      final image = base64Decode(base64Image);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ColorPalette.ticketsColor3,
            content: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2, // Ancho del borde
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Radio del borde
                child: Image.memory(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // If decoding fails, show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid image data.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> aplicarFiltro() async {
    listTicketsTemp = listTickets;
    if (selectedItems1.isNotEmpty) {
      listTicketsTemp = listTicketsTemp
          .where((ticket) => selectedItems1.contains(ticket.Estatus))
          .toList();
    }
    if (selectedItems2.isNotEmpty) {
      listTicketsTemp = listTicketsTemp
          .where((ticket) => selectedItems2.contains(ticket.Prioridad))
          .toList();
    }
    if (_searchController.text.isNotEmpty) {
      listTicketsTemp = listTicketsTemp
          .where((ticket) =>
      ticket.Titulo.toLowerCase()
          .contains(_searchController.text.toLowerCase()) ||
          "${ticket.UsuarioAsignadoID} ${ticket.NombreDepartamento} ${ticket.Estatus}"
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          ticket.UsuarioNombre!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {});
  }

  Future<void> aplicarFiltroFecha() async {
    if (startDate != null && endDate != null) {
      try {
        UserPreferences userPreferences = UserPreferences();
        String idPuesto = await userPreferences.getPuestoID();
        String idUsuario = await userPreferences.getUsuarioID();

        final departamentoController = departamentController();
        String departament = await departamentoController.getPuesto(idPuesto) as String;

        final ticketViewController = TicketViewController();
        DateTime before = today.subtract(const Duration(days: 5));
        DateTime after = today.add(Duration(days: 1));
        _dateInitial.text =
        "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
        listTickets = await ticketViewController.getTicketsRecibidosAdmin(
            "${startDate}", "${endDate},", departament);
        listTicketsTemp = listTickets;
        if (listTicketsTemp.isEmpty) {
          isEmpty = true;
          print("Datos vacios");
        }
        print(listTicketsTemp.first.IDTickets);
        setState(() {});
      } catch (e) {
        CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
        final connectionExceptionHandler = ConnectionExceptionHandler();
        connectionExceptionHandler.handleConnectionException(context, e);
        //print('Error al obtener datos: $e');
      }
    }
  }

  Future<void> showConversation(String idTickets) async {
    try {
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      List<ComentaryModels> listComentary = await _getComenteries(idTickets);
      LoadingDialog.hideLoadingDialog(context);

      await myShowDialog(TicketsConversationScreen(
          idTicket: idTickets,
          listCommentaries: listComentary,
          activeMessages: true,
        ),
        context,
        size.width * .30,
        null,
        ColorPalette.ticketsColor,
      );
      LoadingDialog.hideLoadingDialog(context);
      listComentary.clear();
    } catch (e) {
      print("object");
      LoadingDialog.hideLoadingDialog(context);
    }
  }

  Future<void> _getDatos() async {
    try {
      UserPreferences userPreferences = UserPreferences();
      String idPuesto = await userPreferences.getPuestoID();
      String idUsuario = await userPreferences.getUsuarioID();

      final departamentoController = departamentController();
      String departament =
      await departamentoController.getPuesto(idPuesto) as String;

      final ticketViewController = TicketViewController();
      DateTime before = today.subtract(const Duration(days: 5));
      DateTime after = today.add(Duration(days: 1));
      _dateInitial.text =
      "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
      listTickets = await ticketViewController.getTicketsRecibidosAdmin(
          "${before.year}-${before.month}-${before.day}",
          "${after.year}-${after.month}-${after.day},",
          departament);
      listTickets.sort((a, b) => b.FechaCreacion!
          .compareTo(a.FechaCreacion!)); // Ordenar por fecha de creación
      listTicketsTemp = listTickets;
      if (listTicketsTemp.isEmpty) {
        isEmpty = true;
        print("Datos vacios");
      }
      setState(() {});
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
      final connectionExceptionHandler = ConnectionExceptionHandler();
      connectionExceptionHandler.handleConnectionException(context, e);
      //print('Error al obtener datos: $e');
    }
  }

  Future<List<ComentaryModels>> _getComenteries(String idTicket) async {
    try {
      List<ComentaryModels> listCommentaries = [];
      List<ComentaryModels> filteredCommentaries = [];
      final ticketCommentary = TicketConComentaryController();
      listCommentaries = await ticketCommentary.getTicketComentary(idTicket);

      // Ordena los comentarios por fecha
      listCommentaries.sort((a, b) {
        if (a.FechaHoraComentario == null && b.FechaHoraComentario == null) {
          return 0;
        }
        if (a.FechaHoraComentario == null) {
          return -1;
        }
        if (b.FechaHoraComentario == null) {
          return 1;
        }
        return a.FechaHoraComentario!.compareTo(b.FechaHoraComentario!);
      });
      filteredCommentaries = listCommentaries;
      if (filteredCommentaries.isEmpty) {
        isEmpty = true;
      }
      return filteredCommentaries;
    } catch (e) {
      //final connectionExceptionHandler = ConnectionExceptionHandler();
      return [];
    }
  }

  Future<List<TicketsModels>> _getDatos2() async {
    try {
      return listTicketsTemp;
    } catch (e) {
      print('Error al obtener tickets: $e');
      return [];
    }
  }
}
