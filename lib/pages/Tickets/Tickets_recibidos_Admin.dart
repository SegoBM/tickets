import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:tickets/models/TicketsModels/Comentario.dart';
import 'package:tickets/models/TicketsModels/ticketsReportModel.dart';
import 'package:tickets/pages/Tickets/ticketEditScreen.dart';
import 'package:tickets/pages/Tickets/ticketReasignScreen.dart';
import 'package:tickets/pages/Tickets/ticketResumeScreen.dart';
import 'package:tickets/pages/Tickets/tickets_conversation.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/ConfigControllers/areaController.dart';
import '../../controllers/TicketController/SatisfactionController.dart';
import '../../controllers/TicketController/StatusController.dart';
import '../../controllers/TicketController/TicketConComentaryController.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../controllers/TicketController/ticketViewController.dart';
import '../../models/ConfigModels/area.dart';
import '../../models/TicketsModels/satisfaction.dart';
import '../../models/TicketsModels/status.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/pdf/pw_pdf/generate_material_report.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/PopUpMenu/PopupMenuTickets.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/buttons/custom_button.dart';
import '../../shared/widgets/buttons/custom_dropdown_button.dart';
import '../../shared/widgets/progressBar/progressBar.dart';
import '../../shared/widgets/textfields/my_textfield_icon.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'CustomeAwesomeDialogTickets.dart';
import 'customNoDataTickets.dart';
import 'loadingDialogTickets.dart';

class TicketsRecibidosAdmin extends StatefulWidget {
  static String id = 'TicketsRecibidosAdmin';
  BuildContext context;
  TicketsRecibidosAdmin({super.key, required this.context});

  @override
  State<TicketsRecibidosAdmin> createState() => _TicketsLevantados();
}

