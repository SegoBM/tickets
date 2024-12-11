import 'package:flutter/material.dart';
import 'CustomeAwesomeDialogTickets.dart';
import 'loadingDialogTickets.dart';
import '../../controllers/TicketController/ComentaryController.dart';
import '../../models/TicketsModels/Comentario.dart';
import '../../shared/utils/color_palette.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/Loading/loadingDialog.dart';
import '../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class ticket_noResolved extends StatefulWidget {
  String id;
  ticket_noResolved({Key? key, required String this.id}) : super(key: key);

  @override
  _ticketnoResolvedState createState() => _ticketnoResolvedState();
}

class _ticketnoResolvedState extends State<ticket_noResolved> {
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return noResolved();
  }

  Widget noResolved() {
    return SizedBox(height: 400,
      child: Scaffold(backgroundColor: ColorPalette.ticketsColor2,
        appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false,
          backgroundColor: ColorPalette.ticketsColor2,
          title: const Text('Resolución', style: TextStyle(color: Colors.white),),
        ),
        body: Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10), // Espacio entre el texto y las estrellas
              const Text('¿Porque no se resolvió tu problema?',
                  style: TextStyle(fontSize: 18.0, color: Colors.white)),
              const SizedBox(height: 30.0),
              TextField(controller: _commentController,
                style: const TextStyle(color: Colors.white), maxLines: 3,
                decoration: InputDecoration(
                  floatingLabelStyle: const TextStyle(color: Colors.white,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  labelText: 'Ingresa un texto',
                  labelStyle: const TextStyle(color: Colors.white), // Añade esta línea
                ),
              ),

              const SizedBox(height: 60.0),
              SizedBox(width: 170, height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor5,),
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      await postComentary();
                    }
                  },
                  child: const Text('Enviar', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> postComentary() async {
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    try {
      UserPreferences userPreferences = UserPreferences();
      String idUsuario = await userPreferences.getUsuarioID();
      ComentaryModels commentary = ComentaryModels(
        Comentario: "Problema no resuelto: ${_commentController.text}",
        IDUsuario: idUsuario,
        idTicket: widget.id,
      );
      _commentController.text = "";
      CommentaryController ticketController = CommentaryController();
      bool save = await ticketController.saveComment(commentary);
      print(save);
      if (save) {
        await Future.delayed(const Duration(milliseconds: 500), () async {
          LoadingDialogTickets.hideLoadingDialogTickets(context);
          await Future.delayed(const Duration(milliseconds: 200), () async {
            CustomAwesomeDialogTickets(title: Texts.addSuccess, desc: '', btnOkOnPress: () {},
              btnCancelOnPress: () {},).showSuccess(context);
            await Future.delayed(const Duration(milliseconds: 2550), () async {
             Navigator.of(context).pop();
            });

          });
        });
      } else {
        LoadingDialogTickets.hideLoadingDialogTickets(context);
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: '', btnOkOnPress: () {},
            btnCancelOnPress: () {}).showSuccess(context);
      }
    } catch (e) {}
  }
}
