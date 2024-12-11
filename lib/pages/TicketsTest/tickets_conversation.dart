import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';

import '../../controllers/TicketController/ComentaryController.dart';
import '../../controllers/TicketController/TicketConComentaryController.dart';
import '../../models/TicketsModels/Comentario.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/Loading/loadingDialog.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/appBar/my_appBar.dart';

class TicketsConversationScreenTest extends StatefulWidget {
  String idTicket;
  List<ComentaryModels> listCommentaries;

  TicketsConversationScreenTest(
      {super.key, required this.idTicket, required this.listCommentaries});

  @override
  State<TicketsConversationScreenTest> createState() =>
      _TicketsConversationScreenTestState();
}

class _TicketsConversationScreenTestState extends State<TicketsConversationScreenTest> {
  List<ComentaryModels> listCommentaries = [];
  List<ComentaryModels> filteredCommentaries = [];
  bool isEmpty = false;

  @override
  void initState() {
    _getDatos();

    super.initState();
  }

  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Scaffold(
        appBar: MyCustomAppBarMobile(
          title: "Comentarios",
          context: context,
          color: Colors.white,
          backgroundColor: ColorPalette.ticketsColor,
          ticketsFlag: true,
          size: 20,
          backButton: true,
        ),
        body: Container(
          color: ColorPalette.ticketsColor,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorPalette.ticketsColor5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredCommentaries.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return card(filteredCommentaries[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: ColorPalette.ticketsColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),

                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Cambia esto al color que prefieras
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Cambia esto al color que prefieras
                          ),
                          fillColor: ColorPalette.ticketsColor2,
                          filled: true,
                          labelText: 'Ingresa tu mensaje',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.white,
                      onPressed: () async {
                        await postComentary();

                        setState(() {
                          _messages.insert(0, _messageController.text);
                          _messageController.clear();

                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget card(ComentaryModels commentary) {
    return FutureBuilder<String>(
      future: getUser(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el usuario
        } else {
          return Column(
            children: [
              Align(
                alignment: snapshot.data == commentary.IDUsuario
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  //color:
                  width: 400,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: snapshot.data == commentary.IDUsuario
                        ? ColorPalette.ticketsColor5
                        : ColorPalette.ticketsColor5,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment:
                              snapshot.data == commentary.IDUsuario
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  snapshot.data == commentary.IDUsuario
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                snapshot.data == commentary.IDUsuario
                                    ? SizedBox.shrink()
                                    : Icon(Icons.person, color: Colors.white),
                                SizedBox(width: 6),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.16, // Ajusta esto según tus necesidades
                                  ),
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: snapshot.data == commentary.IDUsuario
                                        ? Colors.blue
                                        : ColorPalette.ticketsColor9,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${commentary.NombreUsuario} ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          )),
                                      SizedBox(height: 6),
                                      Text(
                                        "${commentary.Comentario} ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal),
                                        maxLines: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 6),
                                snapshot.data == commentary.IDUsuario
                                    ? Icon(Icons.person, color: Colors.white)
                                    : SizedBox.shrink(),
                              ],
                            ),
                            Text(
                              "${commentary.FechaHoraComentario?.split("T")[0]}  ${commentary.FechaHoraComentario?.split("T")[1].split(".")[0]}",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
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

  Future<void> postComentary() async {
    LoadingDialog.showLoadingDialog(context, Texts.loadingData);

    try {
      UserPreferences userPreferences = UserPreferences();
      String idUsuario = await userPreferences.getUsuarioID();
      ComentaryModels commentary = ComentaryModels(
        Comentario: _messageController.text,
        IDUsuario: idUsuario,
        idTicket: widget.idTicket,
      );
      CommentaryController ticketController = CommentaryController();
      bool save = await ticketController.saveComment(commentary);
      if (save) {
        _getDatos();
      } else {
        CustomSnackBar.showErrorSnackBar(context, "Error al enviar");
      }

    } catch (e) {}
    Navigator.pop(context);
  }

  Future<void> _getDatos() async {
    try {
      final ticketCommentary = TicketConComentaryController();

      listCommentaries =
          await ticketCommentary.getTicketComentary(widget.idTicket);

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
      print(filteredCommentaries.first.Comentario);
      setState(() {});
    } catch (e) {
      final connectionExceptionHandler = ConnectionExceptionHandler();
      //print('Error al obtener datos: $e');
    }
  }
}
