import 'dart:convert';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/unidad.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;

class UnidadController with ChangeNotifier {
  UnidadController() {}
  //GET
  Future<List<UnidadModels>> getUnidad() async {
    final url1 = Uri.http(urlapi, '/api/Unidad');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return unidadModelsFromJson(resp.body);
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
      await Future.delayed(Duration(seconds: waitTime1));
    }
    return [];
  }
  //GET
  Future<List<UnidadModels>> getUnidadActivos() async {
    final url1 = Uri.http(urlapi, '/api/Unidad/Activos');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return unidadModelsFromJson(resp.body);
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
  Future<UnidadModels?> saveUnidad(UnidadModels unidad, String id) async {
    final url1 = Uri.http(urlapi, '/api/Unidad', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "nombre": '${unidad.nombre}',
            "abreviatura": '${unidad.abreviatura}',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return unidadModelFromJson(resp.body);
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
  Future<bool> updateUnidad(UnidadModels unidad, String id) async {
    final url1 = Uri.http(urlapi, '/api/Unidad/Actualizar', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "id": '${unidad.idUnidad}',
            "nombre": unidad.nombre,
            "abreviatura": '${unidad.abreviatura}'
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
  Future<bool> deleteUnidad(String idUnidad, String id) async {
    final url1 = Uri.http(urlapi, '/api/Unidad', {'id': idUnidad, 'usuarioID' : id});
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
  Future<bool> activarUnidad(String idUnidad, String id) async {
    final url1 = Uri.http(urlapi, '/api/Unidad/Activar', {'id': idUnidad, 'usuarioID' : id});
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