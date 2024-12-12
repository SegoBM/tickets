import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Tickets/CustomeAwesomeDialogTickets.dart';
import 'package:tickets/pages/Tickets/satisfactionTickets.dart';
import 'package:tickets/pages/Tickets/ticketEditScreen.dart';
import 'package:tickets/pages/Tickets/ticketResumeScreen.dart';
import 'package:tickets/pages/Tickets/ticket_noResolved.dart';
import 'package:tickets/pages/Tickets/ticket_registration_screen.dart';
import 'package:tickets/pages/Tickets/tickets_conversation.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import '../../controllers/ConfigControllers/areaController.dart';
import '../../controllers/TicketController/SatisfactionController.dart';
import '../../controllers/TicketController/StatusController.dart';
import '../../controllers/TicketController/TicketConComentaryController.dart';
import '../../controllers/TicketController/ticketViewController.dart';
import '../../models/ConfigModels/area.dart';
import '../../models/TicketsModels/Comentario.dart';
import '../../models/TicketsModels/satisfaction.dart';
import '../../models/TicketsModels/status.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/PopUpMenu/PopupMenuTickets.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/buttons/custom_button.dart';
import '../../shared/widgets/buttons/custom_dropdown_button.dart';
import '../../shared/widgets/textfields/my_textfield_icon.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

import 'customNoDataTickets.dart';
import 'loadingDialogTickets.dart';
class TicketsLevantados extends StatefulWidget {
  static String id = 'TicketsLevantados';
  BuildContext context;
  TicketsLevantados({super.key, required this.context});

  @override
  State<TicketsLevantados> createState() => _TicketsLevantados();
}

