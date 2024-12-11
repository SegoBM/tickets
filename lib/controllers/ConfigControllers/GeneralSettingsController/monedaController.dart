import 'dart:convert';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/monedas.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;
class MonedaController with ChangeNotifier {
  MonedaController() {}

  //GET
  Future<List<MonedaModels>> getMonedas() async {
    final url1 = Uri.http(urlapi, '/api/Moneda');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return monedaModelsFromJson(resp.body);
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return [];
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return [];
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return [];
  }
  //GET
  Future<List<MonedaModels>> getMonedasActivos() async {
    final url1 = Uri.http(urlapi, '/api/Moneda/Activos');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return monedaModelsFromJson(resp.body);
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return [];
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return [];
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return [];
  }
  //SAVE
  Future<MonedaModels?> saveMoneda(MonedaModels moneda, String id) async {
    final url1 = Uri.http(urlapi, '/api/Moneda', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "nombre": '${moneda.nombre}',
            "abreviatura": '${moneda.abreviatura}',
            "tipoCambio": moneda.tipoCambio
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return monedaModelFromJson(resp.body);
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
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return null;
  }
  //UPDATE
  Future<bool> updateMoneda(MonedaModels moneda, String id) async {
    final url1 = Uri.http(urlapi, '/api/Moneda', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "id": moneda.idMoneda,
            "nombre": '${moneda.nombre}',
            "abreviatura": '${moneda.abreviatura}',
            "tipoCambio": moneda.tipoCambio
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200) {
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
  //DELETE
  Future<bool> deleteMoneda(String idMoneda, String id) async {
    final url1 = Uri.http(urlapi, '/api/Moneda', {'id': idMoneda, 'usuarioID' : id});
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
  Future<bool> activarMoneda(String id, String idUser) async {
    final url1 = Uri.http(urlapi, '/api/Moneda/Activar', {'id': id, 'usuarioID' : idUser});
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(url1,
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