import 'package:tickets/controllers/ConfigControllers/usuarioController.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/ConfigModels/userSession.dart';

const urlapi= url;

class departamentController with ChangeNotifier {
  departamentController() {}

  Future<String> getPuesto(String puestoId) async {
    final url1 = Uri.http(urlapi, '/api/Usuario/ObtenerDepartamentoPorPuesto',{"puestoId": puestoId});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',

        });
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.body.substring(1, response.body.length - 1);
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return "";
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return "";
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return "";
  }
}
