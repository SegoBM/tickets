import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../models/ConfigModels/userSession.dart';
import '../../models/TicketsModels/status.dart';

const urlapi= url;
const waitTime1 = waitTime;
class StatusController with ChangeNotifier {
  StatusController() {}
  Future<bool> changueStatus(StatusModels status) async {
    final url1 = Uri.http(urlapi, '/api/Tickets/Estatus',{"id":status.idTicket,"estatus":status.status});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    print("ID "+status.idTicket);
    print("Estatus "+status.status);
    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
            url1,
            headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',

            }
        );
        print(resp.statusCode);
        if (resp.statusCode == 200) {
          return true;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }

}
