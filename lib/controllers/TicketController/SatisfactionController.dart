import 'dart:convert';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../models/TicketsModels/satisfaction.dart';

const urlapi= url;
const waitTime1 = waitTime;
class SatisfactionController with ChangeNotifier {
  SatisfactionController() {}

  Future<bool> saveSatisfaction(SatisfactionModel satisfactionModel) async {
    final url1 = Uri.http(urlapi, '/api/Encuesta');
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "calificacion_General": '${satisfactionModel.calificacion_General}',
            "calificacion_Tiempo": '${satisfactionModel.calificacion_Tiempo}',
            "calificacion_Calidad": '${satisfactionModel.calificacion_Calidad}',
            "Comentarios": '${satisfactionModel.Comentario}',
            "ticketsID": '${satisfactionModel.ticketsID}',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return true;
        } else {
          print(resp.body);
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

  Future<SatisfactionModel?> getSatisfaction(String idTicket) async {
    SatisfactionModel satisfactionModel = SatisfactionModel();
    final url1 = Uri.http(urlapi, '/api/Encuesta', {"IDTicket": idTicket});
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
        if (response.statusCode == 200 || response.statusCode == 201) {
          satisfactionModel = commentaryModelsFromJson(response.body).first;
          return satisfactionModel;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return null;
  }
}