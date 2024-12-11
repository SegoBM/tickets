import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../models/TicketsModels/Comentario.dart';
const urlapi= url;
const waitTime1 = waitTime;

class TicketConComentaryController with ChangeNotifier {
  TicketConComentaryController() {}

  Future<List<ComentaryModels>> getTicketComentary(String idticket) async {
    List<ComentaryModels> filteredCommentaries = [];
    final url1 = Uri.http(urlapi, '/api/Comentarios',{"ticketId": idticket});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          filteredCommentaries = commentaryModelsFromJson(response.body);
          return filteredCommentaries;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return filteredCommentaries;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return filteredCommentaries;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return filteredCommentaries;
  }

}
