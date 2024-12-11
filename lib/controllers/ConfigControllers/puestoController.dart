import 'dart:convert';
import 'package:tickets/models/ConfigModels/puesto.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;

class PuestoController with ChangeNotifier {
  PuestoController() {}

  //SAVE
  Future<PuestoModels?> savePuesto(PuestoModels puesto) async {
    final url1 = Uri.http(urlapi, '/api/Puesto/Save');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "nombre": '${puesto.nombre}',
            "departamentoID": '${puesto.departamentoId}',
            "estatus": true
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return puestoModelFromJson(resp.body);
        } else {
          print(resp.body);
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
      await Future.delayed(Duration(seconds: waitTime1));
    }
    return null;
  }
  //UPDATE
  Future<PuestoModels?> updatePuesto(String IdPuesto, PuestoModels puesto) async {
    final url1 = Uri.http(urlapi, '/api/Puesto/Update', {'id': IdPuesto.toString()});
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      print("Intento $attempts");
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "nombre": '${puesto.nombre}',
            "idPuesto": IdPuesto,
            "departamentoID": '${puesto.departamentoId}',
            "estatus": true
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200) {
          return puestoModelFromJson(resp.body);
        } else {
          print(resp.body);
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
      await Future.delayed(Duration(seconds: waitTime1));
    }
    return null;
  }

  //DELETE
  Future<bool> deletePuesto(String IdPuesto) async {
    final url1 = Uri.http(urlapi, '/api/Puesto/Delete', {'id': IdPuesto});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.delete(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200) {
          return true;
        } else if (resp.statusCode == 404) {
          return false;
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

}
