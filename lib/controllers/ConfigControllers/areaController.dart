import 'dart:convert';
import 'package:tickets/models/ConfigModels/area.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../shared/utils/user_preferences.dart';

const urlapi= url;
const waitTime1 = waitTime;

class AreaController with ChangeNotifier {
  AreaController() {}
  //GET
  Future<List<AreaModels>> getAreasAgrupadas() async {
    List<AreaModels> listAreas= [];
    final url1 = Uri.http(urlapi, '/api/Area/Agrupados');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listAreas = areaModelsFromJson(response.body);
          return listAreas;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listAreas;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listAreas;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listAreas;
  }
  Future<List<AreaModels>> getAreasConUsuario() async {
    List<AreaModels> listAreas= [];
    final url1 = Uri.http(urlapi, '/api/Area/AgrupadosConUsuarios');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listAreas = areaConUsuariosModelsFromJson(response.body);
          return listAreas;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listAreas;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listAreas;
        }
      }
      await Future.delayed(const Duration(milliseconds: waitTime1));
    }
    return listAreas;
  }
  Future<List<AreaModels>> getAreasSubModuloAgrupadas() async {
    List<AreaModels> listAreas= [];
    final url1 = Uri.http(urlapi, '/api/Area/Agrupados/Submodulos');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listAreas = areaDepartamentoModelsFromJson(response.body);
          return listAreas;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listAreas;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listAreas;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listAreas;
  }

  //SAVE
  Future <bool> saveArea(AreaModels area, BuildContext context) async{
    UserPreferences userPreferences = UserPreferences();
    String idUsuario =await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Area/SaveAreaWithDepartments', {"UsuarioID": idUsuario});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "area": {
              "nombre": '${area.nombre}',
              "estatus": true,
            },
            "departamentos": area.departamentos!.map((departamento) => departamento.toJson2()).toList()
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

  //UPDATE
  Future<bool> updateArea (String IdArea, AreaModels area) async{
    UserPreferences userPreferences = UserPreferences();
    String idUsuario = await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Area/Update', {'id': IdArea, "UsuarioID": idUsuario});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "idArea": IdArea,
            "nombre": '${area.nombre}',
            "estatus": true,
          }),
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

  //DELETE
  Future<bool> deleteArea(String idArea) async{
    UserPreferences userPreferences = UserPreferences();
    String idUsuario = await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Area/Delete', {'id': idArea, "UsuarioID": idUsuario});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      print("Intento $attempts");
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
  Future<bool> checkArea(String nombreArea, String empresaID) async{
    final url1 = Uri.http(urlapi, '/api/Area/CheckArea', {'nombreArea': nombreArea, 'empresaId': empresaID});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      print("Intento $attempts");
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
