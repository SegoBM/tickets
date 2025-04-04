import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi = url;
const waitTime1 = waitTime;

class AttentionController with ChangeNotifier {
  AttentionController() {}

  Future<bool> saveAtentionDate(String idTicket) async {
    final url1 = Uri.http(urlapi, '/api/Tickets/AddFechaAtencion', {
      "id": idTicket,
      "fechaAtencion": DateTime.now().toIso8601String(),
    });
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      print("Intento $attempts");
      try {
        final resp = await http.post(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        print(resp.statusCode);
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return true;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          print('Error al enviar la solicitud: $e');
          return false;
        }
      }

      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
}