class _TicketsLevantados extends State<TicketsRecibidosAdmin> {
  late Size size;
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController(),
      scrollControllerButtons = ScrollController(),
      scrollControllerMobile = ScrollController();
  TextEditingController searchController = TextEditingController(),
      dateInitial = TextEditingController();
  List<String> items = ["Abierto", "En Progreso", "Resuelto", "Cerrado"];
  List<String> selectedItems1 = [],
      selectedItems2 = [],
      attachedFiles = ['archivo1.pdf', 'archivo2.docx', 'imagen.png'],
      status = ['Abierto', 'En Progreso', 'Resuelto'],
      importancia = ['Importante', 'Urgente', 'No urgente', 'Pregunta'];
  List<Color> statusColors = [Colors.green, Colors.orange, Colors.blue];
  List<TicketsModels> listTicketsTemp = [];
  List<TicketsReportModel> listTempTickets = [], listTicketsTempReport = [];
  String currentStatus = 'Abierto';
  Color currentColor = Colors.green;
  DateTime today = DateTime.now();
  List<TicketsModels> listTickets = [];
  bool isEmpty = false, _isLoading = true;
  int itemCount = 0;
  DateTime? startDate, endDate, startDateReport, endDateReport;
  ThemeData theme = ThemeData();
  final key = GlobalKey();
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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ColorPalette.ticketsTextSelectedColor,
      body: size.width > 500 ? body() : bodyMobile(),
    );
  }

  List<Widget> _filtros() {
    return [
      SizedBox(
        width: 250,
        height: 55,
        child: MyTextfieldIcon(
          labelText: Texts.searchTicket,
          colorLineBase: Colors.black54,
          textController: searchController,
          textColor: Colors.black54,
          cursorColor: Colors.black54,
          suffixIcon: const Icon(IconLibrary.iconSearch, color: Colors.black),
          focusNode: focusNode,
          floatingLabelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          backgroundColor: ColorPalette.ticketsSelectedColor,
          formatting: false,
          colorLine: Colors.black54,
          textStyle: const TextStyle(color: Colors.black54),
          onChanged: (value) {
            aplicarFiltro();
            setState(() {
              FocusScope.of(context).requestFocus(focusNode);
            });
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
            text: Texts.ticketSelectStatus,
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
            items: importancia,
            selectedItems: selectedItems2,
            setState: setState,
            text: Texts.ticketSelectImportance,
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
            builder: size.width > 500
                ? (context) => AlertDialog(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      content: SizedBox(
                          width: 338,
                          height: 530,
                          child: dialogCustomDateRangePickerFilter()),
                    )
                : (context) => dialogCustomDateRangePickerFilter(),
          );
        },
        tooltip: Texts.ticketSelectDateRange,
        backgroundColor: ColorPalette.ticketsColor,
        child: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.white,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      FloatingActionButton(
        onPressed: () {
          CustomAwesomeDialogTickets(
                  title:
                      "¿Estas seguro que deseas generar un reporte de tickets?\n",
                  desc: Texts.ticketRemember,
                  btnOkOnPress: () async {
                    showDialog<DateTimeRange>(
                      context: context,
                      builder: size.width > 500
                          ? (context) => AlertDialog(
                                backgroundColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                content: SizedBox(
                                    width: 338,
                                    height: 530,
                                    child:
                                        dialogCustomDateRangePickerFilterReport()),
                              )
                          : (context) =>
                              dialogCustomDateRangePickerFilterReport(),
                    );
                  },
                  width: size.width > 500 ? null : size.width * 0.9,
                  btnCancelOnPress: () {})
              .showQuestion(context);
        },
        tooltip: Texts.ticketSelectDateRangeReport,
        backgroundColor: ColorPalette.ticketsColor,
        child: const Icon(
          Icons.picture_as_pdf_outlined,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget dialogCustomDateRangePickerFilterReport() {
    return CustomDateRangePicker(
      minimumDate: DateTime.now().subtract(const Duration(days: 100)),
      maximumDate: DateTime.now().add(const Duration(days: 100)),
      backgroundColor: Colors.white,
      primaryColor: ColorPalette.ticketsColor,
      onApplyClick: (start, end) {
        setState(() {
          endDateReport = end.add(const Duration(days: 1));
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
    );
  }

  Widget dialogCustomDateRangePickerFilter() {
    return CustomDateRangePicker(
      minimumDate: DateTime(2024, 1, 1),
      maximumDate: DateTime.now().add(const Duration(days: 100)),
      backgroundColor: Colors.white,
      primaryColor: ColorPalette.ticketsColor,
      onApplyClick: (start, end) {
        setState(() {
          endDate = end.add(const Duration(days: 1));
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
    );
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

  Widget customButtonShowConversationMobile(String idTickets,
      {double width = 108, double height = 50, double widthIcon = 30}) {
    return IconButton(
        onPressed: () async {
          showConversationMobile(idTickets);
        },
        icon: const Icon(
          IconLibrary.iconConversation,
          color: Colors.white,
        ),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorPalette.ticketsColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  Future<void> showConversationMobile(String idTickets) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      List<ComentaryModels> listCommentary = await _getCommentaries(idTickets);
      LoadingDialogTickets.hideLoadingDialogTickets(context);
      await Navigator.of(widget.context).push(MaterialPageRoute(
          builder: (context) => TicketsConversationScreen(
                idTicket: idTickets,
                listCommentaries: listCommentary,
                activeMessages: true,
              )));
      listCommentary.clear();
    } catch (e) {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
    }
  }

  Widget body() {
    return Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: MyCustomAppBarDesktop(
          title: "Recibidos Admin",
          context: context,
          textColor: Colors.white,
          backButton: false,
          color: ColorPalette.ticketsColor,
          ticketsFlag: false,
          defaultButtons: true,
          extracolor2: Colors.white,
          extracolor: ColorPalette.ticketsColor,
          backButtonWidget: TextButton.icon(
            icon: const Icon(
              IconLibrary.iconBack,
              color: Colors.white,
            ),
            label: const Text(
              Texts.ticketExit,
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {
              Navigator.of(widget.context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                      _filtros()[2]
                    ],
                  ),
                  const SizedBox(
                    height: 5,
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
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    height: size.height - 120,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: futureList(),
                    ))
              ],
            ),
          ),
        ));
    //body: Column(children: [..._filtros()],),);
  }

  Widget bodyMobile() {
    return Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadingEdgeScrollView.fromSingleChildScrollView(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollControllerMobile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filtros()[0],
                      const SizedBox(
                        width: 5,
                      ),
                      _filtros()[6],
                      const SizedBox(
                        width: 5,
                      ),
                      buttonFilters(),
                      //const SizedBox(width: 5,),
                    ],
                  ),
                )),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    height: size.height - 150,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: futureList(mobile: true),
                    ))
              ],
            ),
          ),
        ));
    //body: Column(children: [..._filtros()],),);
  }

  Widget bodyPortrait() {
    return Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollControllerButtons,
                    child: Row(
                      children: [
                        _filtros()[0],
                        const SizedBox(
                          width: 5,
                        ),
                        _filtros()[6],
                        const SizedBox(
                          width: 5,
                        ),
                        _filtros()[8],
                        const SizedBox(
                          width: 5,
                        ),
                        buttonFilters(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    height: size.height - 150,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: futureList(),
                    ))
              ],
            ),
          ),
        ));
  }

  Widget buttonFilters() {
    return FloatingActionButton(
      key: key,
      onPressed: () async {
        BuildContext context = key.currentContext!;
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(button.size.bottomCenter(Offset.zero),
                ancestor: overlay),
            button.localToGlobal(button.size.bottomCenter(Offset.zero),
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        var result = await showMenu(
          context: context,
          position: position,
          elevation: 8.0,
          constraints: const BoxConstraints(maxWidth: 274.0),
          surfaceTintColor: Colors.transparent,
          color: ColorPalette.ticketsColor4,
          items: <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              padding: EdgeInsets.zero,
              child: MyPopupMenuButtonFilter(
                selectedItems1: selectedItems1,
                selectedItems2: selectedItems2,
              ),
            ),
          ],
        );
        aplicarFiltro();
      },
      tooltip: 'Opciones de filtrado',
      backgroundColor: ColorPalette.ticketsColor,
      child: const Icon(
        Icons.filter_alt_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget futureList({bool mobile = false}) {
    return FutureBuilder<List<TicketsModels>>(
      future: _getDatos2(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: _buildLoadingIndicator(10));
        } else {
          final listTickets = snapshot.data ?? [];
          if (listTickets.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return _getDatos();
              },
              color: ColorPalette.ticketsColor2,
              backgroundColor: ColorPalette.ticketsUnselectedColor,
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: FadingEdgeScrollView.fromScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    itemCount: listTicketsTemp.length,
                    itemBuilder: (context, index) {
                      return !mobile
                          ? card(listTicketsTemp[index])
                          : cardMobile(listTicketsTemp[index]);
                    },
                  ),
                ),
              ),
            );
          } else {
            if (_isLoading) {
              return Center(child: _buildLoadingIndicator(10));
            } else {
              return SingleChildScrollView(
                child: Center(
                    child: NoDataWidgetTickets(
                  text: "No se encontrarón Tickets",
                )),
              );
            }
          }
        }
      },
    );
  }

  Widget cardMobile(TicketsModels tickets) {
    return GestureDetector(
      onTap: () async {
        ticketResume(tickets);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorPalette.ticketsColor7,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (tickets.Estatus == "Cerrado") ...[
                              const SizedBox()
                            ] else ...[
                              buttons(tickets)[3],
                            ],
                            Row(
                              children: [
                                Tooltip(
                                  message: "Título:\t${tickets.Titulo}",
                                  child: SizedBox(
                                    width: tickets.Titulo.length > 10
                                        ? size.width / 3.2 +
                                            (tickets.Estatus == "Cerrado"
                                                ? 15
                                                : 0)
                                        : null,
                                    child: Text(
                                      tickets.Titulo,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15 * (size.width / 350),
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ),
                                Text(
                                  "\t# ${tickets.NumeroTicket}",
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Flexible(
                          child: Wrap(
                            spacing: 2,
                            alignment: WrapAlignment.end,
                            runSpacing: 5,
                            children: [
                              buttons(tickets)[0],
                              buttons(tickets)[2],
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: min(10 * (size.width / 500), 12.0),
                      ),
                    ),
                    if (tickets.FechaFinalizacion != null) ...[
                      Text(
                        "fecha de finalización  : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: min(10 * (size.width / 500), 12.0)),
                      ),
                    ],
                    Text(
                      "Descripción:  ${tickets.Descripcion}",
                      maxLines: 3,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11 * (size.width / 350),
                          fontWeight: FontWeight.w800),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width / 1.5,
                              child: Text("Usuario: ${tickets.UsuarioNombre}",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13 * (size.width / 350),
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Departamento: ${tickets.NombreDepartamento}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13 * (size.width / 350),
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(
                              height: 10,
                            ),
                            buttons(tickets)[3],
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: customButtonShowConversationMobile(
                                  tickets.IDTickets!,
                                  height: 25),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: ColorPalette.ticketsColor7,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
    double progreso = calcularProgreso(tickets);
    return SizedBox(
      height: max(153 * (size.width / 1200), 185.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorPalette.ticketsColor7,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: ColorPalette.ticketsColor,
                          borderRadius: BorderRadius.circular(7.0)),
                      height: 40,
                      width: 250,
                      transformAlignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: ListView(
                            padding: const EdgeInsets.only(top: 5.0),
                            scrollDirection: Axis.horizontal,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Tooltip(
                                message: "Título: ${tickets.Titulo}",
                                waitDuration: const Duration(milliseconds: 800),
                                child: Text(
                                  tickets.Titulo,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Ticket # ${tickets.NumeroTicket}",
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Nombre usuario reportante: ${tickets.UsuarioNombre}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Nombre usuario asignado: ${tickets.NombreUsuarioAsignado}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Departamento: ${tickets.NombreDepartamento}",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    buttons(tickets)[5],
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: max(153 * (size.width / 1200), 185.0),
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 700,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: ColorPalette.ticketsColor6,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                "Descripción:  ${tickets.Descripcion}",
                                maxLines: 3,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),

                          buildDateInfo(tickets),
                          const SizedBox(
                            height: 15,
                          ),
                          tickets.Imagen1!.isEmpty &&
                                  tickets.Imagen2!.isEmpty &&
                                  tickets.Imagen3!.isEmpty
                              ? const SizedBox()
                              : const Text(
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
                                        _showImageDialog(tickets.Imagen1!);
                                      },
                                      child: const Icon(Icons.insert_drive_file,
                                          color:
                                              Colors.white), // Icono de archivo
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
                                        _showImageDialog(tickets.Imagen2!);
                                      },
                                      child: const Icon(Icons.insert_drive_file,
                                          color:
                                              Colors.white), // Icono de archivo
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
                                      child: const Icon(Icons.insert_drive_file,
                                          color:
                                              Colors.white), // Icono de archivo
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            if (size.width > 1100) ...[
                              const SizedBox(
                                width: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buttons(tickets)[2],
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ProgressBar(
                                  progreso: progreso,
                                  onTap: (status) {
                                    print('Status tapped: $status');
                                  },
                                  width: 212,
                                ),
                              ),
                            ] else ...[
                              Column(
                                children: [
                                  buttons(tickets)[2],
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ProgressBar(
                                      progreso: progreso,
                                      onTap: (status) {
                                        print('Status tapped: $status');
                                      },
                                      width:157.5,
                                    ),
                                  ),       const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ],
                          ]),
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
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateInfo(TicketsModels tickets) {
    return size.width > 1100
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: min(17 * (size.width / 1200), 12.0),
            ),
          ),
        ),
        Expanded(
          child: tickets.FechaFinalizacion == null
              ? tickets.FechaAtencion == null
              ? SizedBox()
              : Text(
              "Fecha de Atencion : ${tickets.FechaAtencion?.split("T")[0] ?? ""} ${tickets.FechaAtencion?.split("T")[1].split(".")[0] ?? ""}",
              style: TextStyle(
                  color:
                  Colors.white.withOpacity(0.5),
                  fontSize: min(
                      17 * (size.width / 1200),
                      12.0))) // No muestra nada si FechaFinalizacion es nulo
              : Text(
            "Fecha de finalización : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: min(17 * (size.width / 1200), 12.0)),
          ),
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fecha de creación      : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: min(17 * (size.width / 1200), 12.0),
          ),
        ),
        tickets.FechaFinalizacion == null
            ? tickets.FechaAtencion == null
            ? SizedBox()
            : Text(
            "Fecha de Atencion : ${tickets.FechaAtencion?.split("T")[0] ?? ""} ${tickets.FechaAtencion?.split("T")[1].split(".")[0] ?? ""}",
            style: TextStyle(
                color:
                Colors.white.withOpacity(0.5),
                fontSize: min(
                    17 * (size.width / 1200),
                    12.0))) // No muestra nada si FechaFinalizacion es nulo
            : Text(
          "Fecha de finalización : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: min(17 * (size.width / 1200), 12.0)),
        ),
      ],
    );
  }

  Widget editButton(TicketsModels tickets) {
    return tickets.Estatus != "Cerrado"
        ? Container(
        alignment: Alignment.center,
        height: 30,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorPalette.ticketsColor2,
        ),
        child: TextButton(
            onPressed: () async {
              await editTicket(tickets);
              await _getDatos();
              setState(() {});
            },
            child: const Text(
              "Reasignar ticket",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            )))
        : Container();
  }

  Widget cardMobile2(TicketsModels tickets) {
    return GestureDetector(
      onTap: () async {
        ticketResume(tickets);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorPalette.ticketsColor7,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (tickets.Estatus == "Cerrado") ...[
                              const SizedBox()
                            ] else ...[
                              buttons2(tickets)[2],
                            ],
                            Tooltip(
                              message: "Título:\t${tickets.Titulo}",
                              child: SizedBox(
                                width: tickets.Titulo.length > 10
                                    ? size.width / 3.2 +
                                        (tickets.Estatus == "Cerrado" ? 15 : 0)
                                    : null,
                                child: Text(
                                  tickets.Titulo,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15 * (size.width / 350),
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Text(
                              "\t# ${tickets.NumeroTicket}",
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: size.width / 2.2,
                          child: Wrap(
                            spacing: 2,
                            alignment: WrapAlignment.end,
                            runSpacing: 5,
                            children: [
                              buttons2(tickets)[0],
                              buttons2(tickets)[1],
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: min(10 * (size.width / 500), 12.0),
                      ),
                    ),
                    if (tickets.FechaFinalizacion != null) ...[
                      Text(
                        "fecha de finalización  : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: min(10 * (size.width / 500), 12.0)),
                      ),
                    ],
                    Text(
                      "Descripción:  ${tickets.Descripcion}",
                      maxLines: 3,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11 * (size.width / 350),
                          fontWeight: FontWeight.w800),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Usuario: ${tickets.UsuarioNombre}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13 * (size.width / 350),
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Departamento: ${tickets.NombreDepartamento}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13 * (size.width / 350),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: customButtonShowConversationMobile(
                                  tickets.IDTickets!,
                                  height: 25),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> ticketResume(TicketsModels ticket) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();

    LoadingDialogTickets.hideLoadingDialogTickets(context);
    await Navigator.push(
      widget.context,
      MaterialPageRoute(
        builder: (context) =>
            ticketResumeScreen(areas: listArea, ticket: ticket),
      ),
    );
  }

  double calcularProgreso(TicketsModels ticket) {
    switch (ticket.Estatus) {
      case 'Abierto':
        return 0.25;
      case 'En Progreso':
        return 0.5;
      case 'Resuelto':
        return 0.75;
      case 'Cerrado':
        return 1.0;
      default:
        return 0.0;
    }
  }


  Color getColor(TicketsModels tickets) {
    Duration time =
        DateTime.now().difference(DateTime.parse(tickets.FechaCreacion!));
    Color clock = Colors.white;
    if (tickets.Estatus == "Cerrado") {
      clock = Colors.black;
    } else if (tickets.Prioridad == "Importante") {
      if (time.inDays < 2) {
        clock = Colors.green;
      } else if (time.inDays < 3) {
        clock = Colors.orange;
      } else if (time.inDays >= 3) {
        clock = Colors.red;
      }
    } else if (tickets.Prioridad == "Urgente") {
      if (time.inDays < 0.5) {
        clock = Colors.green;
      } else if (time.inDays < 1) {
        clock = Colors.orange;
      } else if (time.inDays >= 1) {
        clock = Colors.red;
      }
    } else if (tickets.Prioridad == "No urgente") {
      if (time.inDays < 3) {
        clock = Colors.green;
      } else if (time.inDays < 4) {
        clock = Colors.orange;
      } else if (time.inDays >= 4) {
        clock = Colors.red;
      }
    } else if (tickets.Prioridad == "Pregunta") {
      if (time.inDays < 3) {
        clock = Colors.green;
      } else if (time.inDays < 4) {
        clock = Colors.orange;
      } else if (time.inDays >= 4) {
        clock = Colors.red;
      }
    }
    return clock;
  }

  Widget buttonCerrado(TicketsModels tickets, {double width = 90}) {
    return Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        height: 25,
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Cerrado",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            InkWell(
                onTap: () async {
                  star(tickets);
                },
                child: const Icon(Icons.star, size: 21, color: Colors.white))
          ],
        ));
  }

  Widget buttonOpciones(TicketsModels tickets, {double width = 90}) {
    return Container(
      alignment: Alignment.center,
      height: 25,
      width: width,
      decoration: BoxDecoration(
          color: statusColors[status.indexOf(tickets.Estatus)],
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Text(
        tickets.Estatus,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> star(TicketsModels tickets) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    SatisfactionModel satisfaction = await getQualification(tickets.IDTickets!);
    LoadingDialogTickets.hideLoadingDialogTickets(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return starDialog(satisfaction, context);
      },
    );
  }

  Widget starDialog(SatisfactionModel satisfaction, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      backgroundColor: ColorPalette.ticketsColor5,
      title: const Text(
        'Calificación del ticket',
        style: TextStyle(color: Colors.white),
      ),
      content: Container(
        height: 400,
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 450,
              decoration: BoxDecoration(
                color: ColorPalette.ticketsColor2,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Text('Calificación General: ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text(
                    satisfaction.calificacion_General.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.ticketsColor2,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              width: 450,
              child: Row(
                children: [
                  const Text(
                    'Calificación Tiempo: ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    satisfaction.calificacion_Tiempo.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.ticketsColor2,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              width: 450,
              child: Row(
                children: [
                  const Text('Calificación Calidad: ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text(
                    satisfaction.calificacion_Calidad.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
                height: 160,
                decoration: BoxDecoration(
                  color: ColorPalette.ticketsColor2,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                width: 450,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Comentarios adicionales:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Text(satisfaction.Comentario.toString(),
                            maxLines: 6,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(primary: Colors.white),
          onPressed: () {
            LoadingDialogTickets.hideLoadingDialogTickets(context);
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  List<Widget> buttons(TicketsModels tickets, {double width = 90}) {
    Color clock = getColor(tickets);
    return [
      tickets.Estatus == "Cerrado"
          ? buttonCerrado(tickets, width: width)
          : buttonOpciones(tickets, width: width),
      tickets.Estatus == "Cerrado"
          ? buttonCerrado(tickets)
          : buttonOpciones(tickets),
      Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: tickets.Prioridad == "Urgente"
                ? Colors.red
                : tickets.Prioridad == "Importante"
                    ? Colors.orange
                    : tickets.Prioridad == "No urgente"
                        ? Colors.green
                        : tickets.Prioridad == "Pregunta"
                            ? Colors.blue
                            : Colors.black,
          ),
          height: 25,
          width: width,
          child: Text(
            " ${tickets.Prioridad}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          )),
      tickets.Estatus == "Cerrado"
          ? Container()
          : Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.access_time_filled_outlined,
                color: clock,
                size: 20,
              ),
              //child: Text(" ${tickets.Prioridad}", style: const TextStyle(color: Colors.white, fontSize: 11,),)
            ),
      tickets.Estatus == "Cerrado"
          ? Container()
          : Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.access_time_filled_outlined,
                color: clock,
                size: 20,
              ),
            ),
      editButton(tickets)

    ];
  }

  List<Widget> buttons2(TicketsModels tickets, {double width = 90}) {
    Color clock = getColor(tickets);
    return [
      tickets.Estatus == "Cerrado"
          ? buttonCerrado(tickets)
          : buttonOpciones(tickets),
      Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: tickets.Prioridad == "Urgente"
                ? Colors.red
                : tickets.Prioridad == "Importante"
                    ? Colors.orange
                    : tickets.Prioridad == "No urgente"
                        ? Colors.green
                        : tickets.Prioridad == "Pregunta"
                            ? Colors.blue
                            : Colors.black,
          ),
          height: 25,
          width: width,
          child: Text(
            " ${tickets.Prioridad}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          )),
      tickets.Estatus == "Cerrado"
          ? Container()
          : Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.access_time_filled_outlined,
                color: clock,
                size: 20,
              ),
            ),
    ];
  }

  Future<void> aplicarFiltroFechaReporte() async {
    if (startDateReport != null && endDateReport != null) {
      try {
        UserPreferences userPreferences = UserPreferences();
        String idPuesto = await userPreferences.getPuestoID();

        final departamentoController = departamentController();
        String? department = await departamentoController.getPuesto(idPuesto);

        final ticketViewController = TicketViewController();
        DateTime before = today.subtract(const Duration(days: 5));
        dateInitial.text =
            "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
        listTempTickets =
            await ticketViewController.getTicketsRecibidosReportAdmin(
                "${startDateReport}", "${endDateReport},", "", department);
        listTicketsTempReport = listTempTickets;
        if (listTicketsTempReport.isEmpty) {
          isEmpty = true;
        }
        setState(() {});
        generatedTicketsReport2(
            context, listTicketsTempReport, startDateReport!, endDateReport!);
      } catch (e) {
        CustomSnackBar.showErrorSnackBar(context,
            "No se puede generar un reporte en ese rango porque no existen tickets disponibles");
      }
    }
  }

  Future<void> changeStatus(
      {required String id, required String estatus}) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      StatusModels status = StatusModels(idTicket: id, status: estatus);
      StatusController statusController = StatusController();
      bool save = await statusController.changueStatus(status);
      if (save) {
        await Future.delayed(const Duration(milliseconds: 500), () async {
          LoadingDialogTickets.hideLoadingDialogTickets(context);
          await Future.delayed(const Duration(milliseconds: 200), () async {
            CustomAwesomeDialogTickets(
                    title: Texts.updateSuccess,
                    desc: '',
                    width: size.width > 500 ? null : size.width * 0.9,
                    btnOkOnPress: () {},
                    btnCancelOnPress: () {})
                .showSuccess(context);
            await Future.delayed(
                const Duration(milliseconds: 2550), () async {});
          });
        });
      } else {
        CustomAwesomeDialogTickets(
            title: Texts.errorSavingData,
            desc: Texts.ticketErrorSave,
            btnOkOnPress: () {
              LoadingDialogTickets.hideLoadingDialogTickets(context);
            },
            width: size.width > 500 ? null : size.width * 0.9,
            btnCancelOnPress: () {
              LoadingDialogTickets.hideLoadingDialogTickets(context);
            }).showError(context);
      }
    } catch (e) {
      CustomAwesomeDialogTickets(
          title: Texts.errorSavingData,
          desc: '${Texts.ticketErrorSave}. $e',
          btnOkOnPress: () {
            LoadingDialogTickets.hideLoadingDialogTickets(context);
          },
          width: size.width > 500 ? null : size.width * 0.9,
          btnCancelOnPress: () {
            LoadingDialogTickets.hideLoadingDialogTickets(context);
          }).showError(context);
    }
  }

  Future<bool> comprobarSave() {
    var completer = Completer<bool>();
    CustomAwesomeDialogTickets(
        title: Texts.askSaveConfirmStatus,
        desc: '',
        btnOkOnPress: () {
          completer.complete(true);
        },
        width: size.width > 500 ? null : size.width * 0.9,
        btnCancelOnPress: () {
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
                  width: 2,
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
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
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
    if (searchController.text.isNotEmpty) {
      listTicketsTemp = listTicketsTemp
          .where((ticket) =>
              ticket.Titulo.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              "${ticket.UsuarioAsignadoID} ${ticket.NombreDepartamento} ${ticket.Estatus}"
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              ticket.UsuarioNombre!
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  Future<void> aplicarFiltroFecha() async {
    if (startDate != null && endDate != null) {
      try {
        UserPreferences userPreferences = UserPreferences();
        String idPuesto = await userPreferences.getPuestoID();
        final departamentoController = departamentController();
        String department = await departamentoController.getPuesto(idPuesto);

        final ticketViewController = TicketViewController();
        DateTime before = today.subtract(const Duration(days: 5));
        dateInitial.text =
            "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
        listTickets = await ticketViewController.getTicketsRecibidosAdmin(
            "${startDate}", "${endDate},", department);
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
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      List<ComentaryModels> listComentary = await _getCommentaries(idTickets);
      LoadingDialogTickets.hideLoadingDialogTickets(context);

      await myShowDialog(
        TicketsConversationScreen(
          idTicket: idTickets,
          listCommentaries: listComentary,
          activeMessages: true,
        ),
        context,
        size.width * .30,
        null,
        ColorPalette.ticketsColor,
      );
      LoadingDialogTickets.hideLoadingDialogTickets(context);
      listComentary.clear();
    } catch (e) {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
    }
  }

  Future<void> _getDatos() async {
    try {
      UserPreferences userPreferences = UserPreferences();
      String idPuesto = await userPreferences.getPuestoID();
      final departamentoController = departamentController();
      String departament = await departamentoController.getPuesto(idPuesto);

      final ticketViewController = TicketViewController();
      DateTime before = today.subtract(const Duration(days: 5));
      DateTime after = today.add(const Duration(days: 1));
      dateInitial.text =
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
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
      final connectionExceptionHandler = ConnectionExceptionHandler();
      connectionExceptionHandler.handleConnectionException(context, e);
      //print('Error al obtener datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<ComentaryModels>> _getCommentaries(String idTicket) async {
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

  Future<void> editTicket(TicketsModels ticket) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();
    LoadingDialogTickets.hideLoadingDialogTickets(context);
    if (size.width < 500) {
      Navigator.of(widget.context).push(MaterialPageRoute(
          builder: (context) =>
              ticketReasignScreen(areas: listArea, ticket: ticket)));
    } else {
      await myShowDialogScale(
          ticketReasignScreen(
            areas: listArea,
            ticket: ticket,
          ),
          context,
          background: ColorPalette.ticketsColor4);
    }
  }


  getQualification(String idTicket) async {
    try {
      SatisfactionModel? satisfactionModel = SatisfactionModel();
      final SatisfactionController satisfactionController =
          SatisfactionController();
      satisfactionModel =
          await satisfactionController.getSatisfaction(idTicket);
      return satisfactionModel;
    } catch (e) {
      print('Error al obtener calificación: $e');
    }
  }
}