class _TicketsLevantados extends State<TicketsLevantados> {
  late Size size; final key = GlobalKey(); FocusNode focusNode = FocusNode();
  late Timer _timer;
  TextEditingController searchController = TextEditingController(), dateInitial = TextEditingController();
  ScrollController scrollController = ScrollController(), scrollControllerMobile = ScrollController();
  AreaController areaController = AreaController();
  List<String> items = ["Item 1", "Item 2", "Item 3", "Item 4"];
  List<String> selectedItems1 = [], selectedItems2 = [];
  List<String> attachedFiles = ['archivo1.pdf', 'archivo2.docx', 'imagen.png'];
  List<String> status = ['Abierto', 'En Progreso'];
  List<String> Importancia = ['Importante', 'Urgente', 'No urgente', 'Pregunta'];
  List<Color> statusColors = [Colors.green, Colors.orange];
  Color currentColor = Colors.green;
  List<TicketsModels> listTickets = [], listTicketsTemp = [], listTicketsTempReport = [];
  DateTime? startDate, endDate, startDateReport, endDateReport;
  DateTime today = DateTime.now();
  bool isEmpty = false;
  bool _isLoading = true;
  String statusConfirm = "",currentStatus = 'Abierto';
  ThemeData theme = ThemeData();
  final ticketViewController = TicketViewController();
  UserPreferences userPreferences = UserPreferences();
  @override
  void initState() {
    super.initState();
    _getDatos();
    _gettingData();
    const timeLimit = Duration(seconds: 30);
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ColorPalette.ticketsTextSelectedColor,
      floatingActionButton: size.width > 500 ? null : customButtonAddMobile(),
      body: size.width > 500 ? body() : bodyMobile(),
    );
  }
  List<Widget> _filtros() {
    return [
      SizedBox(width: 250, height: 55,
        child: MyTextfieldIcon(labelText: Texts.searchTicket, colorLineBase: Colors.black54,
          textController: searchController, textColor: Colors.black54, cursorColor: Colors.black54,
          suffixIcon: const Icon(IconLibrary.iconSearch, color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          backgroundColor: ColorPalette.ticketsSelectedColor, formatting: false, focusNode: focusNode,
          colorLine: Colors.black54, textStyle: const TextStyle(color: Colors.black54),
          onChanged: (value) {
           aplicarFiltro();
           setState(() {
             FocusScope.of(context).requestFocus(focusNode);
           });
          },
        ),
      ),
      const SizedBox(width: 10,),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8), width: 250,
        decoration: BoxDecoration(color: ColorPalette.ticketsSelectedColor,
            borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(context: context, items: status, selectedItems: selectedItems1,
            textColor: Colors.black54, backgroundColor: ColorPalette.ticketsColor4, setState: setState,
            text: Texts.ticketSelectStatus, color: Colors.black54,
            onTap: () {aplicarFiltro();}),
      ),
      const SizedBox(width: 10,),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        width: 250, decoration: BoxDecoration(color: ColorPalette.ticketsSelectedColor,
            borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(context: context, items: Importancia,
            selectedItems: selectedItems2, setState: setState,
            text: Texts.ticketSelectImportance, color: Colors.black54,
            textColor: Colors.black54, backgroundColor: ColorPalette.ticketsColor4,
            onTap: () {aplicarFiltro();}),
      ),
      const SizedBox(width: 10,),
      FloatingActionButton(
        onPressed: () {
          HapticFeedback.vibrate();
          LoadingDialogTickets.showLoadingDialogTickets(context, Texts.ticketLoading);
          showDialog<DateTimeRange>(context: context,
            builder:  size.width>500? (context) => AlertDialog(
              backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
              content: SizedBox(width: 338, height: 530, child: dialogCustomDateRangePickerFilter()),
            ) : (context) => dialogCustomDateRangePickerFilter(),
          );
        },
        tooltip: Texts.ticketSelectDateRange, backgroundColor: ColorPalette.ticketsColor,
        child: const Icon(Icons.calendar_today_outlined, color: Colors.white,),
      ),
    ];
  }
  Widget dialogCustomDateRangePickerFilter() {
    return CustomDateRangePicker(
      minimumDate: DateTime(2024,1,1),
      maximumDate: DateTime.now().add(const Duration(days: 100)),
      backgroundColor: Colors.white, primaryColor: ColorPalette.ticketsColor,
      onApplyClick: (start, end) {
        setState(() async {
          endDate = end.add(const Duration(days: 1));
          startDate = start;
          Navigator.of(context, rootNavigator: true).pop();
          await aplicarFiltroFecha();
          await Future.delayed(const Duration(milliseconds: 400), (){
            LoadingDialogTickets.hideLoadingDialogTickets(context);
          });
        });
      },
      onCancelClick: () {
        setState(() async {
          endDate = null;
          startDate = null;
          Navigator.of(context, rootNavigator: true).pop();
          await Future.delayed(const Duration(milliseconds: 400), (){
            LoadingDialogTickets.hideLoadingDialogTickets(context);
          });
        });
      },
    );
  }
  Widget _customButtonShowConversation(String idTickets) {
    return CustomButton(text: size.width > 1050 ? Texts.conversacion : "",
        onPressed: () async {showConversation(idTickets);},
        icon: IconLibrary.iconConversation, height: 50,
        width: size.width < 1050 ? 30 : 108, color: ColorPalette.ticketsColor.withOpacity(0.9),
        colorText: Colors.white);
  }
  Widget customButtonShowConversationMobile(String idTickets, {double width = 108, double height = 50, double widthIcon = 30}){
    return IconButton(onPressed: () async {showConversationMobile(idTickets);},
        icon: const Icon(IconLibrary.iconConversation, color: Colors.white,),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(ColorPalette.ticketsColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
          ),
        ));
  }
  Widget _customButtonAdd() {
    return IntrinsicHeight(
      child: CustomButton(text: Texts.ticketAdd,
          onPressed: () async {addTicket();}, icon: IconLibrary.iconAdd, height: 50,
          color: ColorPalette.ticketsColor.withOpacity(0.9), colorText: Colors.white),
    );
  }
  Widget customButtonAddMobile() {
    return IconButton(onPressed: (){HapticFeedback.heavyImpact();addTicket();}, icon: const Icon(IconLibrary.iconAdd,
      color: ColorPalette.ticketsColor, size: 40,),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(ColorPalette.ticketsColor4),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
          ),
        ));
  }
  Widget body() {
    return Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: MyCustomAppBarDesktop(title: "Levantados", context: context,
          textColor: Colors.white, backButton: false, color: ColorPalette.ticketsColor,ticketsFlag: false,
          defaultButtons: true,
          backButtonWidget: TextButton.icon(icon: const Icon(IconLibrary.iconBack, color: Colors.white,),
            label: const Text(Texts.ticketExit, style: TextStyle(color: Colors.white),),
            style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.transparent,),
            onPressed: () {Navigator.of(widget.context).pop();},
          ),
        ),
        body: Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (size.width > 1260) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [..._filtros(),],),
                      _customButtonAdd(),
                    ],
                  )
                ] else ...[
                  Row(
                    children: [
                      _filtros()[0],
                      const SizedBox(width: 10,),
                      _filtros()[2]
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _filtros()[4],
                          const SizedBox(width: 10,),
                          _filtros()[6],
                        ],
                      ),
                      _customButtonAdd(),
                    ],
                  ),
                ],
                const SizedBox(height: 5,),
                SizedBox(height: size.height - 120,
                    child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,), padding: const EdgeInsets.all(3),
                      child: futureList(),))
              ],
            ),
          ),
        ));
    //body: Column(children: [..._filtros()],),);
  }
  Widget bodyMobile() {
    return Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
        body: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadingEdgeScrollView.fromSingleChildScrollView(child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,controller: scrollControllerMobile,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    _filtros()[0],
                    const SizedBox(width: 5,),
                    _filtros()[6],
                    const SizedBox(width: 5,),
                    buttonFilters(),
                    //const SizedBox(width: 5,),
                  ],),
                )),
                const SizedBox(height: 5,),
                SizedBox(height: size.height - 150,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0),
                        color: ColorPalette.ticketsColor,
                      ), padding: const EdgeInsets.all(2), child: futureList(mobile: true),
                    ))
              ],
            ),
          ),
        ));
    //body: Column(children: [..._filtros()],),);
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
            return futureListTickets(mobile);
          } else {
            if (_isLoading) {
              return Center(child: _buildLoadingIndicator(10));
            } else {
                return RefreshIndicator(child: SingleChildScrollView(child: Center(child: NoDataWidgetTickets(text: "No se encontrarón Tickets",)),),
                    onRefresh: () async {await _getDatos();});
              }
          }
        }
      },
    );
  }
  Widget futureListTickets(bool mobile) {
    return RefreshIndicator(onRefresh: (){return _getDatos();}, color: ColorPalette.ticketsColor2,backgroundColor: ColorPalette.ticketsUnselectedColor,
      child: Scrollbar(thumbVisibility: true, controller: scrollController,
      child: FadingEdgeScrollView.fromScrollView(
        child: ListView.builder(shrinkWrap: true,physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController, itemCount: listTicketsTemp.length,
          itemBuilder: (context, index) {
            return !mobile? card(listTicketsTemp[index]) : cardMobile(listTicketsTemp[index]);
          },
        ),
      ),
    ),);
  }

  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return cardEsqueleto(size.width);
    });
    return SingleChildScrollView(physics: const NeverScrollableScrollPhysics(),
      child: Column(children: buttonList,),
    );
  }

  Widget cardEsqueleto(double width) {
    return SizedBox(width: width,
      height: max(152 * (size.width / 1200), 180.0),
      child: Container(margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: ColorPalette.ticketsColor7,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Shimmer.fromColors(baseColor: ColorPalette.ticketsColor7,
            highlightColor: ColorPalette.ticketsColor2 == Brightness.light
                ? const Color.fromRGBO(195, 193, 186, 1.0) : const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget card(TicketsModels tickets) {
    return SizedBox(height: max(153 * (size.width / 1200), 178.0),
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
        color: ColorPalette.ticketsColor7, elevation: 0,
        child: Padding(padding: const EdgeInsets.all(5.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 1,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(alignment: Alignment.center,
                      decoration: BoxDecoration(color: ColorPalette.ticketsColor, borderRadius: BorderRadius.circular(7.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 10), height: 40, width: 250,
                      transformAlignment: Alignment.center,
                      child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                             Expanded(child: ListView(padding: const EdgeInsets.only(top: 5.0),
                               scrollDirection: Axis.horizontal,
                        children: [
                          Tooltip(message: "Título: ${tickets.Titulo}", waitDuration: const Duration(milliseconds: 800),
                            child: Text(tickets.Titulo, style: const TextStyle(color: Colors.white,
                              fontSize: 15, fontWeight: FontWeight.bold,
                            ),
                          ),)
                        ],
                      )
                      ),
                          if(tickets.Estatus =="Cerrado")...[
                            const SizedBox(width: 15,)
                          ]else...[
                            buttons(tickets)[2],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Text("Ticket # ${tickets.NumeroTicket}",
                      style: const TextStyle(color: Colors.tealAccent, fontSize: 12,),
                    ),
                    const SizedBox(height: 8,),
                    Text("Usuario: ${tickets.NombreUsuarioAsignado??tickets.NombreDepartamento}",overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5,),
                    Text("Departamento: ${tickets.NombreDepartamento}",
                      style: TextStyle(color: Colors.white.withOpacity(0.8),
                          fontSize: 13 * (size.width / 1400), fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 10,),
                  buttons(tickets)[3],
                  ],
                ),
              ),
              Expanded(flex: 2,
                  child:
                  SingleChildScrollView(controller: ScrollController(), scrollDirection: Axis.vertical,
                    child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(alignment: Alignment.centerLeft,
                          child: Container(width: 700, padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(color: ColorPalette.ticketsColor6,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text("Descripción:  ${tickets.Descripcion}", maxLines: 3,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5),
                                    fontSize: min(17 * (size.width / 1200), 12.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: tickets.FechaFinalizacion == null
                                    ? Container() // No muestra nada si FechaFinalizacion es nulo
                                    : Text(
                                  "Fecha de finalización : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: min(17 * (size.width / 1200), 12.0)),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 15,),
                        tickets.Imagen1!.isEmpty && tickets.Imagen2!.isEmpty && tickets.Imagen3!.isEmpty
                            ? SizedBox(height: 90,)
                            : const Text("Archivos adjuntos:",
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            if (tickets.Imagen1 != null && tickets.Imagen1!.isNotEmpty) ...[
                              Padding(padding: const EdgeInsets.all(8.0),
                                child: MouseRegion(cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {_showImageDialog(tickets.Imagen1!);},
                                    child: const Icon(Icons.insert_drive_file, color: Colors.white), // Icono de archivo
                                  ),
                                ),
                              ),
                            ],
                            if (tickets.Imagen2 != null && tickets.Imagen2!.isNotEmpty) ...[
                              Padding(padding: const EdgeInsets.all(8.0),
                                child: MouseRegion(cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {_showImageDialog(tickets.Imagen2!);},
                                    child: const Icon(Icons.insert_drive_file, color: Colors.white), // Icono de archivo
                                  ),
                                ),
                              ),
                            ],
                            if (tickets.Imagen3 != null && tickets.Imagen3!.isNotEmpty) ...[
                              Padding(padding: const EdgeInsets.all(8.0),
                                child: MouseRegion(cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {_showImageDialog(tickets.Imagen3!);},
                                    child: const Icon(Icons.insert_drive_file, color: Colors.white), // Icono de archivo
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )

              ),
              Expanded(flex: 1,
                  child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                    Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(children: [
                          if (size.width > 1100) ...[
                            const SizedBox(width: 6,),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              buttons(tickets)[0],
                              const SizedBox(width: 5),
                              buttons(tickets)[1],
                            ],),
                            const SizedBox(width: 10,)
                          ] else ...[
                            Column(children: [
                              buttons(tickets)[0],
                              const SizedBox(height: 10,),
                              buttons(tickets)[1],
                              const SizedBox(height: 8,),
                            ],
                            ),
                          ],
                        ]),
                        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Center(child: _customButtonShowConversation(tickets.IDTickets!)),
                        ],),
                      ],
                    ),
                  ],)
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget cardMobile(TicketsModels tickets) {
    return GestureDetector(
      onDoubleTap: (){
      if(tickets.Estatus != "Cerrado"){
        CustomAwesomeDialogTickets(title: Texts.ticketEditConfirm, desc: "Ticket: #${tickets.NumeroTicket}", btnOkOnPress: () async {
          await editTicket(tickets);
        }, btnCancelOnPress: () {}, width: size.width<500? size.width*.9:null).showQuestion(context);
      }else{
        MyCherryToast.showWarningSnackBar(context, theme, Texts.ticketErrorClose);
      }
    },
      onTap: () async {HapticFeedback.vibrate();ticketResume(tickets);},
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
      color: ColorPalette.ticketsColor7, elevation: 0,
      child: Padding(padding: const EdgeInsets.all(5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 1,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    Row(children: [
                      if(tickets.Estatus =="Cerrado")...[
                        const SizedBox()
                      ]else...[
                        buttons(tickets)[2],
                      ],
                      Tooltip(message: "Título:\t${tickets.Titulo}",
                        child: SizedBox(width: tickets.Titulo.length>10? size.width/3.2 + (tickets.Estatus == "Cerrado"? 15 : 0): null, child: Text(tickets.Titulo,
                         style: TextStyle(color: Colors.white, fontSize: 15 * (size.width / 350),
                             fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),),),),
                      Text("\t# ${tickets.NumeroTicket}",
                        style: const TextStyle(color: Colors.tealAccent, fontSize: 12,),),
                    ],),
                    SizedBox(width: size.width/2.2,
                      child: Wrap(spacing: 2, alignment: WrapAlignment.end,
                        runSpacing: 5,
                        children: [
                          buttons(tickets)[0],
                          buttons(tickets)[1],
                        ],),)
                  ],),
                  Text("Fecha de creación : ${tickets.FechaCreacion?.split("T")[0]} ${tickets.FechaCreacion?.split("T")[1].split(".")[0]}",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: min(10 * (size.width / 500), 12.0),),
                  ),
                  if(tickets.FechaFinalizacion != null) ...[
                    Text("Fecha de finalización  : ${tickets.FechaFinalizacion?.split("T")[0] ?? ""} ${tickets.FechaFinalizacion?.split("T")[1].split(".")[0] ?? ""}",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: min(10 * (size.width / 500), 12.0)),
                    ),
                  ],
                  Text("Descripción:  ${tickets.Descripcion}", maxLines: 3,
                    style: TextStyle(color: Colors.white, fontSize: 11 * (size.width / 350), fontWeight: FontWeight.w800),),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                      Text("Usuario: ${tickets.UsuarioNombre}",
                        style: TextStyle(color: Colors.white.withOpacity(0.8),
                            fontSize: 13 * (size.width / 350), fontWeight: FontWeight.bold),),
                      const SizedBox(height: 5,),
                      Text("Departamento: ${tickets.NombreDepartamento}",
                        style: TextStyle(color: Colors.white.withOpacity(0.8),
                            fontSize: 13 * (size.width / 350), fontWeight: FontWeight.bold),),
                    ],),
                    Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [Center(child: customButtonShowConversationMobile(tickets.IDTickets!,
                          height: 25),),],),
                  ],)
                ],
              ),
            ),
          ],
        ),
      ),
    ),);
  }
  Color getColor(TicketsModels tickets) {
    Duration time = DateTime.now().difference(DateTime.parse(tickets.FechaCreacion!));
    Color clock = Colors.white;
    if(tickets.Estatus== "Cerrado"){
      clock = Colors.black;
    } else if(tickets.Prioridad== "Importante") {
      if(time.inDays < 2){
        clock = Colors.green;
      } else if(time.inDays < 3){
        clock = Colors.orange;
      } else if(time.inDays >= 3){
        clock = Colors.red;
      }
    } else if(tickets.Prioridad== "Urgente") {
      if(time.inDays < 0.5){
        clock = Colors.green;
      } else if(time.inDays < 1){
        clock = Colors.orange;
      } else if(time.inDays >= 1){
        clock = Colors.red;
      }
    } else if(tickets.Prioridad== "No urgente") {
      if(time.inDays < 3){
        clock = Colors.green;
      } else if(time.inDays < 4){
        clock = Colors.orange;
      } else if(time.inDays >= 4){
        clock = Colors.red;
      }
    } else if(tickets.Prioridad== "Pregunta") {
      if(time.inDays < 3){
        clock = Colors.green;
      } else if(time.inDays < 4){
        clock = Colors.orange;
      } else if(time.inDays >= 4){
        clock = Colors.red;
      }
    }
    return clock;
  }
  Widget buttonCerrado(TicketsModels tickets) {
    return Container(alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(5))), height: 25, width: 90,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Cerrado", style: TextStyle(color: Colors.white, fontSize: 10,),),
            InkWell(onTap: () async {await star(tickets);},
              child: const Icon(Icons.star, size: 21, color: Colors.white),
            )
          ],
        ));
  }
  Widget buttonOpciones(TicketsModels tickets){
    return Container(alignment: Alignment.center, height: 25, width: 90,
      decoration: BoxDecoration(color: statusColors[status.indexOf(tickets.Estatus)],
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: DropdownButton<String>(isExpanded: !Platform.isWindows,
        dropdownColor: ColorPalette.ticketsColor, alignment: Alignment.center, value: tickets.Estatus,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        underline: Container(),
        onChanged: (String? newValue) async {
          HapticFeedback.vibrate();
          bool result = await comprobarSave();
          if (result) {
            await changeStatus(id: tickets.IDTickets!, estatus: newValue!);
            listTickets.where((element) => element.IDTickets == tickets.IDTickets).first.Estatus = newValue;
            tickets.Estatus = newValue;
            setState(() {});
          }
        },
        items: status.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }

  Future<void> star(TicketsModels tickets) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    SatisfactionModel? satisfaction = await getQualification(tickets.IDTickets!);

    LoadingDialogTickets.hideLoadingDialogTickets(context);
    if(satisfaction != null) {
      showDialog(context: context, builder: (BuildContext context) {
      return starDialog(satisfaction, context);
    },);
    }else{
      MyCherryToast.showWarningSnackBar(context, theme, 'Error al obtener la calificación');
    }
  }
  Widget starDialog(SatisfactionModel satisfaction, BuildContext context){
    return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      backgroundColor: ColorPalette.ticketsColor5,
      title: const Text(Texts.ticketQualification, style: TextStyle(color: Colors.white),),
      content: Container(height: 400, width: 500, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration( borderRadius: BorderRadius.circular(10),),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 450,
              decoration: BoxDecoration(color: ColorPalette.ticketsColor2, borderRadius: BorderRadius.circular(10),),
              padding: const EdgeInsets.all(10),
              child:Row(children: [
                const Text('Calificación General: ',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text(satisfaction.calificacion_General.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),),
              ],),),
            const SizedBox(height: 5),
            Container(decoration: BoxDecoration(color: ColorPalette.ticketsColor2, borderRadius: BorderRadius.circular(10),),
              padding: const EdgeInsets.all(10),width: 450,
              child: Row(children: [
                const Text('Calificación Tiempo: ',
                  style: TextStyle(color: Colors.white,
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(satisfaction.calificacion_Tiempo.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],),),
            const SizedBox(height: 5),
            Container(decoration: BoxDecoration(color: ColorPalette.ticketsColor2, borderRadius: BorderRadius.circular(10),),
              padding: const EdgeInsets.all(10),width: 450,
              child: Row(children: [
                const Text('Calificación Calidad: ', style: TextStyle(color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text(satisfaction.calificacion_Calidad.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],),),
            const SizedBox(height: 5),
            Container(height: 160,decoration: BoxDecoration(color: ColorPalette.ticketsColor2,
              borderRadius: BorderRadius.circular(10),),
                padding: const EdgeInsets.all(10),width: 450,
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    const Text('Comentarios adicionales:', style: TextStyle(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(satisfaction.Comentario.toString(),
                        maxLines: 6, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],)
                ],)
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(style: TextButton.styleFrom(primary: Colors.white),
          onPressed: () {
            LoadingDialogTickets.hideLoadingDialogTickets(context);
            Navigator.of(context).pop();
          },child: const Text('Cerrar'),
        ),
      ],
    );
  }
  List<Widget> buttons(TicketsModels tickets, {double width = 90}) {
    Color clock = getColor(tickets);
    return [
      tickets.Estatus == "Cerrado" ? buttonCerrado(tickets) : tickets.Estatus == "Resuelto"
          ? buttonsConfirm(tickets) : buttonOpciones(tickets),
      Container(alignment: Alignment.center, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: tickets.Prioridad == "Urgente"
            ? Colors.red : tickets.Prioridad == "Importante"
            ? Colors.orange : tickets.Prioridad == "No urgente"
            ? Colors.green : tickets.Prioridad == "Pregunta"
            ? Colors.blue : Colors.black,
      ),
          height: 25, width: width,
          child: Text(" ${tickets.Prioridad}", style: const TextStyle(color: Colors.white, fontSize: 10,),)),
      tickets.Estatus == "Cerrado" ? Container() : Container(
        alignment: Alignment.center,
        child:  Icon(Icons.access_time_filled_outlined, color: clock, size: 20,),
      ),
      editButton(tickets)
    ];
  }
  Widget editButton(TicketsModels tickets) {
    return tickets.Estatus != "Cerrado" ? Container(alignment: Alignment.center, height: 30, width: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: ColorPalette.ticketsColor2,),
        child: TextButton(
            onPressed: () async {
              await editTicket(tickets);
              await _getDatos();
              setState(() {});
            },
            child: const Text("Editar ticket", style: TextStyle(color: Colors.white, fontSize: 12,),
            ))) : Container();
  }
  Widget buttonFilters(){
    return FloatingActionButton(key: key,
      onPressed: () async {
      HapticFeedback.vibrate();
        BuildContext context = key.currentContext!;
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
            button.localToGlobal(button.size.bottomCenter(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        var result = await showMenu(
          context: context, position: position, elevation: 8.0, color: ColorPalette.ticketsColor4,
          constraints: const BoxConstraints(maxWidth: 274.0), surfaceTintColor: Colors.transparent,
          items: <PopupMenuEntry<String>>[
            PopupMenuItem<String>(enabled: false, padding: EdgeInsets.zero,
              child: MyPopupMenuButtonFilter(selectedItems1: selectedItems1, selectedItems2: selectedItems2,),
            ),
          ],
        );
        HapticFeedback.vibrate();
        aplicarFiltro();
      }, tooltip: Texts.ticketFilterOptions, backgroundColor: ColorPalette.ticketsColor,
      child: const Icon(Icons.filter_alt_rounded, color: Colors.white,),
    );
  }
  Widget buttonsConfirm(TicketsModels tickets){
    return Column(children: [
      GestureDetector(child: Container(alignment: Alignment.center, height: 25, width: 90,
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5),),
        child: const Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 10),),
      ), onTap: () async {
        //await myShowDialog(ticket_noResolved(id: tickets.IDTickets!,), context, 400, null, ColorPalette.ticketsColor2);
        await changeStatus(id: tickets.IDTickets!, estatus: "Cerrado");
        setState(() {
          listTickets.where((element) => element.IDTickets == tickets.IDTickets).first.Estatus = "Cerrado";
          tickets.Estatus = "Cerrado";
        });
      },),
      const SizedBox(height: 5,),
      GestureDetector(child: Container(alignment: Alignment.center, height: 25, width: 90,
        decoration: BoxDecoration(color: ColorPalette.ticketsColor10, borderRadius: BorderRadius.circular(5),),
        child: const Text("No resuelto", style: TextStyle(color: Colors.white, fontSize: 10),),
      ), onTap: () async {
        await changeStatusExtra(id: tickets.IDTickets!, estatus: "En Progreso");
        await myShowDialog(ticket_noResolved(id: tickets.IDTickets!,), context, 400, null, ColorPalette.ticketsColor2);
        setState(() {
          listTickets.where((element) => element.IDTickets == tickets.IDTickets).first
              .Estatus = "En Progreso";tickets.Estatus = "En Progreso";
        });
      },)
    ],
    );
  }
  Future<void> changeStatus({required String id, required String estatus}) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      StatusModels status = StatusModels(idTicket: id, status: estatus);
      StatusController statusController = StatusController();
      bool save = await statusController.changueStatus(status);
      if (save) {
        Vibration.vibrate(pattern: [400, 200, 350, 250]);
        await Future.delayed(const Duration(milliseconds: 500), () async {
          LoadingDialogTickets.hideLoadingDialogTickets(context);
          await Future.delayed(const Duration(milliseconds: 200), () async {
            CustomAwesomeDialogTickets(title: Texts.updateSuccess, desc: '', btnOkOnPress: () {},
                    btnCancelOnPress: () {}, width: size.width<500? size.width*.9:null).showSuccess(context);
            await Future.delayed(const Duration(milliseconds: 2550), () async {
              if(estatus == "Cerrado"){
                await satisfactionTicket(id);
              }
            });
          });
        });
      } else {
        try{
          Vibration.vibrate(pattern: [100, 1200]);
        }catch(e){
          print(e);
        }
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: 'Error al guardar el ticket',
            btnOkOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
            btnCancelOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
            width: size.width<500? size.width*.9:null).showError(context);
      }
    } catch (e) {
      CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: '${Texts.ticketErrorSave}}. $e',
          btnOkOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
          btnCancelOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
          width: size.width<500? size.width*.9:null).showError(context);
    }
  }
  Future<void> changeStatusExtra({required String id, required String estatus}) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      StatusModels status = StatusModels(idTicket: id, status: estatus);
      StatusController statusController = StatusController();
      bool save = await statusController.changueStatus(status);
      if (save) {
        await Future.delayed(const Duration(milliseconds: 500), () async {
          LoadingDialogTickets.hideLoadingDialogTickets(context);
          await Future.delayed(const Duration(milliseconds: 200), () async {
            CustomAwesomeDialogTickets(title: Texts.updateSuccess, desc: '', btnOkOnPress: () {},
                    btnCancelOnPress: () {}, width: size.width<500? size.width*.9:null).showSuccess(context);
            await Future.delayed(const Duration(milliseconds: 2550), () async {});
          });
        });
      } else {
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: Texts.ticketErrorSave,
            btnOkOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
            btnCancelOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
            width: size.width<500? size.width*.9:null).showError(context);
      }
    } catch (e) {
      CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: '${Texts.ticketErrorSave}. $e',
          btnOkOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
          btnCancelOnPress: () {LoadingDialogTickets.hideLoadingDialogTickets(context);},
          width: size.width<500? size.width*.9:null).showError(context);
    }
  }
  Future<void> addTicket() async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();
    LoadingDialogTickets.hideLoadingDialogTickets(context);
    if(size.width < 500){
      await Navigator.of(widget.context).push(MaterialPageRoute(builder: (context) => ticketRegistrationScreen(areas: listArea)));
    }else{
      await myShowDialogScale(ticketRegistrationScreen(areas: listArea), context, width: 1140,
          background: ColorPalette.ticketsColor4);
    }
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    await _getDatos();
    Future.delayed(const Duration(milliseconds: 400),(){
      LoadingDialogTickets.hideLoadingDialogTickets(context);
    });
  }
  Future<void> editTicket(TicketsModels ticket) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();
    LoadingDialogTickets.hideLoadingDialogTickets(context);
    if(size.width < 500){
      Navigator.of(widget.context).push(MaterialPageRoute(builder: (context) => ticketEditScreen(areas: listArea, ticket: ticket)));
    }else{
      await myShowDialogScale(ticketEditScreen(areas: listArea, ticket: ticket,), context, background: ColorPalette.ticketsColor4);
    }
  }

  Future<void> ticketResume(TicketsModels ticket) async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();

    LoadingDialogTickets.hideLoadingDialogTickets(context);
    await Navigator.push(widget.context,
      MaterialPageRoute(builder: (context) => ticketResumeScreen(areas: listArea, ticket: ticket),),);
  }
  Future<bool> comprobarSave() {
    var completer = Completer<bool>();
    CustomAwesomeDialogTickets(title: Texts.askSaveConfirmStatus, desc: '', btnOkOnPress: () {completer.complete(true);},
        btnCancelOnPress: () {completer.complete(false);},
        width: size.width<500? size.width*.9:null).showQuestion(context);
    return completer.future;
  }
  void _showImageDialog(String base64Image) {
    try {
      // Attempt to decode the image
      final image = base64Decode(base64Image);
      showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(backgroundColor: ColorPalette.ticketsColor3,
            content: Container(
              decoration: BoxDecoration(border: Border.all(width: 2,),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Radio del borde
                child: Image.memory(image, fit: BoxFit.cover,),
              ),
            ),
            actions: <Widget>[
              TextButton(style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {Navigator.of(context).pop();}, child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: const Text('Error'), content: const Text('Invalid image data.'),
            actions: <Widget>[
              TextButton(child: const Text('Close'),
                onPressed: () {Navigator.of(context).pop();},
              ),
            ],
          );
        },
      );
    }
  }
  Future<void> aplicarFiltro() async {
    listTicketsTemp = listTickets;
    if (searchController.text.isNotEmpty) {
      listTicketsTemp = listTicketsTemp.where((ticket) => ticket.Titulo.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              "${ticket.UsuarioAsignadoID} ${ticket.NombreDepartamento} ${ticket.Estatus}"
                  .toLowerCase().contains(searchController.text.toLowerCase()) ||
              ticket.UsuarioNombre!
                  .toLowerCase().contains(searchController.text.toLowerCase())).toList();
    }
    if (selectedItems1.isNotEmpty) {
      listTicketsTemp = listTicketsTemp.where((ticket) => selectedItems1.contains(ticket.Estatus)).toList();
    }
    if (selectedItems2.isNotEmpty) {
      listTicketsTemp = listTicketsTemp.where((ticket) => selectedItems2.contains(ticket.Prioridad)).toList();
    }
    setState(() {});
  }
  Future<void> aplicarFiltroFecha() async {
    if (startDate != null && endDate != null) {
      try {
        UserPreferences userPreferences = UserPreferences();
        String idUsuario = await userPreferences.getUsuarioID();

        final ticketViewController = TicketViewController();
        DateTime before = today.subtract(const Duration(days: 5));
        dateInitial.text = "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
        listTickets = await ticketViewController.getTicketsAsignados("${startDate}", "${endDate},", idUsuario);
        listTicketsTemp = listTickets;
        if (listTicketsTemp.isEmpty) {
          isEmpty = true;
        }
        setState(() {});
      } catch (e) {
        CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
        final connectionExceptionHandler = ConnectionExceptionHandler();
        connectionExceptionHandler.handleConnectionException(context, e);
      }
    }
  }

  Future<void> showConversation(String idTickets) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      List<ComentaryModels> listCommentary = await _getCommentaries(idTickets);
      Future.delayed(const Duration(milliseconds: 500), () async {
        LoadingDialogTickets.hideLoadingDialogTickets(context);
        await myShowDialog(TicketsConversationScreen(idTicket: idTickets, listCommentaries: listCommentary,
            activeMessages: true), context, size.width * .30, null, ColorPalette.ticketsColor,);
        listCommentary.clear();
      });
    } catch (e) {
      print(e);
    }
  }
  Future<void> showConversation2(String idTicket) async {
    await myShowDialog(TicketsConversationScreen(idTicket: idTicket, listCommentaries: [], activeMessages: true,),
      context, size.width * .30, null, ColorPalette.ticketsColor,);
  }
  Future<void> showConversationMobile(String idTickets) async {
    try {
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      List<ComentaryModels> listCommentary = await _getCommentaries(idTickets);
      LoadingDialogTickets.hideLoadingDialogTickets(context);
      await Navigator.of(widget.context).push(MaterialPageRoute(
          builder: (context) => TicketsConversationScreen(idTicket: idTickets, listCommentaries: listCommentary,activeMessages: true,)));
      listCommentary.clear();
    } catch (e) {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
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
  Future<void> satisfactionTicket(String id) async {
    if(size.width > 500) {
      await myShowDialog(SatisfactionTickets(id: id,), context, 400, null, ColorPalette.ticketsColor2);
    }else{
      await Navigator.of(widget.context).push(MaterialPageRoute(builder: (context) => SatisfactionTickets(id: id,)));
    }
  }

  Future<void> _getDatos() async {
    try {
      String idUsuario = await userPreferences.getUsuarioID();
      DateTime before = today.subtract(const Duration(days: 5));
      DateTime after = today.add(const Duration(days: 1));
      dateInitial.text = "${before.year}-${(before.month).toString().padLeft(2, "0")}-${before.day.toString().padLeft(2, "0")} / ${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}";
      listTickets = await ticketViewController.getTicketsAsignados(
          "${before.year}-${before.month}-${before.day}", "${after.year}-${after.month}-${after.day},", idUsuario);
      listTickets.sort((a, b) => b.FechaCreacion!.compareTo(a.FechaCreacion!)); // Ordenar por fecha de creación
      listTicketsTemp = listTickets;
      if (listTicketsTemp.isEmpty) {
        isEmpty = true;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (listTicketsTemp.isEmpty) {
        CustomSnackBar.showInfoSnackBar(context, Texts.empty);
      } else if (listTicketsTemp == null) {
        CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
        final connectionExceptionHandler = ConnectionExceptionHandler();
        connectionExceptionHandler.handleConnectionException(context, e);
      }
      setState(() {
        _isLoading = false;
      });
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
  Future<SatisfactionModel?> getQualification(String idTicket) async {
    try {
      SatisfactionModel? satisfactionModel = SatisfactionModel();
      final SatisfactionController satisfactionController = SatisfactionController();
      satisfactionModel = await satisfactionController.getSatisfaction(idTicket);
      return satisfactionModel;
    } catch (e) {
      print('Error al obtener calificación: $e');
    }
    return null;
  }
  void _gettingData() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _getDatos();
    });
  }
}
