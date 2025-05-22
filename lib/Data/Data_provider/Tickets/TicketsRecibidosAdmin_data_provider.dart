import 'package:http/http.dart' as http;
import '../../../models/ConfigModels/userSession.dart';
import '../../../shared/utils/constants.dart';

const urlapi= url;
const waitTime1 = waitTime;

class TicketsRecibidosAdminProvider{
  Future<http.Response?> getTicketsRecibidosAdmin(url1) async {
    String? token = await UserSession().getToken();

    try {
      final response = await http.get(url1, headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": "true",
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Agregar el token aquí

      });

      return response;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
