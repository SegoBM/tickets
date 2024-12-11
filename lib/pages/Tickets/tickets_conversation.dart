import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import '../../controllers/TicketController/ComentaryController.dart';
import '../../controllers/TicketController/TicketConComentaryController.dart';
import '../../models/TicketsModels/Comentario.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/appBar/my_appBar.dart';

class TicketsConversationScreen extends StatefulWidget {
  bool activeMessages;
  String idTicket;
  List<ComentaryModels> listCommentaries;

  TicketsConversationScreen({super.key, required this.idTicket, required this.listCommentaries, required this.activeMessages});

  @override
  State<TicketsConversationScreen> createState() => _TicketsConversationScreenState();
}

class _TicketsConversationScreenState extends State<TicketsConversationScreen> {
  List<ComentaryModels> listCommentaries = [];
  List<ComentaryModels> filteredCommentaries = [];
  bool isEmpty = false;

  @override
  void initState() {
    _getDatos();
    super.initState();
  }

  final TextEditingController _messageController = TextEditingController();
  ScrollController scrollControllerTickets = ScrollController();
  final List<String> _messages = [];
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
       return bodyDesktop();

  }
  Widget bodyDesktop(){
    return Scaffold(
      backgroundColor: ColorPalette.ticketsColor,
      appBar: MyCustomAppBarMobile(
        title: "Comentarios", context: context,
        color: Colors.white, backgroundColor: ColorPalette.ticketsColor,
        ticketsFlag: true, size: 20, backButton: true,
      ),
      body: Container(color: ColorPalette.ticketsColor,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: ColorPalette.ticketsColor5,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(5),
                child: Scrollbar(
                  thumbVisibility: true, controller: scrollControllerTickets,
                  child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(shrinkWrap: true, reverse: true,
                      controller: scrollControllerTickets, itemCount: filteredCommentaries.length,
                      itemBuilder: (context, index) {
                        return card(filteredCommentaries[index]);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(padding: const EdgeInsets.all(5.0),
              child: Row(
                children: widget.activeMessages ? <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(color: Colors.white)),
                        fillColor: ColorPalette.ticketsColor2,
                        filled: true, labelText: 'Ingresa tu mensaje',
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), color: Colors.white,
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        await postCommentary();
                        setState(() {
                          _messages.insert(0, _messageController.text);
                          _messageController.clear();
                        });
                      } else {
                        CustomSnackBar.showErrorSnackBar(context, "No puedes enviar mensajes vacios");
                      }
                    },
                  ),
                ] : <Widget>[Container()],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget bodyMobile(){
    return Scaffold(
      appBar: MyCustomAppBarMobile(title: "Comentarios", context: context,
        color: Colors.white, backgroundColor: ColorPalette.ticketsColor,
        ticketsFlag: true, size: 20, backButton: true,
      ),
      body: Container(color: ColorPalette.ticketsColor,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: ColorPalette.ticketsColor5,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ), padding: const EdgeInsets.all(5),
                child: Scrollbar(thumbVisibility: true,
                  controller: scrollControllerTickets,
                  child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(shrinkWrap: true, reverse: true,
                      controller: scrollControllerTickets, itemCount: filteredCommentaries.length,
                      itemBuilder: (context, index) {
                        return cardMobile(filteredCommentaries[index]);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(padding: const EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.white), ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                        fillColor: ColorPalette.ticketsColor2,
                        filled: true, labelText: 'Ingresa tu mensaje',
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), color: Colors.white,
                    onPressed: () async {
                      if(_messageController.text.isNotEmpty){
                        await postCommentary();
                        setState(() {
                          _messages.insert(0, _messageController.text);
                          _messageController.clear();

                        });
                      }else{
                        CustomSnackBar.showErrorSnackBar(context, "No puedes enviar mensajes vacios");
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget card(ComentaryModels commentary) {
    return FutureBuilder<String>(
      future: getUser(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Muestra un indicador de carga mientras se obtiene el usuario
        } else {
          return Column(children: [
              Align(alignment: snapshot.data == commentary.IDUsuario ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 400,
                  child: Padding(padding: const EdgeInsets.all(5.0),
                    child: Container(
                      child: Column(crossAxisAlignment: snapshot.data == commentary.IDUsuario
                          ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: snapshot.data == commentary.IDUsuario
                              ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              snapshot.data == commentary.IDUsuario
                                  ? SizedBox.shrink() : Icon(Icons.person, color: Colors.white),
                              SizedBox(width: 6),
                              Container(constraints: BoxConstraints(maxWidth: size.width>500? size.width * 0.16: size.width * 0.48),
                                padding: EdgeInsets.all(10), margin: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: snapshot.data == commentary.IDUsuario
                                      ? Colors.blue : ColorPalette.ticketsColor9,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${commentary.NombreUsuario} ",
                                        style: TextStyle(color: Colors.white, fontSize: 15,)),
                                    SizedBox(height: 6),
                                    Text("${commentary.Comentario} ",
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.normal),
                                      maxLines: 15,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6),
                              snapshot.data == commentary.IDUsuario ? Icon(Icons.person, color: Colors.white)
                                  : SizedBox.shrink(),
                            ],
                          ),
                          Text("${commentary.FechaHoraComentario?.split("T")[0]}  "
                              "${commentary.FechaHoraComentario?.split("T")[1].split(".")[0]}",
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget cardMobile(ComentaryModels commentary) {
    return FutureBuilder<String>(future: getUser(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Muestra un indicador de carga mientras se obtiene el usuario
        } else {
          return Column(
            children: [
              Align(alignment: snapshot.data == commentary.IDUsuario ?
              Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 400,
                  child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    color: snapshot.data == commentary.IDUsuario
                        ? ColorPalette.ticketsColor5 : ColorPalette.ticketsColor5,
                    elevation: 0,
                    child: Padding(padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: snapshot.data == commentary.IDUsuario
                              ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: snapshot.data == commentary.IDUsuario
                                  ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                snapshot.data == commentary.IDUsuario
                                    ? SizedBox.shrink() : Icon(Icons.person, color: Colors.white),
                                SizedBox(width: 6),
                                Container(constraints: BoxConstraints(maxWidth: size.width * 0.48),
                                  padding: EdgeInsets.all(10), margin: EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: snapshot.data == commentary.IDUsuario
                                        ? Colors.blue : ColorPalette.ticketsColor9,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${commentary.NombreUsuario} ",
                                          style: TextStyle(color: Colors.white, fontSize: 15,)),
                                      SizedBox(height: 6),
                                      Text("${commentary.Comentario} ",
                                        style: TextStyle(color: Colors.white, fontSize: 13,
                                            fontWeight: FontWeight.normal), maxLines: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 6),
                                snapshot.data == commentary.IDUsuario
                                    ? Icon(Icons.person, color: Colors.white) : SizedBox.shrink(),
                              ],
                            ),
                            Text("${commentary.FechaHoraComentario?.split("T")[0]}  ${commentary.FechaHoraComentario?.split("T")[1].split(".")[0]}",
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<String> getUser() async {
    UserPreferences userPreferences = UserPreferences();
    String idUsuario = await userPreferences.getUsuarioID();
    return idUsuario;
  }

  Future<void> postCommentary() async {
    LoadingDialog.showLoadingDialog(context, Texts.loadingData);
    try {
      UserPreferences userPreferences = UserPreferences();
      String idUsuario = await userPreferences.getUsuarioID();
      ComentaryModels commentary = ComentaryModels(
        Comentario: _messageController.text,
        IDUsuario: idUsuario,
        idTicket: widget.idTicket,
      );
      _messageController.text = "";
      CommentaryController ticketController = CommentaryController();
      bool save = await ticketController.saveComment(commentary);
      if (save) {
        _getDatos();
      } else {
        CustomSnackBar.showErrorSnackBar(context, Texts.ticketErrorSend);
      }

    } catch (e) {}
    Navigator.pop(context);
  }

  Future<void> _getDatos() async {
    try {
      final ticketCommentary = TicketConComentaryController();
      listCommentaries = await ticketCommentary.getTicketComentary(widget.idTicket);
      // Ordena los comentarios por fecha
      listCommentaries.sort((b, a) {
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
      print(filteredCommentaries.first.Comentario);
      setState(() {});
    } catch (e) {
      print('Error al obtener datos: $e');
    }
  }
}
