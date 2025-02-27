import 'package:http/http.dart' as http;
import '../../../shared/utils/constants.dart';

const urlapi= url;
const waitTime1 = waitTime;

class TicketsLevantadosProvider {
  Future<http.Response?> getTicketsLevantados(url1) async {
    try {
      final response = await http.get(url1, headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": "true",
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

      return response;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
