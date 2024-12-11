import 'dart:convert';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/ajustesGenerales.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;
class AjustesGeneralesController with ChangeNotifier {
  AjustesGeneralesController() {}

  //GET
  Future<AjustesGeneralesModels?> getAjustesGenerales() async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return ajustesGeneralesModelsFromJson(resp.body).first;
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
  Future<List<bool>> getAjustesUsuarios() async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales/GetAjustesUsuarios');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          List<dynamic> jsonResponse = jsonDecode(resp.body);
          List<bool> ajustesUsuarios = List<bool>.from(jsonResponse.map((e) => e as bool));
          return ajustesUsuarios;
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
  /*Future<AjustesGeneralesModels?> saveAjusteGenerales(AjustesGeneralesModels ajustesGenerales) async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "id": '${ajustesGenerales.id}',
            "permisosForzosos": ajustesGenerales.permisosForzosos,
            "multiEmpresa": ajustesGenerales.solicitarTipoDeCambio,
            "multiMoneda": ajustesGenerales.multiMoneda,
            "solicitarTipoDeCambio": ajustesGenerales.solicitarTipoDeCambio,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return ajustesGeneralesModelsFromJson(resp.body).first;
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
  }*/
  Future<bool?> saveAjustesMultiEmpresa(bool value, String id) async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales/MultiEmpresa', {'value': value.toString(), 'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return resp.body == "true";
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
  Future<bool?> saveAjustesPermisosForzosos(bool value, String id) async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales/PermisosForzosos', {'value': value.toString(), 'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return resp.body == "true";
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
  Future<bool?> saveAjustesMultiMoneda(bool value, String id) async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales/MultiMoneda', {'value': value.toString(), 'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return resp.body == 'true';
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
  Future<bool?> saveAjustesSolicitarTipoDeCambio(bool value, String id) async {
    final url1 = Uri.http(urlapi, '/api/AjustesGenerales/SolicitarTipoDeCambio', {'value': value.toString(), 'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return resp.body == "true";
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
}